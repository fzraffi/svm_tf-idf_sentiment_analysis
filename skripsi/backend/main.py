from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import io
import re
import string
import os
import base64
import pickle

import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory

import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.svm import LinearSVC
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score

import matplotlib.pyplot as plt


# =========================
# APP SETUP
# =========================
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# NLTK DOWNLOAD
# =========================
nltk.download("punkt")
nltk.download("punkt_tab")
nltk.download("stopwords")

STOP_WORDS = set(stopwords.words("indonesian"))
stemmer = StemmerFactory().create_stemmer()

STATE = {"df_raw": None, "df_preprocessed": None, "df_labeled": None}


# =========================
# PREPROCESS FUNCTIONS
# =========================
def clean_text(text: str) -> str:
    text = str(text).lower()
    text = re.sub(r"http\S+|www\S+", "", text)
    text = re.sub(r"@\w+", "", text)
    text = re.sub(r"\d+", "", text)
    text = text.translate(str.maketrans("", "", string.punctuation))
    text = re.sub(r"\s+", " ", text).strip()
    return text

def remove_stopwords(tokens):
    return [w for w in tokens if w not in STOP_WORDS and len(w) > 2]

def stemming(tokens):
    return [stemmer.stem(w) for w in tokens]


# =========================
# LEXICON FUNCTIONS
# =========================
def load_lexicon():
    pos_path = os.path.join("lexicon", "positive.tsv")
    neg_path = os.path.join("lexicon", "negative.tsv")

    if not os.path.exists(pos_path):
        raise FileNotFoundError(f"File tidak ditemukan: {pos_path}")
    if not os.path.exists(neg_path):
        raise FileNotFoundError(f"File tidak ditemukan: {neg_path}")

    pos_lex = pd.read_csv(pos_path, sep="\t")
    neg_lex = pd.read_csv(neg_path, sep="\t")

    if "word" not in pos_lex.columns or "word" not in neg_lex.columns:
        raise ValueError("TSV harus punya kolom bernama 'word'")

    positive_words = set(pos_lex["word"].astype(str).tolist())
    negative_words = set(neg_lex["word"].astype(str).tolist())
    return positive_words, negative_words

POS_WORDS, NEG_WORDS = load_lexicon()

def lexicon_label(text: str) -> str:
    tokens = str(text).split()
    pos = sum(1 for w in tokens if w in POS_WORDS)
    neg = sum(1 for w in tokens if w in NEG_WORDS)

    if pos > neg:
        return "positif"
    elif neg > pos:
        return "negatif"
    else:
        return "netral"


def cm_to_base64_png(cm, labels):
    fig = plt.figure(facecolor="white")
    ax = fig.add_subplot(111)

    ax.imshow(cm, cmap="Blues")
    ax.set_title("Confusion Matrix", color="black")
    ax.set_xlabel("Predicted", color="black")
    ax.set_ylabel("Actual", color="black")

    ax.set_xticks(range(len(labels)))
    ax.set_yticks(range(len(labels)))
    ax.set_xticklabels(labels, rotation=45, ha="right", color="black")
    ax.set_yticklabels(labels, color="black")

    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(
                j,
                i,
                str(cm[i, j]),
                ha="center",
                va="center",
                color="black",
                fontsize=12,
                fontweight="bold",
            )

    for spine in ax.spines.values():
        spine.set_visible(True)
        spine.set_color("black")

    buf = io.BytesIO()
    plt.tight_layout()
    plt.savefig(buf, format="png", dpi=200, facecolor="white")
    plt.close(fig)
    buf.seek(0)

    return base64.b64encode(buf.read()).decode("utf-8")


# =========================
# ENDPOINTS
# =========================
@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    content = await file.read()
    df = pd.read_excel(io.BytesIO(content))
    STATE["df_raw"] = df
    return {"message": "Upload sukses", "rows": int(len(df)), "columns": df.columns.tolist()}

@app.post("/preprocess")
async def preprocess(text_column: str = "full_text"):
    df = STATE["df_raw"]
    if df is None:
        return {"error": "Belum upload file"}

    if text_column not in df.columns:
        return {"error": f"Kolom '{text_column}' tidak ada"}

    df = df.dropna(subset=[text_column]).drop_duplicates(subset=[text_column]).copy()

    df["clean_text"] = df[text_column].apply(clean_text)
    df["tokens"] = df["clean_text"].apply(word_tokenize)
    df["filtered"] = df["tokens"].apply(remove_stopwords)
    df["stemmed"] = df["filtered"].apply(stemming)
    df["final_text"] = df["stemmed"].apply(lambda x: " ".join(x))

    STATE["df_preprocessed"] = df
    preview = df["final_text"].head(5).fillna("").astype(str).tolist()

    return {"message": "Preprocess selesai", "rows": int(len(df)), "preview_final_text": preview}

@app.post("/label")
async def label():
    df = STATE["df_preprocessed"]
    if df is None:
        return {"error": "Belum preprocess"}

    df = df.copy()
    df["label"] = df["final_text"].apply(lexicon_label)
    STATE["df_labeled"] = df

    counts = df["label"].value_counts().to_dict()
    preview = df[["final_text", "label"]].head(5).to_dict(orient="records")

    return {"message": "Labeling selesai", "label_counts": counts, "preview": preview}

@app.post("/train")
async def train(
    test_size: float = 0.2,
    random_state: int = 0,
    max_features: int = 5000
):
    df = STATE["df_labeled"]
    if df is None:
        return {"error": "Belum labeling"}

    df2 = df[["final_text", "label"]].dropna().copy()
    X = df2["final_text"]
    y = df2["label"]

    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state
    )

    # TF-IDF
    tfidf = TfidfVectorizer(max_features=max_features)
    X_train_tfidf = tfidf.fit_transform(X_train)
    X_test_tfidf = tfidf.transform(X_test)

    # SVM
    model = LinearSVC(class_weight="balanced")
    model.fit(X_train_tfidf, y_train)

    # Predict
    y_pred = model.predict(X_test_tfidf)

    # Metrics
    acc = float(accuracy_score(y_test, y_pred))

    # report dalam bentuk dict (mudah dipakai Flutter)
    report_dict = classification_report(y_test, y_pred, zero_division=0, output_dict=True)

    # confusion matrix
    labels = sorted(list(set(y)))
    cm = confusion_matrix(y_test, y_pred, labels=labels)

    cm_b64 = cm_to_base64_png(cm, labels)


    with open("svm_model.pkl", "wb") as f:
        pickle.dump(model, f)

    with open("tfidf_vectorizer.pkl", "wb") as f:
        pickle.dump(tfidf, f)

    return {
        "message": "Training + evaluasi selesai",
        "accuracy": acc,
        "labels": labels,
        "classification_report": report_dict,
        "confusion_matrix": cm.tolist(),
        "confusion_matrix_png_base64": cm_b64
    }

# ================= DOWNLOAD MODEL =================
@app.get("/download-model")
async def download_model():
    return FileResponse(
        path="svm_model.pkl",
        filename="svm_model.pkl",
        media_type="application/octet-stream",
    )


@app.get("/download-tfidf")
async def download_tfidf():
    return FileResponse(
        path="tfidf_vectorizer.pkl",
        filename="tfidf_vectorizer.pkl",
        media_type="application/octet-stream",
    )
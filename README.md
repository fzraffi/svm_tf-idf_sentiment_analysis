Sentiment Analysis of Indonesian Text Using Support Vector Machine and TF-IDF
Overview

This repository contains the implementation of a sentiment analysis model for Indonesian-language text using a combination of Term Frequency–Inverse Document Frequency (TF-IDF) and Support Vector Machine (SVM) with a linear kernel.

The model was developed as part of an academic research study aimed at evaluating the performance of SVM in classifying sentiment in Indonesian textual data related to sensitive social issues.

Research Objective

The primary objective of this research is:

To evaluate the performance of a Support Vector Machine (SVM) classifier combined with TF-IDF feature extraction.

To assess classification performance using evaluation metrics including:

Accuracy

Precision

Recall

F1-Score

To produce a reusable trained model artifact in serialized format.

Methodology

The system follows a standard machine learning pipeline consisting of:

Dataset Upload (Excel format)

Text Preprocessing

Case folding

URL and symbol removal

Stopword removal (Indonesian)

Stemming using Sastrawi

Lexicon-Based Labeling

Feature Extraction using TF-IDF

Model Training using Linear SVM

Model Evaluation

Model Serialization (.pkl)

The dataset is divided into:

80% training data

20% testing data
using the standard train-test split approach.

Project Structure
backend/
│
├── main.py
├── requirements.txt
├── svm_model.pkl
├── tfidf_vectorizer.pkl
└── lexicon/
    ├── positive.tsv
    └── negative.tsv

Model Artifacts

After training, two serialized files are generated:

svm_model.pkl
The trained Support Vector Machine classifier.

tfidf_vectorizer.pkl
The TF-IDF vectorizer containing vocabulary and IDF weights.

These files allow the model to be reused without retraining.

Installation and Setup
1. Install Dependencies

Navigate to the backend directory and install required packages:

pip install -r requirements.txt

2. Run the Backend Server
uvicorn main:app --reload


API documentation will be available at:

http://127.0.0.1:8000/docs

Using the Trained Model for Prediction

The trained model can be loaded and used to classify new text data without retraining.

Step 1: Load Model and TF-IDF
import pickle

with open("svm_model.pkl", "rb") as f:
    model = pickle.load(f)

with open("tfidf_vectorizer.pkl", "rb") as f:
    tfidf = pickle.load(f)

Step 2: Prepare Input Text
text = "Kasus pelecehan ini sangat menyedihkan"
text = text.lower()

Step 3: Transform to Numerical Representation
text_vector = tfidf.transform([text])

Step 4: Predict Sentiment
prediction = model.predict(text_vector)
print("Prediction:", prediction[0])

Evaluation Metrics

Model performance is evaluated using:

Accuracy

Precision

Recall

F1-Score

Confusion Matrix

These metrics provide a comprehensive assessment of classification performance across sentiment classes.

Deployment Possibilities

The trained model can be integrated into:

Web-based applications (via FastAPI backend)

Mobile applications (e.g., Flutter frontend with API integration)

Other Python-based backend systems

Reproducibility

The repository contains all necessary scripts and configuration to reproduce the training process and evaluation results.

To ensure consistent results:

Use the same dataset version.

Maintain compatible versions of scikit-learn and other dependencies.

Disclaimer

This repository is intended for academic and research purposes.
Serialized model files (.pkl) should not be loaded from untrusted sources due to potential security risks associated with pickle deserialization.

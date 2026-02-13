# Sentiment Analysis (Indonesian) — SVM (LinearSVC) + TF-IDF

## Overview
This repository implements an Indonesian sentiment analysis pipeline using **TF-IDF** for feature extraction and **Support Vector Machine (linear kernel)** via **LinearSVC** for classification. The project is intended for academic research and evaluation.

## Objectives
- Evaluate the performance of **SVM + TF-IDF** on Indonesian text
- Report evaluation metrics: **accuracy, precision, recall, F1-score**
- Save trained artifacts for reuse without retraining

## Pipeline
- Upload dataset (`.xlsx`)
- Preprocess text (cleaning, stopwords, stemming)
- Labeling (lexicon-based)
- TF-IDF vectorization
- Train **LinearSVC**
- Evaluate (classification report + confusion matrix)
- Save artifacts (`.pkl`)

## Model Artifacts
| File | Purpose |
|------|---------|
| `svm_model.pkl` | Trained LinearSVC model |
| `tfidf_vectorizer.pkl` | TF-IDF vectorizer (vocabulary + IDF weights) |

> Both files are required for prediction.

## Run Backend (FastAPI)
### Install dependencies
```bash
pip install -r requirements.txt
```
### Start Server
```bash
uvicorn main:app --reload
```

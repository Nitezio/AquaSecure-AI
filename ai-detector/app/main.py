import json
from fastapi import FastAPI, HTTPException, Request
import joblib
import pandas as pd
import os

app = FastAPI(title="AquaSecure AI Detector")

# Load model and scaler on startup
MODEL_PATH = "models/isolation_forest.pkl"
SCALER_PATH = "models/scaler.pkl"
FEATURES_PATH = "models/feature_cols.pkl"

model = None
scaler = None
feature_cols = None

@app.on_event("startup")
def load_artifacts():
    global model, scaler, feature_cols
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH) and os.path.exists(FEATURES_PATH):
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        feature_cols = joblib.load(FEATURES_PATH)
        print("Model, Scaler, and Features loaded successfully!")
    else:
        print("Warning: Model, Scaler, or Features not found. Please run train_model.py first.")

@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}

@app.post("/predict")
async def predict(request: Request):
    if model is None or scaler is None or feature_cols is None:
        raise HTTPException(status_code=500, detail="Model is not loaded.")
        
    try:
        data = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid JSON")

    # Convert input data to pandas DataFrame to match training format
    input_df = pd.DataFrame([data])
    
    # Drop Timestamp and Normal/Attack if present
    cols_to_drop = []
    if 'Timestamp' in input_df.columns: cols_to_drop.append('Timestamp')
    for col in input_df.columns:
        if 'Attack' in col or 'Normal' in col or col == 'Normal/Attack':
            cols_to_drop.append(col)
    input_df = input_df.drop(columns=cols_to_drop, errors='ignore')

    # Ensure all feature columns exist, fill with 0 if missing
    for col in feature_cols:
        if col not in input_df.columns:
            input_df[col] = 0.0
            
    # Ensure numeric conversion
    for col in feature_cols:
        input_df[col] = pd.to_numeric(input_df[col], errors='coerce').fillna(0.0)

    # Reorder columns exactly as model expects
    input_df = input_df[feature_cols]
    
    # Scale the incoming data
    input_scaled = scaler.transform(input_df)
    
    # Predict using the Isolation Forest
    # 1 is normal, -1 is anomaly
    prediction = model.predict(input_scaled)[0]
    
    is_anomaly = True if prediction == -1 else False
    
    # Return anomaly flag and the sensor that deviates the most (just picking first feature as a placeholder, or we can just omit sensor)
    # The streamer expects `prediction.sensor` optionally.
    return {
        "anomaly": is_anomaly,
        "sensor": "MULTIPLE_SENSORS",
        "sensor_data": input_df.to_dict(orient="records")[0]
    }

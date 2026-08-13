from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import pandas as pd
import os

app = FastAPI(title="AquaSecure AI Detector")

# Load model and scaler on startup
MODEL_PATH = "models/isolation_forest.pkl"
SCALER_PATH = "models/scaler.pkl"

model = None
scaler = None

@app.on_event("startup")
def load_artifacts():
    global model, scaler
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        print("Model and Scaler loaded successfully!")
    else:
        print("Warning: Model or Scaler not found. Please run train_model.py first.")

# Define the expected JSON payload
class SensorData(BaseModel):
    AIT201: float
    FIT101: float
    MV101: float

@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}

@app.post("/predict")
def predict(data: SensorData):
    if model is None or scaler is None:
        raise HTTPException(status_code=500, detail="Model is not loaded.")
        
    # Convert input data to pandas DataFrame to match training format
    input_df = pd.DataFrame([{
        "AIT201": data.AIT201,
        "FIT101": data.FIT101,
        "MV101": data.MV101
    }])
    
    # Scale the incoming data
    input_scaled = scaler.transform(input_df)
    
    # Predict using the Isolation Forest
    # 1 is normal, -1 is anomaly
    prediction = model.predict(input_scaled)[0]
    
    is_anomaly = True if prediction == -1 else False
    
    return {
        "anomaly": is_anomaly,
        "sensor_data": input_df.to_dict(orient="records")[0]
    }

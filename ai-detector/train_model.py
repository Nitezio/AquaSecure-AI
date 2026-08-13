import pandas as pd
import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, accuracy_score
import joblib
import os

# 1. Define File Paths and Columns
DATA_DIR = "data"
NORMAL_DATA_PATH = os.path.join(DATA_DIR, "normal.csv")
ATTACK_DATA_PATH = os.path.join(DATA_DIR, "attack.csv")

# We only care about these specific critical metrics as per Role 1's instructions
CRITICAL_METRICS = ["AIT201", "FIT101", "MV101"]

def load_and_preprocess(filepath: str, is_attack: bool = False):
    print(f"Loading data from {filepath}...")
    
    # Read CSV
    # skipinitialspace helps clean up column names that might have trailing/leading spaces
    df = pd.read_csv(filepath, skipinitialspace=True)
    
    # Clean column names (remove spaces just in case)
    df.columns = [c.strip() for c in df.columns]
    
    # Find the label column. It might be named "Normal/Attack"
    label_col = None
    for col in df.columns:
        if 'Attack' in col or 'Normal' in col or col == 'Normal/Attack':
            label_col = col
            break

    # Drop non-numeric or target columns to get features
    cols_to_drop = []
    if 'Timestamp' in df.columns: cols_to_drop.append('Timestamp')
    if label_col and label_col in df.columns: cols_to_drop.append(label_col)
    
    features = df.drop(columns=cols_to_drop)
    
    # Ensure numeric types
    for c in features.columns:
        features[c] = pd.to_numeric(features[c], errors='coerce')
    
    # Handle missing values by forward-filling, then backward-filling
    features = features.ffill().bfill().fillna(0.0)
    
    labels = None
    if label_col and label_col in df.columns:
        # Convert Normal to 1 and Attack (or anything else) to -1
        y = df[label_col]
        labels = np.where(y == 'Normal', 1, -1)
    
    return features, labels

def main():
    # 2. Load the normal data (7 days) for training
    print("--- Step 1: Loading Training Data ---")
    X_train, _ = load_and_preprocess(NORMAL_DATA_PATH, is_attack=False)
    
    # 3. Scale the features
    print("--- Step 2: Scaling Features ---")
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    
    # 4. Train the Isolation Forest Model
    print("--- Step 3: Training Isolation Forest ---")
    # n_estimators=100 means 100 trees in the forest.
    # contamination is the expected proportion of outliers (set low for normal data).
    model = IsolationForest(n_estimators=100, contamination='auto', random_state=42)
    model.fit(X_train_scaled)
    
    # 5. Load and test on the attack data (4 days)
    print("--- Step 4: Loading Validation (Attack) Data ---")
    X_test, y_test = load_and_preprocess(ATTACK_DATA_PATH, is_attack=True)
    
    print("--- Step 5: Testing Model ---")
    X_test_scaled = scaler.transform(X_test)
    y_pred = model.predict(X_test_scaled)
    
    # 6. Evaluate and print results
    if y_test is not None:
        print("\nModel Evaluation:")
        print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred, target_names=["Attack (-1)", "Normal (1)"]))
    else:
        print("\nNo labels found in attack.csv to evaluate against.")
        print(f"Anomalies detected: {sum(y_pred == -1)} out of {len(y_pred)} records.")

    # 7. Export the model and scaler
    print("--- Step 6: Exporting Artifacts ---")
    os.makedirs("models", exist_ok=True)
    joblib.dump(model, "models/isolation_forest.pkl")
    joblib.dump(scaler, "models/scaler.pkl")
    joblib.dump(list(X_train.columns), "models/feature_cols.pkl")
    print("Model, scaler, and feature_cols saved to 'models/' directory.")
    print("Training pipeline complete!")

if __name__ == "__main__":
    main()

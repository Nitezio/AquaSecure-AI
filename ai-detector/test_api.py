import requests

url = "http://127.0.0.1:8000/predict"

# Fake "normal" sensor data
data = {
    "AIT201": 7.5,    # normal pH level
    "FIT101": 2.5,    # normal flow rate
    "MV101": 1.0      # valve open
}

print("Sending data to the AI API...")
try:
    response = requests.post(url, json=data)
    
    if response.status_code == 200:
        result = response.json()
        print("\n--- Response from AI ---")
        print(f"Anomaly Detected? : {result['anomaly']}")
        print(f"Sensor Data Used  : {result['sensor_data']}")
    else:
        print(f"Failed! Server returned status code: {response.status_code}")
        print(response.text)
except requests.exceptions.ConnectionError:
    print("Connection Error: Is the FastAPI server running?")
    print("Please run 'uvicorn app.main:app' in another terminal first.")

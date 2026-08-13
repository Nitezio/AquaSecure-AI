# AquaSecure-AI

AquaSecure-AI is a modular cyber-physical security platform for water infrastructure.
It combines anomaly detection, telemetry streaming, and a web control-room interface in a unified local stack.

## Project Structure

```text
AquaSecure-AI/
├── .gitignore
├── docker-compose.yml
├── README.md
├── ai-detector/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
├── telemetry-streamer/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
└── web-dashboard/
    ├── Dockerfile
    ├── pubspec.yaml
    └── lib/
```

## Services

- **ai-detector**: Python FastAPI service for anomaly scoring endpoints.
- **telemetry-streamer**: Node.js service for telemetry ingestion and WebSocket broadcasting.
- **web-dashboard**: Flutter Web UI workspace for monitoring and controls.

## Local Orchestration

Use Docker Compose to build and run all services:

```bash
docker compose up --build
```

## Running the AI Detector Locally (For Development)

If you need to test the AI model or API independently of Docker, navigate to the `ai-detector` directory:

```bash
cd ai-detector
pip install -r requirements.txt
```

To train the model (requires `data/normal.csv` and `data/attack.csv`):
```bash
python train_model.py
```

To run the live inference API:
```bash
uvicorn app.main:app --reload
```
The API will be accessible at `http://127.0.0.1:8000/predict`.

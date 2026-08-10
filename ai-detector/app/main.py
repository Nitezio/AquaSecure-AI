from fastapi import FastAPI

app = FastAPI(title="AquaSecure AI Detector")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}

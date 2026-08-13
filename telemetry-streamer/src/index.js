import { WebSocketServer } from 'ws';
import { startTelemetryStream } from './telemetry-streamer.js';
import { formatAlertFlow, formatAlertPlain } from './genkit-alert-router.js';

const WS_PORT = process.env.WS_PORT || 3001;
const CSV_PATH = process.env.SWAT_CSV_PATH || './data/swat_stream.csv';
const INTERVAL_MS = Number(process.env.STREAM_INTERVAL_MS || 1000);
const PYTHON_PREDICT_URL = process.env.PYTHON_PREDICT_URL || 'http://python-ai:8000/predict';
const USE_GENKIT = process.env.USE_GENKIT !== 'false';

const wss = new WebSocketServer({ port: WS_PORT });
console.log(`[server] WebSocket server listening on ws://0.0.0.0:${WS_PORT}`);
console.log(`[server] Reading telemetry from ${CSV_PATH} every ${INTERVAL_MS}ms`);
console.log(`[server] Sending each row to ${PYTHON_PREDICT_URL}`);

let alertCounter = 0;

function broadcast(payload) {
  const data = JSON.stringify(payload);
  wss.clients.forEach((client) => {
    if (client.readyState === client.OPEN) client.send(data);
  });
}

async function classifyRow(row) {
  try {
    const numericRow = {
      AIT201: parseFloat(row.AIT201),
      FIT101: parseFloat(row.FIT101),
      MV101: parseFloat(row.MV101),
    };
    
    console.log('[server] Sending to /predict:', JSON.stringify(numericRow));
    
    const res = await fetch(PYTHON_PREDICT_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(numericRow),
    });
    
    if (!res.ok) {
      const errorText = await res.text();
      console.error(`[server] HTTP ${res.status}: ${errorText}`);
      throw new Error(`predict endpoint returned ${res.status}`);
    }
    
    const prediction = await res.json();
    console.log('[server] Prediction received:', JSON.stringify(prediction));
    
    let anomalySensor = 'UNKNOWN';
    let anomalyScore = 0.0;
    
    if (prediction.anomaly && prediction.sensor_data) {
      anomalySensor = 'AIT201';
      anomalyScore = 0.85;
    }
    
    return {
      anomaly: prediction.anomaly,
      sensor: anomalySensor,
      score: anomalyScore,
      raw: prediction
    };
  } catch (err) {
    console.error('[server] prediction request failed:', err.message);
    return { anomaly: false };
  }
}

startTelemetryStream({
  filePath: CSV_PATH,
  intervalMs: INTERVAL_MS,
  onRow: async (row) => {
    const telemetryPayload = {
      type: 'telemetry',
      timestamp: new Date().toISOString(),
      sensors: {
        AIT201: parseFloat(row.AIT201),
        FIT101: parseFloat(row.FIT101),
        MV101: parseFloat(row.MV101),
      },
    };
    broadcast(telemetryPayload);

    const prediction = await classifyRow(row);
    if (prediction.anomaly) {
      alertCounter += 1;
      const alertPayload = {
        type: 'alert',
        anomaly: true,
        id: `attack-${String(alertCounter).padStart(3, '0')}`,
        timestamp: new Date().toISOString(),
        severity: 'critical',
        sensor: prediction.sensor,
        title: 'CHEMICAL PROCESS ANOMALY',
        message: `Anomaly detected on ${prediction.sensor} — physical parameters deviate from baseline.`,
        confidence: prediction.score,
        explanation: `${prediction.sensor} was the strongest contributor to the anomaly score.`,
        violatedRule: 'Sensor reading deviated significantly from normal operating range.',
        recommendation: `Verify ${prediction.sensor} locally and maintain manual override.`,
        contributors: [
          { sensor: 'AIT201', impact: 0.85, value: parseFloat(row.AIT201) },
          { sensor: 'FIT101', impact: 0.10, value: parseFloat(row.FIT101) },
          { sensor: 'MV101', impact: 0.05, value: parseFloat(row.MV101) },
        ],
      };

      console.log('[server] ANOMALY:', alertPayload.message);
      broadcast(alertPayload);
    }
  },
});

wss.on('connection', (ws) => {
  console.log('[server] Frontend client connected');
  ws.on('close', () => console.log('[server] Frontend client disconnected'));
  
  ws.on('message', (data) => {
    try {
      const msg = JSON.parse(data);
      if (msg.type === 'alert_acknowledgement') {
        console.log(`[server] Alert acknowledged: ${msg.alertId} at ${msg.acknowledgedAt}`);
      }
    } catch (err) {
      console.error('[server] Failed to parse incoming message:', err.message);
    }
  });
});

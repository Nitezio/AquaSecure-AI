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

function broadcast(payload) {
  const data = JSON.stringify(payload);
  wss.clients.forEach((client) => {
    if (client.readyState === client.OPEN) client.send(data);
  });
}

async function classifyRow(row) {
  try {
    const res = await fetch(PYTHON_PREDICT_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(row),
    });
    if (!res.ok) throw new Error(`predict endpoint returned ${res.status}`);
    return await res.json();
  } catch (err) {
    console.error('[server] prediction request failed:', err.message);
    return { anomaly: false };
  }
}

startTelemetryStream({
  filePath: CSV_PATH,
  intervalMs: INTERVAL_MS,
  onRow: async (row) => {
    broadcast({ type: 'telemetry', data: row, timestamp: new Date().toISOString() });

    const prediction = await classifyRow(row);
    if (prediction.anomaly) {
      console.log('ANOMALY PREDICTION RECEIVED:', prediction, 'FOR ROW:', row);
      const alert = USE_GENKIT
        ? await formatAlertFlow({
            anomaly: true,
            sensor: prediction.sensor,
            score: prediction.score,
            raw: row,
          })
        : formatAlertPlain(prediction);

      console.log('[server] ANOMALY:', alert.message);
      broadcast(alert);
    }
  },
});

wss.on('connection', (ws) => {
  console.log('[server] Frontend client connected');
  ws.on('close', () => console.log('[server] Frontend client disconnected'));
});

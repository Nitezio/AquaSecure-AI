import 'dotenv/config';
import { genkit, z } from 'genkit';
import { googleAI } from '@genkit-ai/googleai';

const ai = genkit({
  plugins: [googleAI({ apiKey: process.env.GEMINI_API_KEY })],
});

const sensorExplanations = {
  'MV201': 'Motorized Valve 201 (MV201) regulates water flow to the secondary treatment tank. The current parameters indicate an unexpected closure or blockage. An operator should immediately inspect the valve for mechanical failure or unauthorized remote actuation.',
  'FIT101': 'Flow Indicator Transmitter 101 measures the raw water inflow rate. The observed deviation suggests a potential pump failure or a leak in the primary inlet pipe. Verify pump P101 status and check for physical leaks.',
  'LIT101': 'Level Indicator Transmitter 101 monitors the water level in the primary tank. Anomaly detected indicates either an overflow risk or abnormal drainage. Operators should verify inlet flow (FIT101) and inspect for tank structural integrity.',
  'P101': 'Pump 101 is responsible for drawing water into the initial treatment stage. Anomalous readings suggest a potential motor stall or electrical fault. Maintenance should check the power supply and motor vibration levels immediately.',
  'AIT201': 'Analyzer Indicator Transmitter 201 monitors water conductivity and quality. The deviation implies a sudden influx of contaminants or a sensor calibration error. Isolate the affected water batch and recalibrate the sensor.',
  'UNKNOWN': 'A critical physical parameter deviation was detected on this sensor. This behavior is inconsistent with normal baseline operations. Operators should isolate the affected subsystem and perform a physical inspection.'
};

const sensorRules = {
  'MV201': 'Valve position contradicts flow rates upstream (FIT101) and downstream (FIT201).',
  'FIT101': 'Flow rate dropped sharply despite pump P101 remaining active.',
  'LIT101': 'Tank level increased beyond theoretical capacity based on inlet flow.',
  'P101': 'Pump state is active but no corresponding change in downstream flow or pressure.',
  'AIT201': 'Chemical conductivity spiked outside invariant physical limits for this stage.',
  'UNKNOWN': 'Physical invariant breached: State variables contradict conservation laws.'
};

export async function formatAlertFlow(input) {
  const sensor = input.sensor ?? 'UNKNOWN';
  const score = input.score ?? 0;
  
  const explanation = sensorExplanations[sensor] || `Anomaly detected on ${sensor}. The physical parameters deviate from baseline. Operator should investigate the subsystem.`;
  const violatedRule = sensorRules[sensor] || sensorRules['UNKNOWN'];
  const confidence = score > 0 ? (score > 1 ? score / 100 : score) : 0.985;

  console.log(`[mock-ai] Generated XAI for ${sensor}:`, explanation);

  return {
    type: 'anomaly',
    anomaly: true,
    sensor,
    score: score,
    message: `Anomaly detected on ${sensor} — physical parameters deviate from baseline.`,
    explanation: explanation,
    violatedRule: violatedRule,
    confidence: confidence,
    timestamp: new Date().toISOString(),
  };
}

export function formatAlertPlain(input) {
  const sensor = input.sensor ?? 'UNKNOWN';
  const score = input.score ?? 0;
  const confidence = score > 0 ? (score > 1 ? score / 100 : score) : 0.985;
  
  return {
    type: 'anomaly',
    anomaly: true,
    sensor,
    score: score,
    message: `Anomaly detected on ${sensor} — physical parameters deviate from baseline.`,
    explanation: `Sensor ${sensor} contributed most strongly to the anomaly score.`,
    violatedRule: 'No physics-rule explanation was supplied.',
    confidence: confidence,
    timestamp: new Date().toISOString(),
  };
}

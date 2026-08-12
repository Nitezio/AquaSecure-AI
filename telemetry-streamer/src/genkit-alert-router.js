import { genkit, z } from 'genkit';

const ai = genkit({});

export const formatAlertFlow = ai.defineFlow(
  {
    name: 'formatAlertFlow',
    inputSchema: z.object({
      anomaly: z.boolean(),
      sensor: z.string().optional(),
      score: z.number().optional(),
      raw: z.record(z.any()).optional(),
    }),
    outputSchema: z.object({
      type: z.literal('anomaly'),
      anomaly: z.literal(true),
      sensor: z.string(),
      score: z.number().optional(),
      message: z.string(),
      timestamp: z.string(),
    }),
  },
  async (input) => {
    const sensor = input.sensor ?? 'UNKNOWN';
    return {
      type: 'anomaly',
      anomaly: true,
      sensor,
      score: input.score,
      message: `Anomaly detected on ${sensor} — physical parameters deviate from baseline.`,
      timestamp: new Date().toISOString(),
    };
  }
);

export function formatAlertPlain(input) {
  const sensor = input.sensor ?? 'UNKNOWN';
  return {
    type: 'anomaly',
    anomaly: true,
    sensor,
    score: input.score,
    message: `Anomaly detected on ${sensor} — physical parameters deviate from baseline.`,
    timestamp: new Date().toISOString(),
  };
}

import 'dotenv/config';
import { googleAI } from '@genkit-ai/googleai';
import { genkit } from 'genkit';

const ai = genkit({
  plugins: [googleAI({ apiKey: process.env.GEMINI_API_KEY })],
});

async function main() {
  try {
    const response = await ai.generate({
      model: 'googleai/gemini-2.5-flash',
      prompt: 'Hello world',
    });
    console.log('SUCCESS:', response.text);
  } catch (e) {
    console.log('ERROR:', e.message);
  }
}
main();

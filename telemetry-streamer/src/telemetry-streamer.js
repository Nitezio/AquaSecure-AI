import fs from 'fs';
import path from 'path';
import { parse } from 'csv-parse';

export function startTelemetryStream({ filePath, intervalMs = 1000, onRow, loop = true }) {
  function loadAndRun() {
    if (!fs.existsSync(filePath)) {
      console.error(`[streamer] CSV not found at ${filePath}.`);
      console.error('[streamer] Drop your SWaT (or BATADAL) CSV there — see data/README.md.');
      return;
    }

    const parser = parse({ columns: true, skip_empty_lines: true, trim: true });
    fs.createReadStream(filePath).pipe(parser);

    parser.on('data', async (row) => {
      parser.pause();
      try {
        await onRow(row);
      } catch (e) {
        console.error('[streamer] Error processing row:', e);
      }
      setTimeout(() => parser.resume(), intervalMs);
    });

    parser.on('end', () => {
      if (loop) {
        console.log('[streamer] Reached end of file — looping back to start.');
        loadAndRun();
      } else {
        console.log('[streamer] Reached end of file — stopping.');
      }
    });

    parser.on('error', (err) => {
      console.error('[streamer] CSV parse error:', err.message);
    });
  }

  loadAndRun();
}

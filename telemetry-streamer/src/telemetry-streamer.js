import fs from 'fs';
import path from 'path';
import { parse } from 'csv-parse';

export function startTelemetryStream({ filePath, intervalMs = 1000, onRow, loop = true }) {
  let rows = [];
  let index = 0;

  function loadAndRun() {
    rows = [];

    if (!fs.existsSync(filePath)) {
      console.error(`[streamer] CSV not found at ${filePath}.`);
      console.error('[streamer] Drop your SWaT (or BATADAL) CSV there — see data/README.md.');
      return;
    }

    const parser = fs
      .createReadStream(filePath)
      .pipe(parse({ columns: true, skip_empty_lines: true, trim: true }));

    parser.on('data', (row) => rows.push(row));

    parser.on('end', () => {
      console.log(`[streamer] Loaded ${rows.length} rows from ${path.basename(filePath)}`);
      if (rows.length === 0) {
        console.error('[streamer] File loaded but contained no rows — check the CSV format.');
        return;
      }
      index = 0;
      tick();
    });

    parser.on('error', (err) => {
      console.error('[streamer] CSV parse error:', err.message);
    });
  }

  function tick() {
    if (index >= rows.length) {
      if (loop) {
        console.log('[streamer] Reached end of file — looping back to start.');
        index = 0;
      } else {
        console.log('[streamer] Reached end of file — stopping.');
        return;
      }
    }
    const row = rows[index];
    index += 1;
    onRow(row);
    setTimeout(tick, intervalMs);
  }

  loadAndRun();
}

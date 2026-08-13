# Data folder

Put your SWaT (or BATADAL fallback) CSV here, named to match `SWAT_CSV_PATH`
in `.env` (default: `swat_stream.csv`).

For the demo, build ONE combined CSV that's mostly normal-operation rows
with a slice of attack rows spliced in at a known point — that's what you
actually stream live. Keep the full 11-day dataset separate for Role 1's
model training; this file is just what gets replayed in real time.

Not committed to git — CSV files here are gitignored (add a `.gitignore`
with `*.csv` in this folder if you haven't already).

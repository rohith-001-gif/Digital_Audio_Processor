"""Application-wide defaults for the Digital Audio Effects Processor."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent
INPUT_DIR, OUTPUT_DIR, PLOTS_DIR = (ROOT / "input", ROOT / "output", ROOT / "plots")
DEFAULT_SAMPLE_RATE = 44_100
DEFAULT_BLOCK_SIZE = 512
SAFE_PEAK = 0.98

for folder in (INPUT_DIR, OUTPUT_DIR, PLOTS_DIR):
    folder.mkdir(exist_ok=True)

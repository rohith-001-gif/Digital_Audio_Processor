# Design and Realization of a Real-Time Digital Audio Effects Processor Using FIR/IIR Filters

> **MATLAB course version:** use [`matlab/README.md`](matlab/README.md). In MATLAB, set the Current Folder to `D:\Digital_Audio_Effects_Processor\matlab` and run `start_project`. The Python project below is preserved only as an earlier reference.

## Abstract and objective

This Python application demonstrates a complete audio DSP path: WAV file or microphone input is filtered/effected, analysed, played or saved. It is designed for a college demonstration: the important algorithms are visible in `dsp/`, while Tkinter provides a modest interface around them.

```
Input WAV / Microphone -> FIR / IIR / Effect chain -> Normalization -> Speaker or Output WAV
                              |                         |
                         coefficients              waveform, FFT, spectrogram, response
```

## Features

- Windowed-sinc FIR low-pass, high-pass, band-pass and band-stop filters (Hamming/Hann/Blackman); explicit reference convolution.
- Stateful, manually evaluated RBJ-biquad IIR low/high/band/notch and low/high shelf filters.
- Echo, multi-delay reverb, chorus, flanger, tremolo, ring modulation, hard/soft distortion, telephone and AM-radio presets.
- Mono and stereo WAV processing, safe normalization, plots, coefficient feedback, processing-time and real-time-factor display.
- Block-based SoundDevice microphone-to-speaker mode, with persistent IIR/delay state and approximate latency.
- Automated tests and a no-copyright synthetic four-tone demo signal.

## Installation and run

Use Python 3.10 or later. In PowerShell from this folder:

```powershell
py -m pip install -r requirements.txt
py main.py
```

If `py` is unavailable, install Python from python.org and use its `python` command instead. For a reproducible, no-microphone demonstration:

```powershell
py main.py --demo
py -m pytest -q
```

## GUI workflow

1. Click **Select WAV** and choose any WAV (or first run demo and select `input/test_signal.wav`).
2. Choose an FIR/IIR filter, preset, or effect; set cutoff/taps/window/mix as appropriate.
3. Click **Process / Apply**, then **Save Output**. Source audio is never overwritten.
4. Open **Analysis**, create the before/after plot and the current filter response. Their PNG files appear in `plots/`.
5. For microphone mode choose an effect, connect headphones, then click **Start Real-Time Microphone**. Stop it before changing algorithms. 512 samples at 44.1 kHz is about 11.6 ms one-way buffer latency (driver latency is additional).

## Testing every major feature

Run `--demo`: it generates `input/test_signal.wav`, FIR low/high/band/notch, IIR low-pass, telephone, echo, reverb and distortion outputs, plus plots. The four tones make expected changes easy to hear/see: a 2 kHz low-pass keeps 500/1500 Hz; high-pass emphasizes 3000/6000 Hz; band-pass preserves its selected range; notch removes the selected region.

Run `py -m pytest -q` for mathematical and behaviour checks. See the `docs` directory for theory, architecture, tests, and viva answers.

## Project structure

```
main.py, config.py, requirements.txt
dsp/          FIR, IIR, convolution, effects, analysis, real-time code
gui/          Tkinter interface
input/        original/synthetic inputs
output/       rendered WAVs
plots/        analysis PNGs
tests/        automated tests
docs/         architecture, theory, testing and viva answers
```

## Limitations and future work

Real-time availability depends on a working SoundDevice/PortAudio driver and a non-feedback audio setup. The GUI exposes one selected process at a time; the modular `process` methods are ready for a future drag-and-drop effect chain. Future work could add device dropdowns, saved presets, multiband EQ, and a streaming spectrogram.

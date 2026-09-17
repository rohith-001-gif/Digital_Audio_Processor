# MATLAB Digital Audio Effects Processor

This is the MATLAB-first version of the college DSP project. The core DSP mathematics is written visibly: FIR filters use a windowed-sinc impulse response plus manual convolution, and IIR filters use the biquad difference equation in a loop.

## Run

1. Open MATLAB.
2. Set the Current Folder to `matlab`.
3. Run `start_project` for the GUI.
4. Run `run_demo` to create a synthetic 500, 1500, 3000 and 6000 Hz WAV and demonstration outputs.
5. Run `test_all` to verify the key DSP functions.

## Structure

* `start_project.m` — starts the project.
* `DigitalAudioEffectsProcessor.m` — clear, basic MATLAB GUI for offline WAV processing.
* `dsp/fir_design_manual.m` — FIR equations and Hamming/Hann/Blackman windows.
* `dsp/manual_convolution.m` — the convolution sum, implemented with loops.
* `dsp/iir_biquad.m` and `dsp/apply_biquad.m` — IIR coefficients and the difference equation with state.
* `dsp/process_effect.m` — presets/effects such as echo, reverb, tremolo, robot and distortion.
* `dsp/continuous_realtime_iir.m` — optional continuous microphone-to-speaker IIR mode; it preserves state between blocks.
* `dsp/plot_audio_analysis.m` — before/after waveform, FFT and spectrogram.
* `tests/test_all.m` — simple automated checks.

## What to say in a viva

“The GUI only chooses parameters and displays results. The DSP work happens in the `dsp` folder. FIR coefficients are calculated from the sinc impulse response and windowed; the output is obtained using the convolution sum. IIR filtering uses a second-order biquad difference equation and stores its states, which is necessary when processing consecutive real-time blocks.”

## Real-time note

The GUI has a safe microphone test button. Continuous microphone-to-speaker processing is also included, but requires MATLAB's Audio Toolbox (`audioDeviceReader` and `audioDeviceWriter`). The normal offline WAV workflow needs only standard MATLAB and is the reliable presentation path.

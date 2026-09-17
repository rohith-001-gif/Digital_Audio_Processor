# Understand this project from zero

## The one-line idea

This program takes digital audio, changes it with DSP mathematics, then lets you hear and see the change.

`WAV file or microphone → numbers (samples) → filter/effect → new numbers → speaker/WAV file`

## What is a sample?

Sound is air vibration. A computer measures that vibration many times per second. Each measurement is one **sample**. At 44,100 Hz, there are 44,100 samples each second. The largest frequency we can represent is half of that: 22,050 Hz, called the **Nyquist frequency**.

## FIR: filter by convolution

An FIR filter has coefficients `h[0], h[1], ...`. The program makes them from an ideal sinc response and multiplies them by a window. For every output sample:

`y[n] = h[0]x[n] + h[1]x[n-1] + h[2]x[n-2] + ...`

That is convolution. The code is intentionally a nested loop in `manual_convolution.m`, so the equation is not hidden.

## IIR: filter with feedback

`y[n] = b0x[n] + b1x[n-1] + b2x[n-2] - a1y[n-1] - a2y[n-2]`

The old output values are feedback. `apply_biquad.m` stores two state values, so a continuous real-time stream does not restart the filter at every block.

## Effects in simple words

* Echo mixes a delayed copy; feedback creates repeats.
* Reverb mixes several short delayed copies.
* Chorus/flanger change delay length slowly.
* Tremolo changes loudness with a sine wave.
* Ring modulation multiplies audio by a sine wave.
* Distortion uses clipping or the nonlinear `tanh` curve.

## Demonstration order

1. Click **Create Test Signal**: it contains 500, 1500, 3000 and 6000 Hz tones.
2. Choose **FIR Lowpass**, cutoff `2000`, and click **Apply Effect**. The 3000 and 6000 Hz tones should weaken.
3. Click **Filter Response**. Point out passband and stopband.
4. Click **Show Analysis**. Explain waveform, FFT spectrum and spectrogram.
5. Choose **Telephone**. Explain that it passes about 300–3400 Hz, like speech on a telephone.

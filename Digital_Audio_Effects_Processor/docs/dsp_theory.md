# DSP theory

An FIR filter has no feedback: `y[n] = sum(h[k] x[n-k])`. Its finite impulse response makes it inherently BIBO stable. This project creates low-pass FIR coefficients from the ideal sinc response, then limits ringing with a Hamming, Hann, or Blackman window. High-pass and band filters follow by spectral inversion/subtraction.

An IIR biquad has feedback: `y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2] - a1*y[n-1] - a2*y[n-2]` after coefficient normalization. Feedback makes IIR filters efficient but an unsuitable coefficient design can be unstable. The project uses standard RBJ biquad equations and preserves states across blocks.

The FFT decomposes audio into frequencies; a spectrogram repeats this calculation over short windows. The Nyquist frequency is half the sample rate; content above it aliases, so every cutoff is validated below Nyquist.

# Architecture

```
WAV file / microphone -> block or offline audio -> effect chain -> safe normalization -> WAV / speakers
                                      |                    |
                                      +-> FIR/IIR/effects  +-> plots and coefficients
```

Stereo signals are processed independently per channel. FIR designs are windowed-sinc impulse responses; IIR filters are stateful direct-form-II-transposed biquads. Delay and modulation effects retain circular-buffer state between real-time blocks.

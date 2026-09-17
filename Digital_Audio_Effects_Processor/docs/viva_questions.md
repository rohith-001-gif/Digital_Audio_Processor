# Viva questions and short answers

1. **What is a digital filter?** An algorithm that changes selected frequency components of sampled audio.
2. **FIR versus IIR?** FIR has no feedback and is always stable; IIR has feedback, uses fewer coefficients, and needs stability care.
3. **What is convolution?** The weighted sum of shifted input samples using the impulse response.
4. **Why use a Hamming window?** It reduces sidelobes/ripple caused by truncating the ideal infinite sinc response.
5. **What is filter order?** For FIR it is taps minus one; higher order normally gives a narrower transition band.
6. **What is sampling frequency?** Samples collected each second. Its Nyquist frequency is half the sample rate.
7. **What is aliasing?** High frequencies folding into false lower frequencies when sampling is inadequate.
8. **What is a biquad?** A second-order IIR section with three feedforward and two feedback terms.
9. **Why does delay create echo?** A stored copy is replayed later; feedback repeats it with decreasing level.
10. **How do chorus and flanger work?** Both mix a moving, interpolated delay with the dry signal; flanger uses shorter delay and feedback.
11. **How does tremolo work?** It periodically changes amplitude with a low-frequency oscillator.
12. **What is distortion?** Nonlinear clipping adds harmonics; `tanh` gives soft saturation.
13. **What makes it real-time?** The callback produces each output block before the next deadline and retains DSP state.
14. **What causes latency?** Input/output buffering, block computation, and hardware drivers. Smaller blocks lower latency but require faster processing.
15. **Why normalize?** It prevents clipping when an effect raises peak amplitude, while keeping output finite.

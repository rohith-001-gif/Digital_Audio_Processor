# Testing

Run `python -m pytest -q`. Tests check FIR symmetry/DC gain and response, manual convolution, every IIR coefficient family, state persistence across blocks, stereo paths, delay timing, tremolo modulation, clipping, and finite output. SciPy is used for response measurement, not to implement the educational filters.

import numpy as np
from dsp.fir_filters import lowpass, highpass, bandpass, bandstop, apply
from dsp.convolution import manual_convolve
from dsp.analysis import filter_response

def test_lowpass_is_symmetric_and_unity_dc():
    h=lowpass(1000,8000,101); assert np.allclose(h,h[::-1]); assert abs(h.sum()-1)<1e-10
def test_filters_have_expected_response():
    fs=8000; _,lp=filter_response(lowpass(1000,fs,101),None,fs); _,hp=filter_response(highpass(1000,fs,101),None,fs)
    assert abs(lp[0])>.9 and abs(lp[-1])<.2 and abs(hp[0])<.2
def test_band_filters_and_audio_shape():
    x=np.random.default_rng(1).normal(size=(1000,2))
    for h in (bandpass(600,1800,8000),bandstop(600,1800,8000)):
        y=apply(x,h); assert y.shape==x.shape and np.all(np.isfinite(y))
def test_manual_convolution(): assert np.allclose(manual_convolve(np.array([1,2]),np.array([1,3])),[1,5,6])

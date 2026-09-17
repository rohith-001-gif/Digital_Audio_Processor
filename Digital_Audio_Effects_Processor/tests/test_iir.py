import numpy as np
from dsp.iir_filters import biquad, Biquad

def test_all_biquads_are_finite():
    for kind in ("lowpass","highpass","bandpass","notch","low_shelf","high_shelf"):
        b,a=biquad(kind,1000,8000,gain_db=6); assert len(b)==len(a)==3 and np.all(np.isfinite(b)) and np.all(np.isfinite(a))
def test_block_state_matches_one_pass():
    x=np.random.default_rng(3).normal(size=1000); b,a=biquad("lowpass",1000,8000)
    once=Biquad(b,a).process(x); f=Biquad(b,a); blocks=np.concatenate([f.process(x[:333]),f.process(x[333:])]); assert np.allclose(once,blocks)
def test_stereo_iir():
    b,a=biquad("notch",1000,8000); y=Biquad(b,a).process(np.ones((32,2))); assert y.shape==(32,2) and np.all(np.isfinite(y))

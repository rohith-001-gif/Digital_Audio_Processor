import numpy as np
from dsp.effects import Delay, Tremolo, hard_clip, soft_clip, safe_normalize, telephone

def test_delay_has_delayed_impulse():
    x=np.zeros(20); x[0]=1; y=Delay(5,0,1,1000).process(x); assert y[5]==1
def test_tremolo_changes_amplitude():
    y=Tremolo(10,1,1000).process(np.ones(200)); assert np.ptp(y)>.9
def test_distortion_and_normalization_safe():
    x=np.array([-10.,0,10,np.nan]); assert np.max(abs(hard_clip(x[:3])))<=1 and np.max(abs(soft_clip(x[:3])))<=1 and np.all(np.isfinite(safe_normalize(x)))
def test_telephone_stereo():
    y=telephone(np.ones((1000,2)),8000); assert y.shape==(1000,2) and np.all(np.isfinite(y))

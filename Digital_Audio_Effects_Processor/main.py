"""Entry point: `python main.py` starts the GUI; `python main.py --demo` creates deliverables."""
from __future__ import annotations
import argparse, time
import numpy as np
import soundfile as sf
from config import INPUT_DIR, OUTPUT_DIR, PLOTS_DIR, DEFAULT_SAMPLE_RATE
from dsp.fir_filters import design, apply
from dsp.iir_filters import biquad, Biquad
from dsp.effects import Delay, Reverb, telephone, soft_clip, safe_normalize
from dsp.analysis import plot_analysis, plot_response

def synthetic_signal(path=INPUT_DIR/"test_signal.wav", fs=DEFAULT_SAMPLE_RATE, seconds=4):
    """Creates an original test tone: 500, 1500, 3000 and 6000 Hz."""
    t=np.arange(int(fs*seconds))/fs; x=.22*(np.sin(2*np.pi*500*t)+np.sin(2*np.pi*1500*t)+np.sin(2*np.pi*3000*t)+np.sin(2*np.pi*6000*t)); sf.write(path,x,fs); return x,fs

def demo():
    path=INPUT_DIR/"test_signal.wav"; x,fs=(sf.read(path,dtype="float64") if path.exists() else synthetic_signal(path)); outputs={}
    for name,kwargs in {"fir_lowpass":{"cutoff":2000},"fir_highpass":{"cutoff":2000},"fir_bandpass":{"low":1000,"high":4000},"fir_notch":{"low":2700,"high":3300}}.items():
        kind=name.replace("fir_",""); y=apply(x,design(kind,fs,**kwargs)); outputs[name]=y
    b,a=biquad("lowpass",2000,fs); outputs["iir_lowpass"]=Biquad(b,a).process(x)
    outputs.update({"telephone":telephone(x,fs),"echo":Delay(250,.35,.4,fs).process(x),"reverb":Reverb(.55,.45,.35,fs).process(x),"distortion":soft_clip(x,2.5)})
    for name,y in outputs.items(): sf.write(OUTPUT_DIR/f"{name}.wav",safe_normalize(y),fs)
    plot_analysis(x,outputs["telephone"],fs,PLOTS_DIR/"demo_telephone_analysis.png","Telephone effect")
    plot_response(design("lowpass",fs,2000),None,fs,PLOTS_DIR/"fir_lowpass_response.png")
    plot_response(b,a,fs,PLOTS_DIR/"iir_lowpass_response.png")
    print(f"Demo complete: {len(outputs)} WAV files in {OUTPUT_DIR} and plots in {PLOTS_DIR}.")

if __name__=="__main__":
    parser=argparse.ArgumentParser(); parser.add_argument("--demo",action="store_true"); args=parser.parse_args()
    if args.demo: demo()
    else:
        from gui.app import AudioEffectsApp
        AudioEffectsApp().mainloop()

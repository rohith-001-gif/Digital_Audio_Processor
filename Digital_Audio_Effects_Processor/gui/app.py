"""A deliberately simple, viva-friendly Tkinter application."""
from __future__ import annotations
import time
from pathlib import Path
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import numpy as np
import soundfile as sf
from config import OUTPUT_DIR, PLOTS_DIR
from dsp import fir_filters, iir_filters
from dsp.effects import safe_normalize, telephone, hard_clip, soft_clip, make_effect
from dsp.analysis import plot_analysis, plot_response
from dsp.realtime import RealtimeProcessor


class AudioEffectsApp(tk.Tk):
    def __init__(self):
        super().__init__(); self.title("Digital Audio Effects Processor"); self.geometry("920x690")
        self.audio=None; self.output=None; self.fs=44100; self.rt=None
        self.effect=tk.StringVar(value="FIR Low-pass"); self.status=tk.StringVar(value="Select a WAV file, or use Demo from the command line.")
        self.cutoff=tk.DoubleVar(value=3000); self.low=tk.DoubleVar(value=300); self.high=tk.DoubleVar(value=3400); self.taps=tk.IntVar(value=101); self.window=tk.StringVar(value="hamming"); self.mix=tk.DoubleVar(value=.35); self.gain=tk.DoubleVar(value=6); self.coefficients=tk.StringVar(value="Coefficients will appear here after a filter response is generated.")
        self._build()
    def _build(self):
        notebook=ttk.Notebook(self); notebook.pack(fill="both",expand=True,padx=10,pady=10)
        processor=ttk.Frame(notebook,padding=12); analysis=ttk.Frame(notebook,padding=12); about=ttk.Frame(notebook,padding=12)
        notebook.add(processor,text="Processor"); notebook.add(analysis,text="Analysis"); notebook.add(about,text="About")
        ttk.Label(processor,text="DIGITAL AUDIO EFFECTS PROCESSOR",font=("Segoe UI",16,"bold")).grid(column=0,row=0,columnspan=4,pady=(0,14))
        ttk.Button(processor,text="Select WAV",command=self.select_wav).grid(column=0,row=1,sticky="ew"); ttk.Button(processor,text="Process / Apply",command=self.process).grid(column=1,row=1,sticky="ew"); ttk.Button(processor,text="Save Output",command=self.save).grid(column=2,row=1,sticky="ew"); ttk.Button(processor,text="Play Output",command=self.play_output).grid(column=3,row=1,sticky="ew")
        fields=[("Effect",ttk.Combobox(processor,textvariable=self.effect,values=["Clean","FIR Low-pass","FIR High-pass","FIR Band-pass","FIR Notch","IIR Low-pass","IIR High-pass","IIR Band-pass","IIR Notch","Low Shelf","High Shelf","Telephone","Old AM Radio","Warm Voice","Echo","Reverb","Chorus","Flanger","Tremolo","Ring Modulation","Robot","Hard Distortion","Soft Distortion","Custom"],state="readonly")),("Cutoff Hz",ttk.Scale(processor,variable=self.cutoff,from_=50,to=18000)),("Low cutoff Hz",ttk.Scale(processor,variable=self.low,from_=50,to=8000)),("High cutoff Hz",ttk.Scale(processor,variable=self.high,from_=100,to=18000)),("FIR taps",ttk.Spinbox(processor,textvariable=self.taps,from_=3,to=1001,increment=2)),("Window",ttk.Combobox(processor,textvariable=self.window,values=["hamming","hann","blackman"],state="readonly")),("Wet/dry mix",ttk.Scale(processor,variable=self.mix,from_=0,to=1)),("Shelf gain (dB)",ttk.Scale(processor,variable=self.gain,from_=-18,to=18))]
        for row,(label,widget) in enumerate(fields,2): ttk.Label(processor,text=label).grid(column=0,row=row,sticky="w",pady=5); widget.grid(column=1,row=row,columnspan=3,sticky="ew",pady=5)
        ttk.Separator(processor).grid(column=0,row=10,columnspan=4,sticky="ew",pady=12)
        ttk.Button(processor,text="Start Real-Time Microphone",command=self.start_rt).grid(column=0,row=11,columnspan=2,sticky="ew"); ttk.Button(processor,text="Stop",command=self.stop_rt).grid(column=2,row=11,columnspan=2,sticky="ew")
        ttk.Label(processor,textvariable=self.status,wraplength=820).grid(column=0,row=12,columnspan=4,sticky="w",pady=(12,3)); ttk.Label(processor,textvariable=self.coefficients,wraplength=820,foreground="#355").grid(column=0,row=13,columnspan=4,sticky="w")
        for c in range(4): processor.columnconfigure(c,weight=1)
        ttk.Label(analysis,text="After processing, analysis PNGs are saved to the plots folder.",font=("Segoe UI",11)).pack(anchor="w"); ttk.Button(analysis,text="Create waveform, spectrum and spectrogram plot",command=self.make_analysis).pack(anchor="w",pady=10); ttk.Button(analysis,text="Create current filter response plot",command=self.make_response).pack(anchor="w")
        ttk.Label(about,text="Educational implementation: FIR filters use windowed sinc impulse responses; IIR filters use stateful RBJ biquads.\n\nOffline mode processes WAV files without modifying the source. Real-time mode processes blocks and preserves delay/filter state.\n\nApproximate one-way latency = block size / sample rate (512 / 44100 ≈ 11.6 ms).",justify="left",wraplength=800).pack(anchor="nw")
    def select_wav(self):
        path=filedialog.askopenfilename(filetypes=[("WAV audio","*.wav")]);
        if not path: return
        try: self.audio,self.fs=sf.read(path,always_2d=False,dtype="float64"); self.status.set(f"Loaded {Path(path).name}: {len(self.audio)/self.fs:.2f} s at {self.fs} Hz")
        except Exception as e: messagebox.showerror("Audio error",str(e))
    def _processor(self):
        name=self.effect.get(); lower=name.lower(); taps=int(self.taps.get())|1
        if name in ("Clean","Custom"): return (lambda x: x),None,None
        if lower.startswith("fir"):
            kind={"FIR Low-pass":"lowpass","FIR High-pass":"highpass","FIR Band-pass":"bandpass","FIR Notch":"bandstop"}[name]; h=fir_filters.design(kind,self.fs,self.cutoff.get(),self.low.get(),self.high.get(),taps,self.window.get()); return (lambda x: fir_filters.apply(x,h)), h, None
        if lower.startswith("iir") or name in ("Low Shelf","High Shelf"):
            kind={"IIR Low-pass":"lowpass","IIR High-pass":"highpass","IIR Band-pass":"bandpass","IIR Notch":"notch","Low Shelf":"low_shelf","High Shelf":"high_shelf"}[name]; b,a=iir_filters.biquad(kind,self.cutoff.get(),self.fs,gain_db=self.gain.get()); f=iir_filters.Biquad(b,a); return f.process,b,a
        if name=="Telephone": return lambda x: telephone(x,self.fs),None,None
        if name=="Old AM Radio": return lambda x: soft_clip(fir_filters.apply(x,fir_filters.bandpass(300,5000,self.fs)),1.2),None,None
        if name=="Warm Voice":
            b,a=iir_filters.biquad("low_shelf",180,self.fs,gain_db=5); f=iir_filters.Biquad(b,a); h=fir_filters.lowpass(6000,self.fs); return lambda x: fir_filters.apply(f.process(x),h),b,a
        if name=="Robot": return lambda x: telephone(x,self.fs)*np.sin(2*np.pi*90*np.arange(len(x))/self.fs)[:,None] if np.asarray(x).ndim==2 else telephone(x,self.fs)*np.sin(2*np.pi*90*np.arange(len(x))/self.fs),None,None
        if name=="Hard Distortion": return lambda x: hard_clip(x,2),None,None
        if name=="Soft Distortion": return lambda x: soft_clip(x,2),None,None
        effect=make_effect(name.lower(),self.fs,mix=self.mix.get()) if name in ("Echo","Reverb","Chorus","Flanger") else make_effect(name.lower(),self.fs)
        return effect.process,None,None
    def process(self):
        if self.audio is None: messagebox.showwarning("No input","Select a WAV file first."); return
        try:
            started=time.perf_counter(); processor,_,_=self._processor(); self.output=safe_normalize(processor(self.audio)); elapsed=time.perf_counter()-started
            self.status.set(f"Processed {len(self.audio)/self.fs:.2f} s in {elapsed*1000:.1f} ms; real-time factor {(len(self.audio)/self.fs)/max(elapsed,1e-9):.1f}x")
        except Exception as e: messagebox.showerror("Processing error",str(e))
    def save(self):
        if self.output is None: messagebox.showwarning("Nothing to save","Process audio first."); return
        path=filedialog.asksaveasfilename(initialdir=OUTPUT_DIR,defaultextension=".wav",initialfile="processed_output.wav",filetypes=[("WAV audio","*.wav")])
        if path: sf.write(path,self.output,self.fs); self.status.set(f"Saved {path}")
    def play_output(self):
        try:
            import sounddevice as sd
            if self.output is None: raise ValueError("Process audio first.")
            sd.play(self.output,self.fs); self.status.set("Playing output…")
        except Exception as e: messagebox.showerror("Playback",str(e))
    def make_analysis(self):
        if self.audio is None or self.output is None: messagebox.showwarning("Need audio","Load and process audio first."); return
        p=plot_analysis(self.audio,self.output,self.fs,PLOTS_DIR/"before_after_analysis.png",self.effect.get()); self.status.set(f"Saved analysis: {p.name}")
    def make_response(self):
        try:
            _,b,a=self._processor()
            if b is None: raise ValueError("Choose an FIR or IIR filter to plot its response.")
            p=plot_response(b,a,self.fs,PLOTS_DIR/"filter_response.png"); self.coefficients.set(f"Filter order: {len(b)-1}; fs: {self.fs} Hz; coefficients b/h = {np.array2string(b,precision=5)}" + ("" if a is None else f"; a = {np.array2string(a,precision=5)}")); self.status.set(f"Saved response: {p.name}")
        except Exception as e: messagebox.showerror("Response",str(e))
    def start_rt(self):
        try:
            processor,_,_=self._processor(); self.rt=RealtimeProcessor(processor,self.fs,512,1); self.rt.start(); self.status.set(f"Real-time running: {self.fs} Hz, 512 samples, ~{self.rt.latency_ms:.1f} ms latency")
        except Exception as e: messagebox.showerror("Real-time unavailable",str(e))
    def stop_rt(self):
        if self.rt: self.rt.stop(); self.rt=None; self.status.set("Real-time processing stopped.")

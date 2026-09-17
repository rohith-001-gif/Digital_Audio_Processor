function DigitalAudioEffectsProcessor
% DIGITALAUDIOEFFECTSPROCESSOR  Basic, viva-friendly MATLAB GUI.
% It intentionally keeps the UI small. All important signal processing is
% in the separate dsp functions, so each background operation is visible.
root=fileparts(mfilename('fullpath')); addpath(root,fullfile(root,'dsp'));
app=struct('x',[],'y',[],'fs',44100,'file','');
fig=figure('Name','Digital Audio Effects Processor — MATLAB','NumberTitle','off',...
    'Position',[120 80 1040 650],'Color',[0.95 0.97 1],'MenuBar','none');
uicontrol(fig,'Style','text','String','DIGITAL AUDIO EFFECTS PROCESSOR','FontSize',16,'FontWeight','bold',...
    'Position',[30 610 700 28],'BackgroundColor',[0.95 0.97 1],'HorizontalAlignment','left');
uicontrol(fig,'Style','pushbutton','String','1. Select WAV','Position',[30 560 150 32],'Callback',@selectWav);
uicontrol(fig,'Style','pushbutton','String','Create Test Signal','Position',[190 560 150 32],'Callback',@testSignal);
uicontrol(fig,'Style','pushbutton','String','Play Input','Position',[350 560 100 32],'Callback',@playInput);
uicontrol(fig,'Style','text','String','Effect / preset:','Position',[30 510 100 22],'BackgroundColor',[0.95 0.97 1],'HorizontalAlignment','left');
effects={'Clean','FIR Lowpass','FIR Highpass','FIR Bandpass','FIR Notch','IIR Lowpass','IIR Highpass','IIR Bandpass','IIR Notch','Low Shelf','High Shelf','Telephone','Old AM Radio','Warm Voice','Echo','Reverb','Chorus','Flanger','Tremolo','Robot','Hard Distortion','Soft Distortion'};
h.effect=uicontrol(fig,'Style','popupmenu','String',effects,'Position',[140 510 190 25]);
h.cutoff=makeEdit('Cutoff / centre (Hz)',30,470,'2000'); h.low=makeEdit('Low cutoff (Hz)',30,435,'300'); h.high=makeEdit('High cutoff (Hz)',30,400,'3400');
h.taps=makeEdit('FIR taps (odd)',30,365,'101'); h.window=makePopup('Window',30,330,{'hamming','hann','blackman'});
h.mix=makeEdit('Wet mix (0–1)',250,470,'0.4'); h.delay=makeEdit('Delay (ms)',250,435,'280'); h.rate=makeEdit('Rate (Hz)',250,400,'5'); h.gain=makeEdit('Shelf gain (dB)',250,365,'6');
uicontrol(fig,'Style','pushbutton','String','2. Apply Effect','FontWeight','bold','Position',[30 280 150 36],'Callback',@applyEffect);
uicontrol(fig,'Style','pushbutton','String','Play Output','Position',[190 280 120 36],'Callback',@playOutput);
uicontrol(fig,'Style','pushbutton','String','Save Output WAV','Position',[320 280 130 36],'Callback',@saveOutput);
uicontrol(fig,'Style','pushbutton','String','Show Analysis','Position',[30 235 130 32],'Callback',@showAnalysis);
uicontrol(fig,'Style','pushbutton','String','Filter Response','Position',[170 235 130 32],'Callback',@showResponse);
uicontrol(fig,'Style','pushbutton','String','Microphone Test','Position',[310 235 130 32],'Callback',@micTest);
uicontrol(fig,'Style','pushbutton','String','Continuous RT IIR','Position',[30 200 130 28],'Callback',@continuousRealtime);
uicontrol(fig,'Style','text','String','Status','FontWeight','bold','Position',[30 195 100 20],'BackgroundColor',[0.95 0.97 1],'HorizontalAlignment','left');
h.status=uicontrol(fig,'Style','text','String','Select a WAV file or create the synthetic test signal.','Position',[30 160 500 35],'BackgroundColor',[1 1 1],'HorizontalAlignment','left');
uicontrol(fig,'Style','text','String','Current coefficients / filter details','FontWeight','bold','Position',[570 580 350 20],'BackgroundColor',[0.95 0.97 1],'HorizontalAlignment','left');
h.coeff=uicontrol(fig,'Style','edit','Max',20,'Min',0,'Enable','inactive','HorizontalAlignment','left','FontName','Consolas','FontSize',10,'Position',[570 340 430 235],'BackgroundColor',[1 1 1],'String','Apply a FIR or IIR filter to see its coefficients.');
uicontrol(fig,'Style','text','String','Presentation order: input → select effect/parameters → Apply → Analysis → play/save output.','Position',[570 290 430 36],'BackgroundColor',[0.95 0.97 1],'HorizontalAlignment','left');

    function control=makeEdit(label,xpos,ypos,default)
        uicontrol(fig,'Style','text','String',label,'Position',[xpos ypos 125 22],'BackgroundColor',[0.95 0.97 1],'HorizontalAlignment','left');
        control=uicontrol(fig,'Style','edit','String',default,'Position',[xpos+125 ypos 80 24]);
    end
    function control=makePopup(label,xpos,ypos,items)
        uicontrol(fig,'Style','text','String',label,'Position',[xpos ypos 125 22],'BackgroundColor',[0.95 0.97 1],'HorizontalAlignment','left');
        control=uicontrol(fig,'Style','popupmenu','String',items,'Position',[xpos+125 ypos 100 24]);
    end
    function selectWav(~,~)
        [name,path]=uigetfile({'*.wav','WAV audio (*.wav)'}); if isequal(name,0), return; end
        try, [app.x,app.fs]=audioread(fullfile(path,name)); app.file=fullfile(path,name); app.y=[]; set(h.status,'String',sprintf('Loaded %s | %.1f s | %d Hz | %d channel(s)',name,size(app.x,1)/app.fs,app.fs,size(app.x,2))); catch ME, errordlg(ME.message,'Cannot read audio'); end
    end
    function testSignal(~,~)
        [app.x,app.fs]=create_test_signal(5,44100); app.file='matlab_test_signal.wav'; app.y=[]; set(h.status,'String','Created 5 s synthetic signal: 500, 1500, 3000 and 6000 Hz.');
    end
    function p=parameters
        p=struct('cutoff',number(h.cutoff),'lowCutoff',number(h.low),'highCutoff',number(h.high),'taps',round(number(h.taps)),...
            'window',popupText(h.window),'mix',number(h.mix),'delayMs',number(h.delay),'rate',number(h.rate),'gainDB',number(h.gain));
    end
    function applyEffect(~,~)
        if isempty(app.x), errordlg('First select a WAV or click Create Test Signal.','No input'); return; end
        effectName=popupText(h.effect); p=parameters; started=tic;
        try
            app.y=process_effect(app.x,app.fs,effectName,p); elapsed=toc(started); updateCoefficients(effectName,p);
            set(h.status,'String',sprintf('%s applied in %.3f s. Audio duration %.2f s; real-time factor %.1fx.',effectName,elapsed,size(app.x,1)/app.fs,(size(app.x,1)/app.fs)/max(elapsed,eps)));
        catch ME, errordlg(ME.message,'Processing error');
        end
    end
    function updateCoefficients(effectName,p)
        name=lower(strrep(effectName,' ',''));
        if startsWith(name,'fir')
            if contains(name,'bandpass'), type='bandpass'; elseif contains(name,'notch'), type='notch'; elseif contains(name,'high'), type='highpass'; else, type='lowpass'; end
            [hh,info]=fir_design_manual(type,app.fs,p.cutoff,p.highCutoff,p.taps,p.window); if contains(type,'band')||strcmp(type,'notch'), [hh,info]=fir_design_manual(type,app.fs,p.lowCutoff,p.highCutoff,p.taps,p.window); end
            set(h.coeff,'String',sprintf('FIR %s | order %d | fs %d Hz | window %s\n\nh[n] =\n%s',info.type,info.order,app.fs,info.window,sprintf('%.7f\n',hh)));
        elseif startsWith(name,'iir') || strcmp(name,'lowshelf') || strcmp(name,'highshelf')
            type=strrep(name,'iir',''); [b,a,c]=iir_biquad(type,app.fs,p.cutoff,0.707,p.gainDB);
            set(h.coeff,'String',sprintf('IIR %s | fs %d Hz | Q=0.707\n\nb0=%.7f\nb1=%.7f\nb2=%.7f\na0=%.7f\na1=%.7f\na2=%.7f',c.type,app.fs,b(1),b(2),b(3),a(1),a(2),a(3)));
        else, set(h.coeff,'String',sprintf('%s is an effect/preset. See dsp/process_effect.m for its readable DSP steps.',effectName));
        end
    end
    function showAnalysis(~,~), if isempty(app.y), errordlg('Apply an effect first.'); return; end, plot_audio_analysis(figure('Name','Before / After Analysis','Color','w'),app.x,app.y,app.fs,popupText(h.effect)); end
    function showResponse(~,~)
        p=parameters; name=lower(strrep(popupText(h.effect),' ','')); f=figure('Name','Filter Frequency Response','Color','w');
        try
            if startsWith(name,'fir'), if contains(name,'bandpass'), type='bandpass'; elseif contains(name,'notch'), type='notch'; elseif contains(name,'high'), type='highpass'; else, type='lowpass'; end; [hh,~]=fir_design_manual(type,app.fs,p.lowCutoff,p.highCutoff,p.taps,p.window); if ~contains(type,'band') && ~strcmp(type,'notch'), [hh,~]=fir_design_manual(type,app.fs,p.cutoff,0,p.taps,p.window); end; plot_filter_response(hh,1,app.fs,'FIR frequency response');
            elseif startsWith(name,'iir') || strcmp(name,'lowshelf') || strcmp(name,'highshelf'), [b,a]=iir_biquad(strrep(name,'iir',''),app.fs,p.cutoff,.707,p.gainDB); plot_filter_response(b,a,app.fs,'IIR frequency response');
            else, close(f); errordlg('Choose a FIR or IIR filter to show a response.'); end
        catch ME, if isvalid(f), close(f); end, errordlg(ME.message,'Response error'); end
    end
    function playInput(~,~), if isempty(app.x), errordlg('No input audio.'); else, sound(app.x,app.fs); end, end
    function playOutput(~,~), if isempty(app.y), errordlg('No output audio.'); else, sound(app.y,app.fs); end, end
    function saveOutput(~,~), if isempty(app.y), errordlg('Apply an effect first.'); return; end; [name,path]=uiputfile('*.wav','Save processed WAV',fullfile(root,'..','output',[lower(strrep(popupText(h.effect),' ','_')) '.wav'])); if ~isequal(name,0), write_audio_safe(fullfile(path,name),app.y,app.fs); set(h.status,'String',['Saved output: ' fullfile(path,name)]); end, end
    function micTest(~,~)
        answer=questdlg('This records 3 seconds, applies the chosen effect, then plays it. For continuous low-latency real-time audio, MATLAB Audio Toolbox is needed. Continue?','Microphone test','Continue','Cancel','Cancel'); if ~strcmp(answer,'Continue'), return; end
        try, recorder=audiorecorder(app.fs,16,1); recordblocking(recorder,3); app.x=getaudiodata(recorder); app.file='microphone_3_second_recording.wav'; applyEffect(); sound(app.y,app.fs); catch ME, errordlg(ME.message,'Microphone unavailable'); end
    end
    function continuousRealtime(~,~)
        try, continuous_realtime_iir('lowpass',number(h.cutoff),512); catch ME, errordlg(ME.message,'Continuous real-time mode'); end
    end
    function value=number(control), value=str2double(get(control,'String')); if ~isfinite(value), error('Every numeric field must contain a valid number.'); end, end
    function value=popupText(control), choices=get(control,'String'); value=choices{get(control,'Value')}; end
end

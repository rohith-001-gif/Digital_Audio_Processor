function continuous_realtime_iir(filterType, cutoffHz, blockSize)
% CONTINUOUS_REALTIME_IIR  Microphone -> IIR filter -> speaker loop.
% Requires MATLAB Audio Toolbox. State is carried from one block to the next.
if nargin < 1, filterType='lowpass'; end
if nargin < 2, cutoffHz=2000; end
if nargin < 3, blockSize=512; end
if ~exist('audioDeviceReader','class') || ~exist('audioDeviceWriter','class')
    error(['Continuous real-time mode needs MATLAB Audio Toolbox. ' ...
        'Use the GUI Microphone Test or offline WAV mode without it.']);
end
fs=44100; reader=audioDeviceReader('SampleRate',fs,'SamplesPerFrame',blockSize,'NumChannels',1);
writer=audioDeviceWriter('SampleRate',fs);
[b,a]=iir_biquad(filterType,fs,cutoffHz,0.707,0); state=[];
control=figure('Name','Continuous real-time IIR','NumberTitle','off','MenuBar','none','Position',[300 300 380 120]);
uicontrol(control,'Style','text','String',sprintf('Live %s at %d Hz | block=%d | latency ≈ %.1f ms',filterType,cutoffHz,blockSize,1000*blockSize/fs),'Position',[15 75 350 25]);
uicontrol(control,'Style','text','String','Close this window to stop. Use headphones to prevent feedback.','Position',[15 45 350 22]);
while isvalid(control)
    inputBlock=reader();
    [outputBlock,state]=apply_biquad(inputBlock,b,a,state);
    writer(outputBlock);
    drawnow limitrate;
end
release(reader); release(writer);
end

function plot_audio_analysis(fig, x, y, fs, titleText)
% PLOT_AUDIO_ANALYSIS  Before/after waveform, spectrum and spectrogram.
figure(fig); clf(fig); set(fig,'Color','w');
t=(0:size(x,1)-1)/fs; n=min(size(x,1),8192); f=(0:floor(n/2))*fs/n;
subplot(3,2,1); plot(t,x(:,1)); grid on; title('Input waveform'); xlabel('Time (s)'); ylabel('Amplitude');
subplot(3,2,2); plot(t,y(:,1)); grid on; title('Output waveform'); xlabel('Time (s)'); ylabel('Amplitude');
X=fft(x(1:n,1))/n; Y=fft(y(1:n,1))/n;
subplot(3,2,3); plot(f,20*log10(abs(X(1:floor(n/2)+1))+eps)); xlim([0 fs/2]); grid on; title('Input spectrum'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
subplot(3,2,4); plot(f,20*log10(abs(Y(1:floor(n/2)+1))+eps)); xlim([0 fs/2]); grid on; title('Output spectrum'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
subplot(3,2,5); simple_spectrogram(x(:,1),fs); title('Input spectrogram');
subplot(3,2,6); simple_spectrogram(y(:,1),fs); title('Output spectrogram');
annotation(fig,'textbox',[0.3 0.96 0.4 0.03],'String',titleText,'EdgeColor','none','HorizontalAlignment','center','FontWeight','bold');
end

function simple_spectrogram(signal,fs)
% This short-time FFT is used instead of the toolbox spectrogram command.
frameLength=512; hop=128; numberFrames=max(1,floor((numel(signal)-frameLength)/hop)+1);
window=0.5-0.5*cos(2*pi*(0:frameLength-1)'/(frameLength-1));
S=zeros(frameLength/2+1,numberFrames);
for frame=1:numberFrames
    index=(frame-1)*hop+(1:frameLength);
    if index(end)>numel(signal), break; end
    X=fft(signal(index).*window);
    S(:,frame)=20*log10(abs(X(1:frameLength/2+1))+eps);
end
time=((0:numberFrames-1)*hop+frameLength/2)/fs;
frequency=(0:frameLength/2)*fs/frameLength;
imagesc(time,frequency,S); axis xy; ylim([0 min(fs/2,10000)]); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
end

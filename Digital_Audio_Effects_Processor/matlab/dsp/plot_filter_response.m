function plot_filter_response(b, a, fs, titleText)
% PLOT_FILTER_RESPONSE  Evaluates H(e^jw) from the coefficients directly.
frequency = linspace(0, fs/2, 2048); omega=2*pi*frequency/fs; H=zeros(size(omega));
for k=1:numel(omega)
    z=exp(-1i*omega(k)); numerator=sum(b(:)'.*z.^(0:numel(b)-1)); denominator=sum(a(:)'.*z.^(0:numel(a)-1)); H(k)=numerator/denominator;
end
plot(frequency,20*log10(abs(H)+eps),'LineWidth',1.2); grid on; xlim([0 fs/2]); ylim([-90 10]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title(titleText);
end

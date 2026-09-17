function [x, fs] = create_test_signal(durationSeconds, fs)
% CREATE_TEST_SIGNAL  Synthetic audio containing four easy-to-see tones.
if nargin < 1, durationSeconds = 5; end
if nargin < 2, fs = 44100; end
t = (0:1/fs:durationSeconds-1/fs)';
x = 0.25*sin(2*pi*500*t) + 0.22*sin(2*pi*1500*t) + ...
    0.18*sin(2*pi*3000*t) + 0.15*sin(2*pi*6000*t);
% A short fade prevents clicks at the beginning and end.
fadeSamples = min(round(0.02*fs), floor(numel(x)/2));
fade = linspace(0, 1, fadeSamples)';
x(1:fadeSamples) = x(1:fadeSamples).*fade;
x(end-fadeSamples+1:end) = x(end-fadeSamples+1:end).*flipud(fade);
end

function [h, info] = fir_design_manual(type, fs, f1, f2, taps, windowName)
% FIR_DESIGN_MANUAL  Windowed-sinc FIR design. No fir1/filter call is used.
% f1 is cutoff for low/high pass; f1,f2 are lower/upper cutoffs for band filters.
if mod(taps, 2) == 0 || taps < 3, error('FIR tap count must be an odd number >= 3.'); end
if f1 <= 0 || f1 >= fs/2 || (contains(lower(type),'band') && (f2 <= f1 || f2 >= fs/2))
    error('Choose frequencies inside 0 to the Nyquist frequency (fs/2).');
end
M = taps - 1; n = 0:M; centre = M/2; m = n - centre;
idealLow = @(fc) 2*(fc/fs)*sinc(2*(fc/fs)*m); % MATLAB sinc(z)=sin(pi*z)/(pi*z)
switch lower(type)
    case 'lowpass', hIdeal = idealLow(f1);
    case 'highpass', hIdeal = -idealLow(f1); hIdeal(centre+1) = hIdeal(centre+1) + 1;
    case 'bandpass', hIdeal = idealLow(f2) - idealLow(f1);
    case {'bandstop','notch'}
        hIdeal = idealLow(f1) - idealLow(f2); hIdeal(centre+1) = hIdeal(centre+1) + 1;
    otherwise, error('Unknown FIR type.');
end
switch lower(windowName)
    case 'hamming', w = 0.54 - 0.46*cos(2*pi*n/M);
    case 'hann', w = 0.5 - 0.5*cos(2*pi*n/M);
    case 'blackman', w = 0.42 - 0.5*cos(2*pi*n/M) + 0.08*cos(4*pi*n/M);
    otherwise, error('Window must be hamming, hann, or blackman.');
end
h = (hIdeal .* w)';
info = struct('type', lower(type), 'fs', fs, 'f1', f1, 'f2', f2, ...
    'taps', taps, 'order', M, 'window', lower(windowName));
end

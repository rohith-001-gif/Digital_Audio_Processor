function [b, a, coefficients] = iir_biquad(type, fs, f0, Q, gainDB)
% IIR_BIQUAD  RBJ cookbook coefficients for a second-order IIR filter.
% The returned equation is y[n]=b0*x[n]+b1*x[n-1]+b2*x[n-2]
%                              -a1*y[n-1]-a2*y[n-2].
if nargin < 4 || isempty(Q), Q = 0.707; end
if nargin < 5 || isempty(gainDB), gainDB = 0; end
if f0 <= 0 || f0 >= fs/2, error('Centre/cutoff frequency must be below Nyquist.'); end
w0 = 2*pi*f0/fs; c = cos(w0); s = sin(w0); alpha = s/(2*Q); A = 10^(gainDB/40);
switch lower(type)
    case 'lowpass'
        b0=(1-c)/2; b1=1-c; b2=(1-c)/2; a0=1+alpha; a1=-2*c; a2=1-alpha;
    case 'highpass'
        b0=(1+c)/2; b1=-(1+c); b2=(1+c)/2; a0=1+alpha; a1=-2*c; a2=1-alpha;
    case 'bandpass'
        b0=alpha; b1=0; b2=-alpha; a0=1+alpha; a1=-2*c; a2=1-alpha;
    case {'notch','bandstop'}
        b0=1; b1=-2*c; b2=1; a0=1+alpha; a1=-2*c; a2=1-alpha;
    case 'lowshelf'
        beta=2*sqrt(A)*alpha;
        b0=A*((A+1)-(A-1)*c+beta); b1=2*A*((A-1)-(A+1)*c); b2=A*((A+1)-(A-1)*c-beta);
        a0=(A+1)+(A-1)*c+beta; a1=-2*((A-1)+(A+1)*c); a2=(A+1)+(A-1)*c-beta;
    case 'highshelf'
        beta=2*sqrt(A)*alpha;
        b0=A*((A+1)+(A-1)*c+beta); b1=-2*A*((A-1)+(A+1)*c); b2=A*((A+1)+(A-1)*c-beta);
        a0=(A+1)-(A-1)*c+beta; a1=2*((A-1)-(A+1)*c); a2=(A+1)-(A-1)*c-beta;
    otherwise, error('Unknown IIR filter type.');
end
b = [b0 b1 b2]/a0; a = [1 a1/a0 a2/a0];
coefficients = struct('b', b, 'a', a, 'type', lower(type), 'fs', fs, 'frequency', f0, 'Q', Q, 'gainDB', gainDB);
end

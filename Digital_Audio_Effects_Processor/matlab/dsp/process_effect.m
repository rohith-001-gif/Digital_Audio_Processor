function y = process_effect(x, fs, effectName, p)
% PROCESS_EFFECT  Readable offline implementations of common audio effects.
if nargin < 4, p = struct(); end
x = double(x); if isvector(x), x = x(:); end
name = lower(strrep(effectName, ' ', ''));
switch name
    case 'clean', y = x;
    case 'firlowpass'
        [h,~]=fir_design_manual('lowpass',fs,getp(p,'cutoff',2000),0,getp(p,'taps',101),getp(p,'window','hamming')); y=manual_convolution(x,h,'same');
    case 'firhighpass'
        [h,~]=fir_design_manual('highpass',fs,getp(p,'cutoff',2000),0,getp(p,'taps',101),getp(p,'window','hamming')); y=manual_convolution(x,h,'same');
    case 'firbandpass'
        [h,~]=fir_design_manual('bandpass',fs,getp(p,'lowCutoff',300),getp(p,'highCutoff',3400),getp(p,'taps',101),getp(p,'window','hamming')); y=manual_convolution(x,h,'same');
    case 'firnotch'
        [h,~]=fir_design_manual('notch',fs,getp(p,'lowCutoff',900),getp(p,'highCutoff',1100),getp(p,'taps',101),getp(p,'window','hamming')); y=manual_convolution(x,h,'same');
    case {'iirlowpass','iirhighpass','iirbandpass','iirnotch','lowshelf','highshelf'}
        kind = strrep(name,'iir',''); [b,a]=iir_biquad(kind,fs,getp(p,'cutoff',2000),getp(p,'Q',0.707),getp(p,'gainDB',6)); y=apply_biquad(x,b,a);
    case {'echo','delay'}
        delay = max(1,round(getp(p,'delayMs',300)*fs/1000)); feedback=getp(p,'feedback',0.35); mix=getp(p,'mix',0.4); wet=zeros(size(x));
        % First delayed copy comes from x[n-delay]; feedback creates repeats.
        for n=delay+1:size(x,1), wet(n,:)=x(n-delay,:)+feedback*wet(n-delay,:); end; y=(1-mix)*x+mix*wet;
    case {'chorus','flanger'}
        if strcmp(name,'chorus'), baseMs=20; depthMs=8; rate=0.8; mixDefault=0.45;
        else, baseMs=3; depthMs=2; rate=0.35; mixDefault=0.50; end
        baseMs=getp(p,'delayMs',baseMs); depthMs=getp(p,'depthMs',depthMs); rate=getp(p,'rate',rate); mix=getp(p,'mix',mixDefault);
        y=zeros(size(x)); maximumDelay=ceil((baseMs+depthMs)*fs/1000)+2;
        padded=[zeros(maximumDelay,size(x,2)); x];
        for n=1:size(x,1)
            currentDelay=(baseMs+depthMs*sin(2*pi*rate*(n-1)/fs))*fs/1000;
            readPosition=n+maximumDelay-currentDelay;
            left=floor(readPosition); fraction=readPosition-left;
            delayed=(1-fraction)*padded(left,:)+fraction*padded(left+1,:);
            y(n,:)=(1-mix)*x(n,:)+mix*delayed;
        end
    case 'tremolo'
        t=(0:size(x,1)-1)'/fs; gain=1-getp(p,'depth',0.5)/2 + getp(p,'depth',0.5)/2*sin(2*pi*getp(p,'rate',5)*t); y=x.*gain;
    case {'ringmodulation','robot'}
        t=(0:size(x,1)-1)'/fs; carrier=sin(2*pi*getp(p,'rate',80)*t); y=x.*carrier;
        if strcmp(name,'robot'), y=process_effect(y,fs,'firbandpass',struct('lowCutoff',300,'highCutoff',3400,'taps',101,'window','hamming')); end
    case {'harddistortion','hardclip'}
        y=max(-getp(p,'threshold',0.45),min(getp(p,'threshold',0.45),x*getp(p,'drive',2)));
    case {'softdistortion','softclip'}
        y=tanh(x*getp(p,'drive',2));
    case 'telephone'
        y=process_effect(x,fs,'firbandpass',struct('lowCutoff',300,'highCutoff',3400,'taps',101,'window','hamming')); y=tanh(1.4*y);
    case 'oldamradio'
        y=process_effect(x,fs,'firbandpass',struct('lowCutoff',300,'highCutoff',5000,'taps',101,'window','hann')); y=tanh(2*y);
    case 'warmvoice'
        [b,a]=iir_biquad('lowshelf',fs,220,0.707,6); y=apply_biquad(x,b,a); [b,a]=iir_biquad('lowpass',fs,5500,0.707,0); y=apply_biquad(y,b,a);
    case 'reverb'
        delays=round(fs*[0.0297 0.0371 0.0411 0.0437]); decay=getp(p,'decay',0.45); wet=zeros(size(x));
        for d=delays, temp=zeros(size(x)); temp(d+1:end,:)=x(1:end-d,:); wet=wet+(decay*temp); end
        y=(1-getp(p,'mix',0.3))*x+getp(p,'mix',0.3)*wet;
    otherwise, error('Unknown effect/preset: %s', effectName);
end
y = safe_normalize(y);
end

function value=getp(s,field,defaultValue)
if isfield(s,field), value=s.(field); else, value=defaultValue; end
end

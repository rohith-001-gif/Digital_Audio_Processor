function test_all
% TEST_ALL  Small checks for the educational MATLAB implementation.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root,fullfile(root,'dsp'));
fs=44100; x=[1; zeros(99,1)];
[h,info]=fir_design_manual('lowpass',fs,2000,0,101,'hamming'); assert(numel(h)==101 && abs(sum(h)-1)<0.05); assert(info.order==100);
y=manual_convolution(x,h,'same'); assert(all(isfinite(y)) && numel(y)==numel(x));
[b,a]=iir_biquad('lowpass',fs,2000,0.707,0); yi=apply_biquad(randn(1000,2)*0.05,b,a); assert(all(isfinite(yi(:))));
impulse=[1;zeros(round(fs/2),1)]; echo=process_effect(impulse,fs,'echo',struct('delayMs',100,'feedback',0,'mix',0.5)); assert(abs(echo(round(fs*.1)+1))>0.1);
dist=process_effect(3*ones(100,1),fs,'softdistortion',struct('drive',3)); assert(max(abs(dist))<=0.98);
stereo=[sin((1:100)'/10), cos((1:100)'/10)]; out=process_effect(stereo,fs,'telephone',struct()); assert(isequal(size(out),size(stereo)));
disp('All MATLAB DSP tests passed.');
end

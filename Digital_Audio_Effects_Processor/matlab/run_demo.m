% RUN_DEMO  Creates a known test signal and demonstrates the main effects.
% This is useful when no music or microphone recording is available.

projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot, fullfile(projectRoot, 'dsp'));
inputFolder = fullfile(projectRoot, '..', 'input');
outputFolder = fullfile(projectRoot, '..', 'output', 'matlab_demo');
plotFolder = fullfile(projectRoot, '..', 'plots', 'matlab_demo');
if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
if ~exist(plotFolder, 'dir'), mkdir(plotFolder); end

[x, fs] = create_test_signal(5, 44100);
audiowrite(fullfile(inputFolder, 'matlab_test_signal.wav'), x, fs);

[h, info] = fir_design_manual('lowpass', fs, 2000, 0, 101, 'hamming');
yFir = manual_convolution(x, h, 'same');
[b, a, coeff] = iir_biquad('lowpass', fs, 2000, 0.707, 0);
yIir = apply_biquad(x, b, a);
yTelephone = process_effect(x, fs, 'telephone', struct());
yEcho = process_effect(x, fs, 'echo', struct('delayMs', 280, 'feedback', 0.35, 'mix', 0.40));
yReverb = process_effect(x, fs, 'reverb', struct('mix', 0.32, 'decay', 0.45));

write_audio_safe(fullfile(outputFolder, 'fir_lowpass.wav'), yFir, fs);
write_audio_safe(fullfile(outputFolder, 'iir_lowpass.wav'), yIir, fs);
write_audio_safe(fullfile(outputFolder, 'telephone.wav'), yTelephone, fs);
write_audio_safe(fullfile(outputFolder, 'echo.wav'), yEcho, fs);
write_audio_safe(fullfile(outputFolder, 'reverb.wav'), yReverb, fs);

fig = figure('Name', 'MATLAB DSP Demo', 'Color', 'w', 'Visible', 'off');
plot_audio_analysis(fig, x, yTelephone, fs, 'Telephone preset: before and after');
saveas(fig, fullfile(plotFolder, 'telephone_analysis.png'));
fig2 = figure('Name', 'FIR Response', 'Color', 'w', 'Visible', 'off');
plot_filter_response(h, 1, fs, 'FIR low-pass response');
saveas(fig2, fullfile(plotFolder, 'fir_lowpass_response.png'));
fig3 = figure('Name', 'IIR Response', 'Color', 'w', 'Visible', 'off');
plot_filter_response(b, a, fs, 'IIR low-pass response');
saveas(fig3, fullfile(plotFolder, 'iir_lowpass_response.png'));

fprintf('MATLAB demo complete. Files saved in:\n%s\n', outputFolder);
fprintf('FIR: %s, order %d, window %s\n', info.type, info.order, info.window);
fprintf('IIR coefficients: b=[%.5f %.5f %.5f], a=[%.5f %.5f %.5f]\n', coeff.b, coeff.a);

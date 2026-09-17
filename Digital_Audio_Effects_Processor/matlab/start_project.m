% START_PROJECT  Launch the MATLAB Digital Audio Effects Processor.
% Run this file from MATLAB. It adds the project folders to MATLAB's path
% and opens the simple graphical interface.

projectRoot = fileparts(mfilename('fullpath'));
addpath(projectRoot, fullfile(projectRoot, 'dsp'), fullfile(projectRoot, 'tests'));
DigitalAudioEffectsProcessor;

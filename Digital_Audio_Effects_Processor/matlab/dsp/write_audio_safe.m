function write_audio_safe(filename, x, fs)
% WRITE_AUDIO_SAFE  Normalizes then writes without changing the input file.
audiowrite(filename, safe_normalize(x), fs);
end

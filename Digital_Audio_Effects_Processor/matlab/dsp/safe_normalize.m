function y = safe_normalize(x)
% SAFE_NORMALIZE  Removes invalid values and prevents WAV clipping.
x(~isfinite(x)) = 0;
peak = max(abs(x(:)));
if peak > 0.98, y = 0.98*x/peak; else, y = x; end
end

function y = manual_convolution(x, h, outputMode)
% MANUAL_CONVOLUTION  FIR equation implemented directly with loops.
% y[n] = sum(h[k] * x[n-k]).  Each audio channel is processed separately.
if nargin < 3, outputMode = 'same'; end
if ~isvector(h), error('The impulse response h must be a vector.'); end
if isempty(x) || isempty(h), error('Audio and filter coefficients cannot be empty.'); end
x = double(x); h = double(h(:));
if isvector(x), x = x(:); end
[numberSamples, channels] = size(x);
filterLength = numel(h);
fullY = zeros(numberSamples + filterLength - 1, channels);
for ch = 1:channels
    for n = 1:size(fullY, 1)
        total = 0;
        for k = 1:filterLength
            sourceIndex = n - k + 1;
            if sourceIndex >= 1 && sourceIndex <= numberSamples
                total = total + h(k) * x(sourceIndex, ch);
            end
        end
        fullY(n, ch) = total;
    end
end
switch lower(outputMode)
    case 'full', y = fullY;
    case 'same'
        first = floor((filterLength - 1)/2) + 1;
        y = fullY(first:first+numberSamples-1, :);
    otherwise, error('outputMode must be ''full'' or ''same''.');
end
end

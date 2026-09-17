function [y, state] = apply_biquad(x, b, a, state)
% APPLY_BIQUAD  Direct-form difference equation with persistent state.
% Pass returned state into the next audio block in real-time processing.
if nargin < 4 || isempty(state), state = zeros(2, size(x,2)); end
x = double(x); if isvector(x), x = x(:); end
if numel(b) ~= 3 || numel(a) ~= 3 || a(1) ~= 1, error('Use normalized 3-coefficient b and a arrays.'); end
y = zeros(size(x));
for ch = 1:size(x,2)
    z1 = state(1,ch); z2 = state(2,ch);
    for n = 1:size(x,1)
        y(n,ch) = b(1)*x(n,ch) + z1;
        z1 = b(2)*x(n,ch) - a(2)*y(n,ch) + z2;
        z2 = b(3)*x(n,ch) - a(3)*y(n,ch);
    end
    state(:,ch) = [z1; z2];
end
end

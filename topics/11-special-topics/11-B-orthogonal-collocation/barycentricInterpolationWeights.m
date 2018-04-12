function v = barycentricInterpolationWeights(x)
% v = barycentricInterpolationWeights(x)
%
% This function computed the barycentric interpolation weights that
% correspond to a specific set of interpolation points.
%
% INPUTS:
%   x = [1, n] = vector of interpolation points
%
% OUTPUTS:
%   v = [1, n] = vector of interpolation weights
%
% NOTES:
%   https://epubs.siam.org/doi/pdf/10.1137/16M1062569  (Appendix D)
%
%   This algorithm may not be the best for numerical stability and
%   efficiency, but it is included here simply for illustrative purposes.
%
%   Use the ChebFun toolbox or similar, which computes these weights at the
%   same time as the points, using numerically well designed algorithms.
%

n = length(x);
v = zeros(size(x));

for i=1:n
   t = x(i) - x;
   t(i) = [];
   v(i) = 1/prod(t);
end 
v = v / max(abs(v));

end
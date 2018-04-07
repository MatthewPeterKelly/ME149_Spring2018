function D = orthDiffMat(X, V)
% D = orthDiffMat(X, V)
%
% This function computes the differentiation matrix associated with an
% orthogonal polynomial.
%
% INPUTS:
%   X = [1, n] = vector of points
%   V = [1, n] = vector of barycentric interpolation weights
%   domain = [low, upp] = domain of the interval
%
% OUTPUTS:
%   D = [n, n] = differentiation matrix
%
% NOTES
%   Given F = fun(X)
%   Then dF = D * F = derivative of the interpolant at points X
%
%   X and V are computed using either chebpts, lobpts, or legpts
%
% REFERENCE:
%
%   https://people.maths.ox.ac.uk/trefethen/barycentric.pdf
%
%   https://epubs.siam.org/doi/pdf/10.1137/16M1062569     [Appendix D]
%

n = length(X);
D = zeros(n, n);

% Populate non-diagonal entries:
for i=1:n
    for j = (i+1):n
        a = V(j) / V(i);
        b = X(i) - X(j);
        D(i,j) = a / b;
        D(j,i) = -1 / (a*b);
    end
end

% Populate the diagonal entries:
for i=1:n
    D(i,i) = -sum(D(i, :));
end

end
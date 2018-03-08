function polyInfo = getPolynomialTestFunction(seed)
% polyInfo = getPolynomialTestFunction(seed)
%
% This function computes a polynomial test function that has a single 
% root xRoot on the bracketed interval [xLow, xUpp].
%
% INPUTS:
%   seed = int = seed for the random number generator (RNG)
%
% OUTPUTS:
%   polyInfo = struct with polynomial information:
%       .xRoot = unique root on [xLow, xUpp]
%       .xLow = lower edge of bracket
%       .xUpp = upper edge of bracket
%       .xBnd = domain [low, upp] for plotting
%       .coeff = matlab polynomial coefficient data
%

% initialize the RNG
rng(seed, 'twister'); 

% Select the roots to use for the polynomial
nRoot = randi(5);
iRoot = randi(nRoot);
xDel = 0.2 + 0.8 * rand(1, nRoot);
xRoots = cumsum(xDel);
xRoot = xRoots(iRoot);

% Set the bounds of the search interval
xDelBnd = [0.5 + 3*rand(1), diff(xRoots), 0.5 + 3*rand(1)];
xDelLow = 0.02 + 0.98 * rand(1);
xDelUpp = 0.02 + 0.98 * rand(1);
xLow = xRoot - xDelLow*xDelBnd(iRoot);
xUpp = xRoot + xDelUpp*xDelBnd(iRoot+1);

% Bounds for plotting:
xBnd = [min(min(xRoot), xLow), max(max(xRoots), xUpp)];
xBnd = xBnd + 0.1 * diff(xBnd)*[-1,1];

% Pack up the data:
polyInfo.xRoot = xRoot;
polyInfo.xLow = xLow;
polyInfo.xUpp = xUpp;
polyInfo.xBnd = xBnd;
polyInfo.coeff = poly(xRoots);

end
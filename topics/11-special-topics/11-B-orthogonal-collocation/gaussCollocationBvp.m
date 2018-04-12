function soln = gaussCollocationBvp(tBnd, dynFun, bndCst, guess, n)
% soln = gaussCollocationBvp(tBnd, dynFun, bndCst, guess, n)
%
% This function uses gauss pseudospectral collocation to solve a
% boundary value problem for a simple dynamical system.
%
% INPUTS:
%   tBnd = [tLow, tUpp] = boundary times
%   dynFun = function handle for the dynamics
%       IN: x = [nDim, nGrid] = state vector
%       OUT: dx = [nDim, nGrid] = dynamics (derivative of state)
%   bndCst = boundary constraint function
%       IN: x0 = [nDim, 1] = initial state
%       IN: xF = [nDim, 1] = final state
%       OUT: cst = [nCst, 1] = equality constraint at boundaries
%   guess = function handle for interpolating the initial guess
%       IN: t = [1, nGrid] = vector of query times on tBnd
%       OUT: x = [nDim, nGrid] = matrix of states at query times
%   n = number of collocation points
%
% OUTPUTS:
%   soln = solution struct
%
% REFERENCES:
%
%    https://hal.archives-ouvertes.fr/hal-01615132/file/GPHR.pdf
%

% Compute collocation grid and weights:
[tColl, wColl, vColl] = legpts(n, tBnd);

% Compute the differentiation matrix:
tDiff = [tBnd(1); tColl];
vDiff = barycentricInterpolationWeights(tDiff);
Dsq = orthDiffMat(tDiff, vDiff);
D = Dsq(2:end, :);

% Initial guess:
tGrid = [tBnd(1); tColl; tBnd(2)];
xGridGuess = guess(tGrid')';
decVarGuess = packDecVars(xGridGuess);

% Constraint function:
cstFun = @(decVars)( collocFun(decVars, dynFun, bndCst, D, wColl) );

% Options:
options = optimset('fsolve');
options.Display = 'iter';  % {'iter','final','off'}
options.MaxFunEvals = 1e4;
options.MaxIter = 1e3;

% Solve:
xSoln = fsolve(cstFun, decVarGuess, options);
xGrid = unpackDecVars(xSoln, n);
x0 = xGrid(1, :);
xColl = xGrid(2:(end-1), :);
dxColl = dynFun(xColl')';
xF = xGrid(end, :);

% Return solution grid points:
soln.knots.t = tBnd;
soln.knots.x = [x0', xF'];
soln.colloc.t = tColl';
soln.colloc.x = xColl';
soln.colloc.dx = dxColl';
soln.colloc.v = vColl;

% Evaluate on dense grid:
nDim = length(x0);
nGrid = 250;
soln.interp.t = linspace(tBnd(1), tBnd(2), nGrid);
soln.interp.x = zeros(nDim, nGrid);
soln.interp.dx = zeros(nDim, nGrid);
xDiff = [x0; xColl];
for iDim = 1:nDim
    soln.interp.x(iDim, :) = bary(soln.interp.t', xDiff(:, iDim), tDiff, vDiff)';
    soln.interp.dx(iDim, :) = bary(soln.interp.t', dxColl(:, iDim), tColl, vColl)';
end

% Evaluate the error on a grid:
soln.collErr.t = soln.interp.t;
soln.collErr.x = dynFun(soln.interp.x) - soln.interp.dx;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function decVars = packDecVars(xGrid)

decVars = reshape(xGrid, numel(xGrid), 1);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function xGrid = unpackDecVars(decVars, n)

nDim = numel(decVars) / (n+2);
xGrid = reshape(decVars, n+2, nDim);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function cst = collocFun(decVars, dynFun, bndCst, D, wColl)

n = length(wColl);
xGrid = unpackDecVars(decVars, n);

x0 = xGrid(1, :);
xColl = xGrid(2:(end-1), :);
xF = xGrid(end, :);
dxColl = dynFun(xColl')';

collCst = D*[x0; xColl] - dxColl;
quadCst = (xF - x0) - wColl * dxColl;
bvpCst = bndCst(x0', xF');

cst = [reshape(collCst, numel(collCst), 1);
    reshape(quadCst, numel(quadCst), 1);
    bvpCst];
end

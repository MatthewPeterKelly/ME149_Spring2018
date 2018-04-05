function pp = ppSpline2b(tGrid, xGrid)
% pp = ppSpline2b(tGrid, xGrid)
%
% This function computes a matlab pp-form (piecewise-polynomial) spline
% that is quadratic between knot points. Each segment is constructed using
% the value of the function at both boundaries and the midpoint of each 
% segment.
%
% [xLow, xMid, xUpp]  -->  coeff
%
% INPUTS:
%   tGrid = [1, 2*nSeg + 1] = vector of grid points
%   xGrid = [nDim, 2*nSeg + 1] = value at each grid point
%
% OUTPUTS:
%   pp = Matlab pp-form spline that quadratically interpolates the data
%
% NOTES:
%   IMPORTANT: tGrid is assumed to be of the form:
%       tGrid(k) = 0.5 * (tGrid(k-1), tGrid(k+1));
%       In other words, elements 1, 3, 5, ... represent the knot points
%       for the spline, while 2, 4, 6, ... represent the midpoints, which
%       are assumed to be exactly at the middle of each pair of knot
%       points.
%
% REFERENCES:
%   
%   "Practical Methods for Optimal Control and Estimation Using NOnlinear
%   Programming" by John T. Betts. Section 4.7.1 - 4.7.2.
%   
%   "Trajectory Optimization: Overview and Tutorial"  Slide 20
%   By Matthew P. Kelly
%   http://www.matthewpeterkelly.com/tutorials/trajectoryOptimization/cartPoleCollocation.svg
%

% Run a unit test if called with no arguments
if nargin == 0, ppSpline2b_test(); return; end

% Check input size:
[nDim, nGrid] = size(xGrid);
if mod(nGrid, 2) ~= 1
   error('Invalid input: nGrid must be odd!  (nGrid = 2*nSeg+1)');   
end
if nGrid < 3
   error('Invalid input: nGrid >= 3 is required!   (nGrid = 2*nSeg+1)');
end
[oneCheck, nGridCheck] = size(tGrid);
if oneCheck ~= 1 || nGridCheck ~= nGrid
    error('Invalid input: tGrid must be size [%d, %d]', 1, nGrid);
end

% Size of the coefficient data structure
nSeg = (nGrid - 1)/2;  % number of spline segments
nCoeff = 3;  % x = C0 + C1 * t + C2 * t^2
nRows = nDim * nSeg; % number of rows in pp.coeffs
iKnot = 1:2:nGrid; % Indices corresponding to knot points

% Initialize the pp-form data structure
pp.form = 'pp';
pp.breaks = tGrid(iKnot);
pp.coefs = zeros(nRows, nCoeff);
pp.pieces = nSeg;
pp.order = nCoeff;
pp.dim = nDim;

% Subsets of xGrid, useful for vectorization
iUpp = iKnot(2:end);
iMid = iUpp - 1;
iLow = iMid - 1;
xLow = xGrid(:, iLow);
xMid = xGrid(:, iMid);
xUpp = xGrid(:, iUpp);

% Compute the constant term:
C0 = reshape(xLow, nRows, 1);

% Compute the linear term:
h = ones(nDim, 1) * diff(tGrid(iKnot));
hInv = 1.0 ./ h;
C1 = reshape(-hInv.*(3*xLow - 4*xMid + xUpp), nRows, 1);

% Compute the quadratic term:
C2 = reshape(2*hInv.*hInv.*(xLow - 2*xMid + xUpp), nRows, 1);

% Pack up the coefficients:
pp.coefs(:, 1) = C2;
pp.coefs(:, 2) = C1;
pp.coefs(:, 3) = C0;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function ppSpline2b_test()
%
% This function performs a quick unit test to make sure that ppSpline1
% is performing as expected. It also demonstrates how to use this function.
%

% Create a sample data set
nSeg = 6;
nGrid = 2*nSeg + 1;
tGrid = linspace(0, 1, nGrid);
xGrid = [sin(5 * tGrid); cos(8 * tGrid); 2 * tGrid.^2 - tGrid];
dxGrid = [5*cos(5 * tGrid); -8*sin(8 * tGrid); 4 * tGrid - 1];
nDim = size(xGrid, 1);

% Compute the pp-spline:
ppx = ppSpline2b(tGrid, xGrid);
ppdx = ppDer(ppx);

% Interpolate the spline:
t = linspace(tGrid(1), tGrid(end), 400);
x = ppval(ppx, t);
dx = ppval(ppdx, t);

% Plot!
colors = lines(nDim);
figure(1010); clf; 

subplot(2,1,1); hold on;
for iDim = 1:nDim
    plot(t, x(iDim, :), '-', ...
        'LineWidth', 2, 'Color', colors(iDim, :));
    plot(tGrid, xGrid(iDim, :), '*',...
        'LineWidth',2,'MarkerSize', 8, 'Color', colors(iDim, :));
end
xlabel('t')
ylabel('x')
title('ppSpline2a:  unit test');

subplot(2,1,2); hold on;
for iDim = 1:nDim
    plot(t, dx(iDim, :), '-', ...
        'LineWidth', 2, 'Color', colors(iDim, :));
    plot(tGrid, dxGrid(iDim, :), '*',...
        'LineWidth',2,'MarkerSize', 8, 'Color', colors(iDim, :));
end
xlabel('t')
ylabel('dx')

end

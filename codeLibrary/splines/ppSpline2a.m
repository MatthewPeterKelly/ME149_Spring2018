function pp = ppSpline2a(tGrid, xGrid, dxGrid)
% pp = ppSpline2a(tGrid, xGrid, dxGrid)
%
% This function computes a matlab pp-form (piecewise-polynomial) spline
% that is quadratic between knot points. Each segment is constructed using
% the slope at each boundary and the value at the lower boundary:
%
% [xLow, dxLow, dxUpp]  -->  coeff
%
% INPUTS:
%   tGrid = [1, nGrid] = vector of knot points
%   xGrid = [nDim, nGrid] = value at each knot point
%   dxGrid = [nDim, nGrid] = slope at each knot point
%
% OUTPUTS:
%   pp = Matlab pp-form spline that quadratically interpolates the data
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
if nargin == 0, ppSpline2a_test(); return; end

% Check input size:
[nDim, nGrid] = size(xGrid);
[oneCheck, nGridCheck] = size(tGrid);
if oneCheck ~= 1 || nGridCheck ~= nGrid
    error('Invalid input: tGrid must be size [%d, %d]', 1, nGrid);
end
[nDimCheck, nGridCheck] = size(dxGrid);
if nDimCheck ~= nDim || nGridCheck ~= nGrid
    error('Invalid input: dxGrid must be size [%d, %d]', nDim, nGrid);
end

% Size of the coefficient data structure
nCoeff = 3;  % x = C0 + C1 * t + C2 * t^2
nSeg = nGrid - 1 ; % number of spline segments
nRows = nDim * nSeg; % number of rows in pp.coeffs

% Initialize the pp-form data structure
pp.form = 'pp';
pp.breaks = tGrid;
pp.coefs = zeros(nRows, nCoeff);
pp.pieces = nSeg;
pp.order = nCoeff;
pp.dim = nDim;

% Subsets of xGrid, useful for vectorization
xLow = xGrid(:, 1:(end-1));
dxLow = dxGrid(:, 1:(end-1));
dxUpp = dxGrid(:, 2:end);

% Compute the constant term:
C0 = reshape(xLow, nRows, 1);

% Compute the linear term:
C1 = reshape(dxLow, nRows, 1);

% Compute the quadratic term:
h = ones(nDim, 1) * diff(tGrid);
C2 = reshape(0.5*(dxUpp - dxLow)./h, nRows, 1);

% Pack up the coefficients:
pp.coefs(:, 1) = C2;
pp.coefs(:, 2) = C1;
pp.coefs(:, 3) = C0;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function ppSpline2a_test()
%
% This function performs a quick unit test to make sure that ppSpline1
% is performing as expected. It also demonstrates how to use this function.
%

% Create a sample data set
nGrid = 15;  % number of grid points
tGrid = linspace(0, 1, nGrid);
xGrid = [sin(5 * tGrid); cos(8 * tGrid); 2 * tGrid.^2 - tGrid];
dxGrid = [5*cos(5 * tGrid); -8*sin(8 * tGrid); 4 * tGrid - 1];
nDim = size(xGrid, 1);

% Compute the pp-spline:
ppx = ppSpline2a(tGrid, xGrid, dxGrid);
ppdx = ppDer(ppx);

% Interpolate the spline:
t = linspace(tGrid(1), tGrid(end), 250);
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

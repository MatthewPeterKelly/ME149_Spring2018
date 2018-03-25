function pp = ppSpline1(tGrid, xGrid)
% pp = ppSpline1(tGrid, xGrid)
%
% This function computes a matlab pp-form (piecewise-polynomial) spline
% that is linear between the knot points.
%
% INPUTS:
%   tGrid = [1, nGrid] = vector of knot points
%   xGrid = [nDim, nGrid] = state at each knot point
%
% OUTPUTS:
%   pp = Matlab pp-form spline that linearly interpolates the data
%

% Run a unit test if called with no arguments
if nargin == 0, ppSpline1_test(); return; end

% Check input size:
[nDim, nGrid] = size(xGrid);
[oneCheck, nGridCheck] = size(tGrid);
if oneCheck ~= 1 || nGridCheck ~= nGrid
    error('Invalid input: tGrid must be size [%d, %d]', 1, nGrid);
end

% Size of the coefficient data structure
nCoeff = 2;  % x = C0 + C1 * t
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
xUpp = xGrid(:, 2:end);

% Compute the constant term:
C0 = reshape(xLow, nRows, 1);

% Compute the linear term:
h = ones(nDim, 1) * diff(tGrid);
C1 = reshape((xUpp - xLow)./h, nRows, 1);

% Pack up the coefficients:
pp.coefs(:,1) = C1;
pp.coefs(:,2) = C0;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function ppSpline1_test()
%
% This function performs a quick unit test to make sure that ppSpline1
% is performing as expected. It also demonstrates how to use this function.
%

% Create a sample data set
nGrid = 5;  % number of grid points
tGrid = linspace(0, 1, nGrid);
xGrid = [sin(5 * tGrid); cos(8 * tGrid); 2 * tGrid.^2 - tGrid];
nDim = size(xGrid, 1);

% Compute the pp-spline:
pp = ppSpline1(tGrid, xGrid);

% Interpolate the spline:
t = linspace(tGrid(1), tGrid(end), 250);
x = ppval(pp, t);

% Plot!
colors = lines(nDim);
figure(1010); clf; hold on;
for iDim = 1:nDim
    plot(t, x(iDim, :), '-', ...
        'LineWidth', 2, 'Color', colors(iDim, :));
    plot(tGrid, xGrid(iDim, :), '*',...
        'LineWidth',3,'MarkerSize', 10, 'Color', colors(iDim, :));
end
xlabel('t')
ylabel('x')
title('ppSpline1:  unit test');

end

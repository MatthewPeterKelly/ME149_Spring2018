function DEMO_SecondOrderRungeKutta()
%
% DEMO: Second-Order Runge--Kutta Methods
%
% This demo is nearly identical to DEMO_HeunMethodVizualization, but it is
% Generalized to work for any second-order explicit Runge--Kutta method.
%
% As the code runs the simulation it plots each predictor step to help
% visualize what is going on with the method.
%
% Solves:  dx = x
%

clc; clear;
figure(100410); clf; hold on;

dynFun = @(x)( x ); % dx = x
solnFun = @(t)( exp(t) );  % x(t) = exp(t)

% Set the time domain and initial condition
nStep = 1;
tSpan = [0, 2];
x0 = solnFun(tSpan(1)); % make sure that constant of integration matches


%%%% Set the method parameter:   (Family of explicit second-order methods)
%
% alpha = 0.5;  % Midpoint Method
% alpha = 2/3;  % Ralston's Method
% alpha = 1.0;  % Heun's Method
%
alpha = 0.5;  % fractional predictor step length
%
% Compute quadrature weights:
w2 = 1/(2 * alpha);
w1 = 1 - w2;
%
%%%%


% Plot the dynamics function as a vector field:
nArrows = 10;
plotDynFun1D(dynFun, tSpan, [0, 1.1 * solnFun(tSpan(end))], nArrows);
axis tight;

% First plot the solution:
tSoln = linspace(tSpan(1), tSpan(end), 200);
xSoln = solnFun(tSoln);
plot(tSoln, xSoln, 'k-', 'LineWidth', 4);

% Visualize Second-order Runge-Kutta method
h = diff(tSpan) / nStep;
tPrev = tSpan(1);
xPrev = x0;
for iStep = 1:nStep

   % Predictor Step:  (Euler's method, for a fraction of the step)
   vPrev = dynFun(xPrev);
   tTmp = tPrev + alpha * h;
   xTmp = xPrev + alpha * h * vPrev;

   % Now compute the dynamics at that new point:
   vTmp = dynFun(xTmp);

   % Estimate the dynamics as a weighted average:
   vNew = w1 * vPrev + w2 * vTmp;

   % Use the dynamics estimate to take a better Euler step:
   tNext = tPrev + h;
   xNext = xPrev + h * vNew;

   % Plot the "predictor" step
   plot([tPrev, tTmp],[xPrev, xTmp], 'r--', 'LineWidth', 2);

   % Plot the "corrector" step
   plot([tPrev, tNext],[xPrev, xNext], 'b-', 'LineWidth', 3);

   % Update the variables:
   tPrev = tNext;
   xPrev = xNext;

end

% Annotations for the plot:
xlabel('t')
ylabel('x')
title(['Second-Order Runge--Kutta (alpha=', num2str(alpha), ') solution:  dx = x']);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotDynFun1D(dynFun, tSpan, zSpan, nArrow)

% Create the grid along each dimension
t = linspaceInterior(tSpan(1), tSpan(end), nArrow);
z = linspaceInterior(zSpan(1), zSpan(end), nArrow);

% Use meshgrid to expand t and z into a 2D grid for plotting:
[tt, zz] = meshgrid(t, z);

% Evaluate the dynamics function at every point in tt and zz:
dd = dynFun(zz);

% Plot a vector field:
scale = 0.5;
quiver(tt, zz, ones(size(dd)), dd, scale, ...
    'LineWidth', 2, 'Color', 0.5 * [1,1,1]);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function t = linspaceInterior(tLow, tUpp, nGrid)

% Linspace with an extra point
tt = linspace(tLow, tUpp, nGrid + 1);

% return the set of points that are exactly between points in tt
t = 0.5*(tt(1:(end-1)) + tt(2:end));

end

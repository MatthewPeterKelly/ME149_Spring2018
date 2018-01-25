% DEMO - Heun's Method
%
% Illustrate how Heun's method works by solving: dx = x
%

clc; clear;
figure(100400); clf; hold on;

dynFun = @(x)( x ); % dx = x
solnFun = @(t)( exp(t) );  % x(t) = exp(t)

% Set the time domain and initial condition
nStep = 2;
tSpan = [0, 2];
x0 = solnFun(tSpan(1)); % make sure that constant of integration matches

% Plot the dynamics function as a vector field:
nArrows = 15;
plotDynFun1D(dynFun, tSpan, [0, 1.1 * solnFun(tSpan(end))], nArrows);
axis tight;

% First plot the solution:
tSoln = linspace(tSpan(1), tSpan(end), 200);
xSoln = solnFun(tSoln);
plot(tSoln, xSoln, 'k-', 'LineWidth', 4);

% Visualize Heun's method
h = diff(tSpan) / nStep;
tPrev = tSpan(1);
xPrev = x0;
for iStep = 1:nStep
    
   % First use Euler's method to predict the next state:
   vPrev = dynFun(xPrev);
   xTmp = xPrev + h * vPrev;   
   
   % Now use xTmp to predict the dynamics at the next step:
   vTmp = dynFun(xTmp);
   
   % Now take the average to get a better estimate for dynamics:
   vMean = 0.5*(vTmp + vPrev);
   
   % Use the new dynamics estimate to take a better Euler step:
   tNext = tPrev + h;
   xNext = xPrev + h * vMean;
   
   % Plot the "predictor" step
   plot([tPrev, tNext],[xPrev, xTmp], 'r--', 'LineWidth', 2);
   
   % Plot the "corrector" step
   plot([tPrev, tNext],[xPrev, xNext], 'b-', 'LineWidth', 3);
   
   % Update the variables:
   tPrev = tNext;
   xPrev = xNext;  
   
end

% Annotations for the plot:
xlabel('t')
ylabel('x')
title('Heun''s method solution:  dx = x');
legend('dyamics function','solution','predictor step','Heun''s Method',...
       'Location', 'NorthWest');

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

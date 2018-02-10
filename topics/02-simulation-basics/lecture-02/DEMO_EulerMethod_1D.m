function DEMO_EulerMethod_1D()
%
%%%% DEMO:  Euler's method in one dimension
%
% This demo shows how to use Euler's method to simulate the simplest
% first-order system: dx = x
%
% We then go on to compare Euler's method with different step sizes to the
% analytic solution.
%

% Clear the workspace and create a new figure:
clc; clear;
hFigOne = figure(20010); clf; hold on;

% Add the code library to the local path:
cd(fileparts(mfilename('fullpath')));
run('../../../codeLibrary/addLibraryToPath.m');

% Create a function handle for the system:  dz = z
dynFun = @(t, z)( z );

% We can easily see that the solution is z(t) = z0 * exp(t)
z0 = 1;  % z(0) = initial state
solnFun = @(t)( z0 * exp(t) );

% Set the time-span over which we will study the system:
tSpan = [0, 2];

% Plot the dynamics as a vector field:
zSpan = [0, 8];  % range of z values over which to plot
nArrow = 15;  % how many arrows to show in the plot?
plotDynFun1D(dynFun, tSpan, zSpan, nArrow);

% Plot the solution on top of the vector field:
tSoln = linspace(tSpan(1), tSpan(2), 150);
zSoln = solnFun(tSoln);
plot(tSoln, zSoln, 'k-', 'LineWidth', 5);

% Plot the approximation obtained by a single Euler step:
nStepVec = 2.^(0:18);
errVec = zeros(size(nStepVec));
maxStepPlot = 20;
for iEuler = 1:length(nStepVec)
    nStep = nStepVec(iEuler);
    [tEuler, zEuler] = eulerSimScalar(dynFun, tSpan, z0, nStep);
    errVec(iEuler) = solnFun(tSpan(end)) - zEuler(end);
    if nStep < maxStepPlot
        plot(tEuler, zEuler, '-o', ...
            'LineWidth', 3, 'MarkerSize', 8);
    end
end

% Create the legend:
plotNames = cell(2+sum(nStepVec < maxStepPlot), 1);
plotNames{1} = 'dynamics';
plotNames{2} = 'solution';
for iEuler = 1:length(nStepVec)
    nStep = nStepVec(iEuler);
    if nStep < 20
        plotNames{iEuler + 2} = ['euler ', num2str(nStep), ' step'];
    end
end
legend(plotNames, 'Location', 'NorthWest', 'FontSize', 14)

% Other annotations:
xlabel('time', 'FontSize', 14)
ylabel('state', 'FontSize', 14)
title('Euler''s method:  exponential simulation', 'FontSize', 16);

% Plot the error as a function of step count:
hFigTwo = figure(20011); clf;
loglog(nStepVec, errVec, 'r-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Number of Euler Steps', 'FontSize', 14)
ylabel('Error in final state', 'FontSize', 14)
title('Euler''s method: error vs step count', 'FontSize', 16);

% Save the figures
% writeFiguresToFiles(hFigOne, hFigTwo)

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotDynFun1D(dynFun, tSpan, zSpan, nArrow)

% Create the grid along each dimension
t = linspaceInterior(tSpan(1), tSpan(end), nArrow);
z = linspaceInterior(zSpan(1), zSpan(end), nArrow);

% Use meshgrid to expand t and z into a 2D grid for plotting:
[tt, zz] = meshgrid(t, z);

% Evaluate the dynamics function at every point in tt and zz:
dd = dynFun(tt, zz);

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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [t, z] = eulerSimScalar(dynFun, tSpan, z0, nStep)

% Setup:
t = linspace(tSpan(1), tSpan(2), nStep + 1);  % time grid
z = zeros(1, nStep + 1);  % state grid
z(1) = z0;  % initial condition
h = (tSpan(end) - tSpan(1)) / nStep;  % time step

% Simulation:
for k = 1:nStep
    % [next state] = [prev state] + [change in state]
    z(k+1) = z(k) + h * dynFun(t(k), z(k));
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function writeFiguresToFiles(hFigOne, hFigTwo)

% Set the desired figure sizes:
set(hFigOne,'Position', [100, 100, 900, 600]);
set(hFigTwo,'Position', [100, 100, 900, 600]);

% Save figure as a pdf file:
saveFigureToPdf('DEMO_EulerMethod_1D_ErrorAnalysis', hFigOne);
saveFigureToPdf('DEMO_EulerMethod_1D_Simulation', hFigTwo);

% Save figure as a png file:
resolution = 200;  % dpi
saveFigureToPng('DEMO_EulerMethod_1D_Simulation', hFigOne, resolution);
saveFigureToPng('DEMO_EulerMethod_1D_ErrorAnalysis', hFigTwo, resolution);

end

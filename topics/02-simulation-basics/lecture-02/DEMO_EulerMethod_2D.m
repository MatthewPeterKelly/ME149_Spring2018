function DEMO_EulerMethod_2D()
%
%%%% DEMO:  Euler's method in two dimensions
%
% This demo shows how to use Euler's method to simulate a simple pendulum,
% a simple non-linear second-order system. In order to solve, we will
% first turn it into a set of coupled first-order differential equations.
%
% Since there is no (reasonable) analytic solution, we will use ode45
% as the "true" solution.
%

% Clear the workspace and create a new figure:
clc; clear;
figure(20020); clf; hold on;

% Add the code library to the local path:
cd(fileparts(mfilename('fullpath')));
run('../../../codeLibrary/addLibraryToPath.m');

% Create a function handle for the first-order form:
dynFun = @(t, z)( pendulumDynamics(z) );

% Set the initial state of the system:
q0 = 0.0;  % initial angle, in radians
w0 = 1.9;  % initial angular rate, in radians per second
z0 = [q0; w0];  % combined first-order state

% Set the time-span over which we will study the system:
tSpan = [0, 6];

% Plot the dynamics as a vector field:
qSpan = [-4, 12];  % range of angles over which to plot the dynamics
wSpan = [-3, 3];  % range of angular rates over which to plot the dynamics
nArrow = 30;  % how many arrows to show in the plot?
plotDynFun2D(dynFun, qSpan, wSpan, nArrow);

% Compute and plot the "true" solution using ode45 (black box for now)
options = odeset('AbsTol', 1e-12, 'RelTol', 1e-12);
tSoln = linspace(tSpan(1), tSpan(end), 200);
[tSoln, zSoln] = ode45(dynFun, tSoln, z0, options);  zSoln = zSoln';
qSoln = zSoln(1, :);
wSoln = zSoln(2, :);
plot(qSoln, wSoln, 'k-', 'LineWidth', 5);

% Plot the approximation obtained by a single Euler step:
nStepVec = [8, 16, 32, 64, 128];
for nStep = nStepVec
    [~, zEuler] = eulerSimVector(dynFun, tSpan, z0, nStep);
    plot(zEuler(1,:), zEuler(2,:), '-o', ...
         'LineWidth', 2, 'MarkerSize', 4);
end

% Create the legend:
plotNames = cell(2+length(nStepVec), 1);
plotNames{1} = 'dynamics';
plotNames{2} = 'solution';
for iEuler = 1:length(nStepVec)
   plotNames{iEuler + 2} = ['euler ', num2str(nStepVec(iEuler)), ' step'];
end
legend(plotNames, 'Location', 'SouthEast', 'FontSize', 14)

% Other annotations:
xlabel('angle (rad)', 'FontSize', 14)
ylabel('rate (rad/sec)', 'FontSize', 14)
title('Euler''s method:  pendulum simulation', 'FontSize', 16);
axis tight

% Write figures to files:
% set(gcf,'Position', [100, 100, 900, 600]);
% saveFigureToPdf('DEMO_EulerMethod_2D');
% saveFigureToPng('DEMO_EulerMethod_2D');

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function dz = pendulumDynamics(z)
% dz = pendulumDynamics(z)
%
% Compute the dynamics of a simple pendulum in first-order form.
%
% INPUTS:
%   z = [2, n] = [q; w] = state of the system
%
% OUTPUTS:
%   dz = [2, n] = [dq; dw] = first time derivative of the state
%
% NOTES:
%
%   pendulum dynamics as second-order system:
%     ddq = -sin(q)
%
%   pendulum dynamics written in "first-order form". Let w = dq.
%     dq = w
%     dw = -sin(q)
%

% unpack the state
q = z(1,:);
w = z(2,:);

% compute the dynamics
dq = w;
dw = -sin(q);

% pack up the derivatives
dz = [dq; dw];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotDynFun2D(dynFun, qSpan, wSpan, nArrow)

% Create the grid along each dimension
q = linspaceInterior(qSpan(1), qSpan(end), nArrow);
w = linspaceInterior(wSpan(1), wSpan(end), nArrow);

% Use meshgrid to expand q and w into a 2D grid for plotting:
[qq, ww] = meshgrid(q, w);

% Compute the dynamics for each point
dqq = zeros(size(qq));
dww = zeros(size(qq));
t = [];  % t is an unused input for dynamics function
for iArrow = 1:nArrow
    z = [qq(iArrow, :); ww(iArrow, :)];
    dz = dynFun(t, z);
    dqq(iArrow, :) = dz(1,:);
    dww(iArrow, :) = dz(2,:);
end

% Plot a vector field:
scale = 0.6;
quiver(qq, ww, dqq, dww, scale, ...
    'LineWidth', 1, 'Color', 0.6 * [1,1,1]);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function t = linspaceInterior(tLow, tUpp, nGrid)

% Linspace with an extra point
tt = linspace(tLow, tUpp, nGrid + 1);

% return the set of points that are exactly between points in tt
t = 0.5*(tt(1:(end-1)) + tt(2:end));

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [t, z] = eulerSimVector(dynFun, tSpan, z0, nStep)

% Setup:
t = linspace(tSpan(1), tSpan(2), nStep + 1);  % time grid
z = zeros(length(z0), nStep + 1);  % state grid
z(:, 1) = z0;  % initial condition
h = (tSpan(end) - tSpan(1)) / nStep;  % time step

% Simulation:
for k = 1:nStep
    % [next state] = [prev state] + [change in state]
    z(:, k+1) = z(:, k) + h * dynFun(t(k), z(:, k));
end
end

% In class demo - January 25, 2018
%
% Second-order Runge-Kutta Simulation
%

clc; clear;

% Set pendulum parameters
param.g = 9.81;   %gravity (m/s)
param.l = 2;  % length (m)

% Simulation parameters:
nGrid = 200;

% Simulate a pendulum with ode45
tGrid = linspace(0, 8, nGrid);
z0 = [0.01; 0];   % [angle; rate]
dynFun = @(t, z)( pendulumDynamics(t, z, param) );
options = odeset('RelTol', 1e-12, 'AbsTol', 1e-12);  % options for ode45
[tOde45, zOde45] = ode45(dynFun, tGrid, z0, options);
tOde45 = tOde45';  zOde45 = zOde45';  % transpose vectors to match convention in the rest of the code

% Simulate the pendulum with Euler's method:
zEuler = zeros(2, nGrid);
zEuler(:, 1) = z0;  % set initial state
h = tGrid(2) - tGrid(1);  % time step
for iGrid = 1:(nGrid-1)
    % rename local variables:
    tPrev = tGrid(iGrid);
    zPrev = zEuler(:, iGrid);
    
    % Compute the dynamics function:
    dzPrev = dynFun(tPrev, zPrev);
    
    % Euler's method:
    zEuler(:, iGrid+1) = zPrev + h * dzPrev;  % this has two rows
end

% Simulate the pendulum with Heun's method:
zHeun = zeros(2, nGrid);
zHeun(:, 1) = z0;  % set initial state
for iGrid = 1:(nGrid-1)
    % rename local variables:
    tPrev = tGrid(iGrid);
    tNext = tGrid(iGrid + 1);
    zPrev = zHeun(:, iGrid);
    
    % Compute the dynamics function at initial point
    dzPrev = dynFun(tPrev, zPrev);
    
    % Euler's step to obtain estimate
    zNextPredicted = zPrev + h * dzPrev;  % approximation
    dzNext = dynFun(tNext, zNextPredicted);
    
    % Take the average
    dzAvg = 0.5 * (dzPrev + dzNext);
    
    % Take the euler step with the new estimate
    zHeun(:, iGrid+1) = zPrev + h * dzAvg;
end

% Make a plot:
hFig = figure(1000); clf;

subplot(2,1,1); hold on;   % angle
plot(tOde45, zOde45(1,:), 'r-', 'LineWidth', 5);
plot(tGrid, zEuler(1,:), 'b-', 'LineWidth', 2);
plot(tGrid, zHeun(1,:), 'g-', 'LineWidth', 2);
xlabel('time (s)');
ylabel('angle (rad)');
title('Pendulum Simulation');
legend('ode45', 'euler', 'heun');

subplot(2,1,2); hold on;   % rate
plot(tOde45, zOde45(2,:), 'r-', 'LineWidth', 5);
plot(tGrid, zEuler(2,:), 'b-', 'LineWidth', 2);
plot(tGrid, zHeun(2,:), 'g-', 'LineWidth', 2);
xlabel('time (s)');
ylabel('rate (rad/s)');
legend('ode45', 'euler', 'heun');


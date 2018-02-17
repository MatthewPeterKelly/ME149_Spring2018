% DEMO - Use trajectory optimization to compute the optimal swing-up for
%        a simple pendulum (torque-squared objective)
%
% Demonstrates simple swing-up for a single pendulum with a torque motor.
%

clc; clear;
run('../../../codeLibrary/addLibraryToPath.m');
checkForOptimTraj();  % Make sure that OptimTraj is installed

% Physical parameters of the pendulum
param.freq = 1;  % Normalized gravity constant
param.damp = 0;  % Normalized damping constant

% Trajectory parameters:
duration = 3;
startState = [0; 0];  % [angle; rate]
finalState = [pi; 0];  % [angle; rate]

% User-defined dynamics and objective functions
problem.func.dynamics = @(t, x, u)( simplePendulumDynamics(x, u, param) );
problem.func.pathObj = @(t, x, u)( u.^2 );

% Problem bounds
problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = duration;
problem.bounds.finalTime.upp = duration;

problem.bounds.initialState.low = startState;
problem.bounds.initialState.upp = startState;
problem.bounds.finalState.low = finalState;
problem.bounds.finalState.upp = finalState;

% Guess at the initial trajectory
problem.guess.time = [0, duration];
problem.guess.state = [startState, finalState];
problem.guess.control = [0, 0];

% Select a solver:
problem.options(1).method = 'trapezoid';
problem.options(2).method = 'hermiteSimpson';
problem.options(2).defaultAccuracy = 'high';

% Solve the problem
soln = optimTraj(problem);

% Unpack the solution for plotting
S = soln(end);
t = linspace(0, duration, 250);
z = S.interp.state(t);
q = z(1,:);
dq = z(2,:);
u = S.interp.control(t);

% Plot the solution:
figure(4050); clf;

subplot(3,1,1)
plot(t, q, 'LineWidth', 2)
ylabel('q', 'FontSize', 14)
xlabel('t', 'FontSize', 14)
title('Single Pendulum Swing-Up');

subplot(3,1,2)
plot(t, dq, 'LineWidth', 2)
ylabel('dq', 'FontSize', 14)
xlabel('t', 'FontSize', 14)

subplot(3,1,3)
plot(t, u, 'LineWidth', 2)
ylabel('u', 'FontSize', 14)
xlabel('t', 'FontSize', 14)
title(sprintf('Optimal Cost: %6.6f', S.info.objVal));



% MAIN  --  Simple Pendulum Swing-Up
%
% Solves the minimum-effort swing-up for a simple pendulum using 
% the trapezoid method for direct collocation.
%
% Demo:   adjust the parameters!
%
%    --> Can you find a set of parameters that does swings backward before
%    the final swing-up?
%
%   --> Adjust ALL of the parameters below and see what happens
% 

run('../../../codeLibrary/addLibraryToPath.m');
clc; clear;

% Duration and number of grid points:
nGrid = 50;
duration = 4.0;

% Boundary states:
xBegin = [0; 0];
xFinal = [pi; 0];

% Dynamics function:
param = struct('freq', 5, 'damp', 0.05);
problem.func.dynamics = @(t, x, u)( simplePendulumDynamics(x, u, param) );

% Path integral:  (minimize the integral of actuation-squared)
problem.func.pathObj = @(t, x, u)( u.^2 );

% Boundary constraint:
problem.func.bndCst = @(t0, tF, x0, xF)( ...
                        deal([], [x0 - xBegin; xF - xFinal]) );

% Initial guess: (cubic segment, matching boundary conditions)
problem.guess.time = linspace(0, duration, nGrid);
ppAngle = pwch([0, duration], [xBegin(1), xFinal(1)], [xBegin(2), xFinal(2)]);
ppRate = ppDer(ppAngle);
angleGuess = ppval(ppAngle, problem.guess.time);
rateGuess = ppval(ppRate, problem.guess.time);
problem.guess.state = [angleGuess; rateGuess];
problem.guess.control = zeros(1, nGrid);              

% Set the options for FMINCON
problem.nlpOpt = optimoptions('fmincon');
problem.nlpOpt.Display = 'iter';
problem.nlpOpt.OptimalityTolerance = 1e-6;
problem.nlpOpt.ConstraintTolerance = 1e-10;
problem.nlpOpt.MaxFunctionEvaluations = 1e5;

% Call the optimization:
soln = dirColBvpTrap(problem);

%% Make some plots:
figure(8010); clf;
t = soln.grid.time;
q = soln.grid.state(1,:);
w = soln.grid.state(2,:);
u = soln.grid.control;
tBnd = t([1, end]);
bndMarker = 'ks';
bndSize = 8;
lineWidth = 2;

% Angle
subplot(3,1,1); hold on;
plot(t, q, 'LineWidth', lineWidth)
plot(tBnd, [xBegin(1); xFinal(1)], ...
    bndMarker, 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('angle (rad)');
title('Simple Pendulum BVP  --  Min. Effort')

% Rate
subplot(3,1,2); hold on;
plot(t, w, 'LineWidth', lineWidth);
plot(tBnd, [xBegin(2); xFinal(2)], ...
    bndMarker, 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('rate (rad/s)');

% Torque
subplot(3,1,3); hold on;
plot(tBnd, [0,0], 'k--');
plot(t,u, 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('torque (Nm)');
title(sprintf('ObjVal: %4.4f', soln.info.objVal));


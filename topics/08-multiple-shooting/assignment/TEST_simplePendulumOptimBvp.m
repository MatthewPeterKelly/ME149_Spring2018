% TEST  --  Simple Pendulum Swing-Up
%
% Entry-point for a simple test script to run simplePendulumOptimBvp()
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

% Parameters for the pendulum
param = struct('freq', 5, 'damp', 0.05);

% Configuration for the trajectory optimization problem:
config = struct(...
    'nStep', 50, ... % Number of integration steps
    'beginState', [0; 0], ... % initial state:  [angle; rate]
    'finalState', [pi; 0], ... % final state:  [angle; rate]
    'duration', 5.0);  % duration of the trajectory

% Set the options for FMINCON
nlpOpt = optimoptions('fmincon');
nlpOpt.Display = 'iter';
nlpOpt.OptimalityTolerance = 1e-6;
nlpOpt.ConstraintTolerance = 1e-10;
nlpOpt.MaxFunctionEvaluations = 1e5;

% Call the optimization:
soln = simplePendulumOptimBvp(config, param, nlpOpt);

% Uncomment the following line to call the solution (as p-code)
% soln = simplePendulumOptimBvpSoln(config, param, nlpOpt);

%% Make some plots:
figure(8010); clf;
t = soln.grid.time;
q = soln.grid.state(1,:);
w = soln.grid.state(2,:);
u = soln.grid.control;
tBnd = [0, config.duration];
bndMarker = 'ks';
bndSize = 8;
lineWidth = 2;

% Angle
subplot(3,1,1); hold on;
plot(t, q, 'LineWidth', lineWidth)
plot(tBnd, [config.beginState(1); config.finalState(1)], ...
    bndMarker, 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('angle (rad)');
title('Simple Pendulum BVP  --  Min. Effort')

% Rate
subplot(3,1,2); hold on;
plot(t, w, 'LineWidth', lineWidth);
plot(tBnd, [config.beginState(2); config.finalState(2)], ...
    bndMarker, 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('rate (rad/s)');

% Torque
subplot(3,1,3); hold on;
plot(tBnd, [0,0], 'k--');
stairs(t,[u,u(end)], 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('torque (Nm)');
title(sprintf('ObjVal: %4.4f', soln.info.objVal));


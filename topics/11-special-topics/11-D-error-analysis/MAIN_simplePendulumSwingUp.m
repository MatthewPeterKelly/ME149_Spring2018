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
nSeg = 15;
duration = 2.0;

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
problem.guess.time = linspace(0, duration, nSeg + 1);
ppAngle = pwch([0, duration], [xBegin(1), xFinal(1)], [xBegin(2), xFinal(2)]);
ppRate = ppDer(ppAngle);
angleGuess = ppval(ppAngle, problem.guess.time);
rateGuess = ppval(ppRate, problem.guess.time);
problem.guess.state = [angleGuess; rateGuess];
problem.guess.control = zeros(1, nSeg + 1);              

% Set the options for FMINCON
problem.nlpOpt = optimset('fmincon');
problem.nlpOpt.Display = 'iter';
problem.nlpOpt.TolFun = 1e-6;
problem.nlpOpt.TolCon = 1e-10;
problem.nlpOpt.MaxIter = 250;
problem.nlpOpt.MaxFunEvals = 1e5;

% Call the optimization:
soln = dirColBvpHermiteSimpson(problem);

%% Make some plots:

% Interpolate the solution
t = linspace(0, duration, 250);
x = ppval(soln.spline.state, t);
q = x(1,:);
w = x(2,:);
u = ppval(soln.spline.control, t);

%% Create a nice figure!
figure(8010); clf;
tGrid = soln.grid.time;
qGrid = soln.grid.state(1,:);
wGrid = soln.grid.state(2,:);
uGrid = soln.grid.control;
tKnot = soln.knots.time;
qKnot = soln.knots.state(1,:);
wKnot = soln.knots.state(2,:);
uKnot = soln.knots.control;
tBnd = tGrid([1, end]);

% Annotations:
bndMarker = 'ks';
bndSize = 8;
lineWidth = 2;
heavyLine = 3;
gridMarker = 'bo';
gridMarkerSize = 6;
knotMarker = 'rs';
knotMarkerSize = 8;

% Angle
subplot(3,1,1); hold on;
plot(tGrid, qGrid, gridMarker, 'LineWidth', lineWidth, 'MarkerSize', gridMarkerSize);
plot(tKnot, qKnot, knotMarker, 'LineWidth', heavyLine, 'MarkerSize', knotMarkerSize);
plot(t, q, 'k-', 'LineWidth', lineWidth)
plot(tBnd, [xBegin(1); xFinal(1)], ...
    bndMarker, 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('angle (rad)');
title('Simple Pendulum BVP  --  Min. Effort')

% Rate
subplot(3,1,2); hold on;
plot(tGrid, wGrid, gridMarker, 'LineWidth', lineWidth, 'MarkerSize', gridMarkerSize);
plot(tKnot, wKnot, knotMarker, 'LineWidth', heavyLine, 'MarkerSize', knotMarkerSize);
plot(t, w, 'k-', 'LineWidth', lineWidth)
plot(tBnd, [xBegin(2); xFinal(2)], ...
    bndMarker, 'LineWidth', lineWidth);
xlabel('time (s)');
ylabel('rate (rad/s)');

% Torque
subplot(3,1,3); hold on;
plot(tBnd, [0,0], 'k--');
plot(t, u, 'k-', 'LineWidth', lineWidth)
plot(tGrid, uGrid, gridMarker, 'LineWidth', lineWidth, 'MarkerSize', gridMarkerSize);
plot(tKnot, uKnot, knotMarker, 'LineWidth', heavyLine, 'MarkerSize', knotMarkerSize);
xlabel('time (s)');
ylabel('torque (Nm)');
title(sprintf('ObjVal: %4.4f', soln.info.objVal));


%% Plot the discretization error analysis:

figure(8020); clf;
xErr = soln.analysis.collCstErr(t);
qErr = xErr(1, :);
wErr = xErr(2, :);

% collocation error for angle:
subplot(3,1,1); hold on;
plot(tGrid, 0*qGrid, gridMarker, 'LineWidth', lineWidth, 'MarkerSize', gridMarkerSize);
plot(tKnot, 0*qKnot, knotMarker, 'LineWidth', heavyLine, 'MarkerSize', knotMarkerSize);
plot(t, qErr, 'k-', 'LineWidth', lineWidth)
xlabel('time (s)');
ylabel('angle error rate (rad/s)');
title('Simple Pendulum BVP  --  Min. Effort  --  Discretization Error');

% collocation error for angle:
subplot(3,1,2); hold on;
plot(tGrid, 0*wGrid, gridMarker, 'LineWidth', lineWidth, 'MarkerSize', gridMarkerSize);
plot(tKnot, 0*wKnot, knotMarker, 'LineWidth', heavyLine, 'MarkerSize', knotMarkerSize);
plot(t, wErr, 'k-', 'LineWidth', lineWidth)
xlabel('time (s)');
ylabel('rate error rate (rad/s^2)');

% Error by segment:
subplot(3,1,3); hold on;
tMid = 0.5*( tKnot(1:(end-1)) + tKnot(2:end) );
segErr = max(soln.analysis.meshErr, [], 1);
plot(tBnd, [0,0], 'k-', 'LineWidth', 1);
plot(tMid, segErr, knotMarker, 'LineWidth', heavyLine, 'MarkerSize', knotMarkerSize);
set(gca, 'XTick', tMid, 'XTickLabel',1:length(tMid))
xlabel('segment index');
ylabel('error estimate');




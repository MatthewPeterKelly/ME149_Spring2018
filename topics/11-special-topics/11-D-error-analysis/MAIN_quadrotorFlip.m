% MAIN  --  Quadrotor Flip
%
% Solves a minimal-effort flip maneuver for a planar quadrotor model,
% using trapezoid direct collocation
%
% Demo:   adjust the parameters and see what happens!
% 

run('../../../codeLibrary/addLibraryToPath.m');
clc; clear;

% Duration and number of grid points:
nSeg = 25;
nGridGuess = nSeg + 1;
duration = 1.0;

% Boundary states:
xBegin = [0; % horizontal position
          0; % vertical position
          0; % angle
          zeros(3,1)];
xFinal = [1; % horizontal position
          0; % vertical position
          2*pi; % angle
          zeros(3,1)];

% Dynamics function:
param = struct('m', 0.5, 'w', 0.5, 'g', 5);
problem.func.dynamics = @(t, x, u)( planarQuadrotorDynamics(x, u, param) );

% Path integral:  (minimize the integral of actuation-squared)
problem.func.pathObj = @(t, x, u)( sum(u.^2, 1) );

% Boundary constraint:
problem.func.bndCst = @(t0, tF, x0, xF)( ...
                        deal([], [x0 - xBegin; xF - xFinal]) );

% Initial guess: (cubic segment, matching boundary conditions)
problem.guess.time = linspace(0, duration, nGridGuess);
ppAngle = pwch([0, duration], [xBegin(1:3), xFinal(1:3)], ...
                              [xBegin(4:6), xFinal(4:6)]);
ppRate = ppDer(ppAngle);
angleGuess = ppval(ppAngle, problem.guess.time);
rateGuess = ppval(ppRate, problem.guess.time);
problem.guess.state = [angleGuess; rateGuess];
problem.guess.control = zeros(2, nGridGuess);              

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
figure(8015); clf;
t = linspace(0, duration, 200);
x = ppval(soln.spline.state, t);
u = ppval(soln.spline.control, t);
planarQuadrotorPlot(t, x, u, param);

% Show some information about the optimization:
subplot(3, 2, 6);
axis([-1,1,-1,1]); axis off;
hText = text(-0.8,0,...
             {sprintf('NLP Time: %3.3f seconds', soln.info.nlpTime);
              sprintf('NLP exit code: %d', soln.info.exitFlag);
              sprintf('NLP iteration count: %d', soln.info.iterations);
              sprintf('NLP function evaluation count: %d', soln.info.funcCount);
              sprintf('Objective Function: %6.6f', soln.info.objVal)});
set(hText,'HorizontalAlignment','left');
set(hText,'VerticalAlignment','middle');
    

%% Plot the discretization error:
figure(8025); clf;
zErr = soln.analysis.collCstErr(t);
xErr = zErr(1, :);
yErr = zErr(2, :);
qErr = zErr(3, :);
dxErr = zErr(4, :);
dyErr = zErr(5, :);
dqErr = zErr(6, :);

% Plots:
hSub(1) = subplot(2, 2, 1); hold on;
plot(t, xErr, 'r-', 'lineWidth', 2);
plot(t, yErr, 'b-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('position error rate (m/s)')
title('center of mass position error rate')
legend('x','y');

hSub(2) = subplot(2, 2, 2); hold on;
plot(t, dxErr, 'r-', 'lineWidth', 2);
plot(t, dyErr, 'b-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('velocity error rate (m/s^2)')
title('center of mass velocity error rate')
legend('dx','dy');

hSub(3) = subplot(2, 2, 3);
plot(t, qErr, 'k-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('angle error rate (rad/s)')
title('quadrotor angle error rate')

hSub(4) = subplot(2, 2, 4);
plot(t, dqErr, 'k-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('rate error rate (rad/s^2)')
title('quadrotor anglular rate error rate')

linkaxes(hSub, 'x');





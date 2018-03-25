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
nGrid = 30;
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
problem.guess.time = linspace(0, duration, nGrid);
ppAngle = pwch([0, duration], [xBegin(1:3), xFinal(1:3)], ...
                              [xBegin(4:6), xFinal(4:6)]);
ppRate = ppDer(ppAngle);
angleGuess = ppval(ppAngle, problem.guess.time);
rateGuess = ppval(ppRate, problem.guess.time);
problem.guess.state = [angleGuess; rateGuess];
problem.guess.control = zeros(2, nGrid);              

% Set the options for FMINCON
problem.nlpOpt = optimoptions('fmincon');
problem.nlpOpt.Display = 'iter';
problem.nlpOpt.OptimalityTolerance = 1e-6;
problem.nlpOpt.ConstraintTolerance = 1e-8;
problem.nlpOpt.MaxFunctionEvaluations = 2e5;

% Call the optimization:
soln = dirColBvpTrap(problem);

%% Make some plots:
figure(8010); clf;
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
    



% DEMO - Use trajectory optimization to compute the optimal swing-up for
%        a simple pendulum (torque-squared objective)
%
% Demonstrates simple swing-up for a single pendulum with a torque motor.
%
function DEMO_doublePendulum_optimalSwingUp()

run('../../../codeLibrary/addLibraryToPath.m');
checkForOptimTraj();  % Make sure that OptimTraj is installed

%%%% NOTE:
%   
% The behavior described in the assignment is actually a swing-down
% maneuver for the double pendulum, because the origin is defined to be the
% inverted state. Here I compute both the swing-up and the swing-down
% maneuvers. Interestingly they are identical, except for being flipped in
% time: the optimal swing-up trajectory is the optimal swing-down
% trajectory run in reverse.
%
%%%%

% Physical parameters of the pendulum
param.m1 = 1;  % link one mass
param.m2 = 1;  % link two mass
param.d1 = 1;  % link one length
param.d2 = 1;  % link two length
param.g = 1;  % gravity

% Trajectory parameters:
duration = 5;
upState = [0; 0; 0; 0];  % [angles; rates]
downState = [pi; pi; 0; 0];  % [angles; rates]

% Solve optimal swing-down:
figure(4060); clf;
computeOptimalTrajectory(param, duration, downState, upState, 'Single Pendulum Swing-Up');
saveFigureToPdf('doublePendulumSwingUp.pdf');

figure(4065); clf;
computeOptimalTrajectory(param, duration, upState, downState, 'Single Pendulum Swing-Down');
saveFigureToPdf('doublePendulumSwingDown.pdf');

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function computeOptimalTrajectory(param, duration, startState, finalState, name)

% User-defined dynamics and objective functions
problem.func.dynamics = @(t, x, u)( doublePendulumDynamics(x, u, param) );
problem.func.pathObj = @(t, x, u)( sum(u.^2, 1) );

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
problem.guess.control = [zeros(2,1), zeros(2,1)];

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
u = S.interp.control(t);

% Plot the solution:
doublePendulumPlot(t, z, u, param);
subplot(2,3,2);
title({name; 'link two angle'});
subplot(2,3,6);
objStr = sprintf('Obj Val = %6.6f', S.info.objVal);
title({objStr; 'control torque'});

end

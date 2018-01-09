% MAIN  --  passive simulation of the double pendulum
%
% This script runs a passive simulation of the double pendulum, showing how to
% call the dynamics and analysis functions. It also checks that mechanical
% energy is conserved, as a quick check on the dynamics.
%
% Things to try:
%
% 1) Adjust the parameters and states and see if you can guess what will
% happen when you run the simulation. What if one mass or length is much
% bigger than the other? Can you make the system behave like a single
% pendulum?
%
% 2) Type:      >> help animate
% to see the keyboard commands for controlling the animation. You can use
% then to see the system in slow motion, pause, or go back in time, to name
% a few possiblities. This is useful for understanding what the system is
% doing.
%

clc; clear;
cd(fileparts(mfilename('fullpath')));
run('../../addLibraryToPath.m');

% Physical parameters
param.m1 = 1;
param.m2 = 1;
param.g = 1;
param.d1 = 1;
param.d2 = 1;

% Initial state:
q1 = (pi/180) * 5;
q2 = (pi/180) * -10;
dq1 = 0;
dq2 = 0;
z0 = [q1; q2; dq1; dq2];  %Pack up initial state

tSpan = [0,8];  %time span for the simulation
ctrlFun = @(t, z)( zeros(2, length(t)) );  % passive controller
dynFun = @(t, z)( doublePendulumDynamics(z, ctrlFun(t, z), param) );  %dynamics function

% Run simulation:
options = odeset('RelTol', 1e-10, 'AbsTol', 1e-10);
soln = ode45(dynFun, tSpan, z0, options);
t = linspace(tSpan(1), tSpan(2), 500);
z = deval(soln, t);
u = ctrlFun(t, z);

% Animate the results:
A.plotFunc = @(t, z)( doublePendulumDraw(t, z, param) );
A.speed = 1.0;
A.figNum = 101;
A.verbose = true;
animate(t, z, A)

% Plot the results:
figure(1337); clf; doublePendulumPlot(t, z, u, param)

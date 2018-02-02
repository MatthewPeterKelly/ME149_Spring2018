function prob_03_soln()
%
% This function computes a simulation of a simple pendulum.
%

%~~~~~~~~~~~~~~~~~  Set up for the simulation  ~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Duration of 20 seconds, with a maximum time-step of 0.01 seconds.
% Initial angle is randomly selected from [-3, 3] radians
% Initial angular rate is randomly selected from [-1, 1] radians / second
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Define the dynamical system and timing details:
dynFun = @(t, z)( PendulumDynamics(t, z) );
tSpan = [0, 20];
hMax = 0.01;

% Specify the initial state:
qInit = -3 + 6*rand();  % initial angle
wInit = -1 + 2*rand();  % initial angular rate
zInit = [qInit; wInit];  % combined initial state [angle ; rate];

%~~~~~~~~~~~~~~~~~~~~~~~~  Run the simulation  ~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[t, z] = EulerMethodSimulation(dynFun, tSpan, zInit, hMax);

%~~~~~~~~~~~~~~~~~~~  Make plots of the simulation  ~~~~~~~~~~~~~~~~~~~~~~%
% Create a single figure with three sub-plots (three rows, one column)
% The top sub-plot is pendulum angle vs time
% The middle sub-plot is angular rate vs time
% The botom sub-plot is angular acceleration vs time
% All axis should be clearly labeled (including units)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Unpack the result of the simulation
dz = PendulumDynamics(t, z);
q = z(1,:);  % Angle
w = z(2,:);  % Angular rate = derivative of q
dw = dz(2,:);  % Angular acceleration = derivative of w

% Set up the figure:
figure(1030); clf;

% Plot angle:
h1 = subplot(3,1,1); hold on;
plot(t, q, 'LineWidth', 2);
title('Simple Pendulum Simulation');
xlabel('time (s)')
ylabel('angle (rad)')

% Plot rate:
h2 = subplot(3,1,2); hold on;
plot(t, w, 'LineWidth', 2);
xlabel('time (s)')
ylabel('rate (rad/s)')

% Plot acceleration:
h3 = subplot(3,1,3); hold on;
plot(t, dw, 'LineWidth', 2);
xlabel('time (s)')
ylabel('accel (rad/s^2)')

% Link axes so that the view zooms in on all three plots at once
linkaxes([h1, h2, h3], 'x');

end

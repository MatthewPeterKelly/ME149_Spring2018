function TEST_quadrotorPendulumHover()
% TEST_quadrotorPendulumHover
%
% This function tests the quadrotor pendulum by running a closed-loop
% simulation of a LQR hover controller for small perturbations. This is
% not an extensive test, but is instead designed as a quick check.
%

% Simulation parameter:
duration = 5;   % seconds
nGrid = 500;  % number of grid points in the simulation
inverted = true;  % should the pendulum be inverted?

% Initial error in each state:
perturbationScale = [...
    0.1;  % x
    0.1; % y
    -0.2; % q1
    0.5; % q2
    0.1; % dx
    -0.2; % dy
    0.0; % dq1
    0.3]; % dq2

% Physical Parameters
param = struct('m1', 0.4, 'm2', 0.9, 'w', 0.4, 'l', 0.5, 'g', 10);

% Get the controller
xRef = 0.0;
yRef = 1.0;
[hoverController, zHover] = quadrotorPendulumHoverController(xRef, yRef, param, inverted);

% Define the closed-loop dynamics:
dynFun = @(t, z)( quadrotorPendulumDynamics(z, hoverController(z), param) );

% Run a simulation:
zInit = zHover + perturbationScale .* (1 - 2*rand(8,1));
t = linspace(0, duration, nGrid);
z = runSimulation(dynFun, t, zInit);
u = hoverController(z);

% Plot the result
figure(53040); clf;
quadrotorPendulumPlot(t, z, u);

% Animate the result
figure(53045); clf;
quadrotorPendulumAnimate(t, z, u, param);

end
function MAIN_hoverController()
% SOLN_TEST_hoverController()
%
% This function runs a simple simulation of the quadrotor hover controller.
%
run('../../../codeLibrary/addLibraryToPath.m');

% Decide whether to use the "real" or "ideal" dynamics
useRealDynamics = true; %#ok<*UNRCH>

% Simulation parameter:
duration = 5;   % seconds
nGrid = 500;  % number of grid points in the simulation
perturbationScale = 0.1;  % initial perturbation scale factor

% Parameters
param.m = 0.4;
param.w = 0.4;
param.g = 10;

% Get the controller
xRef = 0.0;
yRef = 1.0;
ctrlFun = getHoverController(xRef, yRef, param);

% Define the closed-loop dynamics:
if useRealDynamics
    planarQuadrotorRealDyn(randi(100000));  % Set the seed for the disturbance
    dynFun = @(t, z)( planarQuadrotorRealDyn(t, z, ctrlFun(z), param) );
else
    dynFun = @(t, z)( planarQuadrotorDynamics(z, ctrlFun(z), param) );
end

% Run a simulation:
zHover = [xRef; yRef; zeros(4,1)];
zTol = [0.1;  % tolerable error in horizontal position (m)
    0.1;  % tolerable error in vertical position (m)
    0.8;  % tolerable error in angle (rad)
    0.3;  % tol. error in horiz. vel. (m/s)
    0.3;  % tol. error in vert. vel. (m/s)
    1.0];  % tol. error in ang. vel. (m/s)
zInit = zHover + perturbationScale * randn(6,1) .* zTol;
t = linspace(0, duration, nGrid);
z = runSimulation(dynFun, t, zInit);
u = ctrlFun(z);

% Plot the result
figure(5040); clf;
planarQuadrotorPlot(t, z, u, param);

% Animate the result
figure(5045); clf;
planarQuadrotorAnimate(t, z, u, param);

end
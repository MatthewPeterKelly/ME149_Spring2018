function hw_04_solution()
% Tufts ME 149 - Optimal Control for Robotics - HW 4
%
% Assignment 4:  Introduction to Tracking Controllers
%
% Assigned: Feb 6, 2018
% Due: Feb 15, 2018
%
% Student Name:  SOLUTION
%
% Outline:
%
%   The code for this assignment is set up into two parts. The first part
%   is system specific and creates a standard-format model struct that
%   describes all unique aspects of that system. The second part is
%   generic, and runs the exact same code on each system. This avoids the
%   need to duplicate code for running the simulation, evaluating the cost
%   function, and plotting the trajectory.
%
% Notes:
%
%  The sign convention in the double-pendulum model is opposite than that
%  of the single pendulum. As a result, the behavior described in this 
%  assignment works out to be a swing-up for the single pendulum and a
%  swing-down for the double pendulum.
%

% Add the code library to the current path (needed for dynamics models)
run('../../../codeLibrary/addLibraryToPath.m');

% Initial perturbation size
xInitDel = 0.1;

% Run analysis for the simple pendulum
runTrackingControllerAnalysis(getSimplePendulumModel(), xInitDel);

% Run analysis for the double pendulum
runTrackingControllerAnalysis(getDoublePendulumModel(), xInitDel);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function model = getSimplePendulumModel()
% model = getSimplePendulumModel()
%
% Compute the model-specific data for the simple pendulum.
%
% OUTPUTS:
%   model = struct with model-specific data for the simple pendulum
%     .ref = reference trajectory
%     .gains = gains for the PD feed-back controller
%     .dynamics = dynamics function
%     .invDyn = inverse dynamics function
%     .info = general information about the model
%

% Reference trajectory
nSubSample = 50;
model.ref = getRefTrajSimplePendulum(nSubSample);

% Gains for the simple PD controller
xi = 1.0;  % controller damping ratio
wn = 2.0;  % controller response frequency
m = 1.0;  % effective mass (or inertia) at this joint
[model.gains.kp, model.gains.kd] = secondOrderSystemGains(wn, xi, m);

% Forward and inverse dynamics:
param.freq = 1.0;
param.damp = 0.0;
model.dynamics = @(z, u)( simplePendulumDynamics(z, u, param) );
model.invDyn = @(z, ddq)( simplePendulumInvDyn(z, ddq, param) );

% Information about the model:
model.info.nDof = 1;  % Number of degrees of freedom (joints)
model.info.name = 'Simple Pendulum';
model.info.figNum = 4010; 

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function ref = getRefTrajSimplePendulum(nSubSample)
% ref = getRefTrajSimplePendulum(nSubSample)
%
% Construct the kinematic reference trajectory that performs a swing-up
% behavior for the simple pendulum.
%
% INPUTS:
%   nSubSample = positive scalar integer = number of grid-points to add between
%               each pair of knot points for passing to the simulator
%
% OUTPUTS:
%   ref = struct (each field is a Matlab piece-wise polynomial struct)
%      .time = time-grid to use for simulation
%      .pos = position reference trajectory
%      .vel = velocity reference trajectory
%      .acc = acceleration reference trajectory
%

% Boundary conditions:
x0 = 0;  % initial angle
xT = pi;  % final angle
T = 3;  % duration (final time)

% Intermediate points:
xMid = pi * [0.3, 0.8];  %5.50

% Construct the knot points
xKnot = [x0, xMid, xT];

% Generate a reference trajectory from the knot points
ref = generateReferenceTrajectory([0, T], xKnot, nSubSample);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function model = getDoublePendulumModel()
% model = getDoublePendulumModel()
%
% Compute the model-specific data for the double pendulum.
%
% OUTPUTS:
%   model = struct with model-specific data for the simple pendulum
%     .ref = reference trajectory
%     .gains = gains for the PD feed-back controller
%     .dynamics = dynamics function
%     .invDyn = inverse dynamics function
%     .info = general information about the model
%

% Reference trajectory
nSubSample = 50;
model.ref = getRefTrajDoublePendulum(nSubSample);

% Gains for the simple PD controller
% For now, just use the same gains on both joints
xi = 1.0;  % controller damping ratio
wn = 2.0;  % controller response frequency
m = 1.0;  % effective mass (or inertia) at this joint
[model.gains.kp, model.gains.kd] = secondOrderSystemGains(wn, xi, m);

% Forward and inverse dynamics:
param.m1 = 1.0;
param.m2 = 1.0;
param.d1 = 1.0;
param.d2 = 1.0;
param.g = 1.0;
model.dynamics = @(z, u)( doublePendulumDynamics(z, u, param) );
model.invDyn = @(z, ddq)( doublePendulumInvDyn(z, ddq, param) );

% Information about the model:
model.info.nDof = 2;  % Number of degrees of freedom (joints)
model.info.name = 'Double Pendulum';
model.info.figNum = 4020;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function ref = getRefTrajDoublePendulum(nSubSample)
% ref = getRefTrajDoublePendulum(nSubSample)
%
% Construct the kinematic reference trajectory that performs a swing-up
% behavior for the double pendulum.
%
% INPUTS:
%   nSubSample = positive scalar integer = number of grid-points to add between
%               each pair of knot points for passing to the simulator
%
% OUTPUTS:
%   ref = struct (each field is a Matlab piece-wise polynomial struct)
%      .time = time-grid to use for simulation
%      .pos = position reference trajectory
%      .vel = velocity reference trajectory
%      .acc = acceleration reference trajectory
%

% Boundary conditions:  [link one; link two]
x0 = [0; 0];
xT = [pi; pi];
T = 5;  % duration (final time)

% Intermediate points:
xMid = pi * [ -0.1 0.5;
              0.6, 1.3];          
          
% Construct the knot points
xKnot = [x0, xMid, xT];

% Generate a reference trajectory from the knot points
ref = generateReferenceTrajectory([0, T], xKnot, nSubSample);

end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function ref = generateReferenceTrajectory(tBnd, xKnot, nSubSample)
% ref = generateReferenceTrajectory(tBnd, xKnot, nSubSample)
%
% Generate a reference trajectory using a clamped cubic spline with zero
% boundary velocity and uniformly spaced knot points.
%
% INPUTS:
%   tBnd = [1, 2] = [tLow, tUpp] = boundary times
%   xKnot = [nDim, nKnot] = position at the knot points
%   nSubSample = positive scalar integer = number of grid-points to add between
%               each pair of knot points for passing to the simulator
% OUTPUTS:
%   ref = struct (each field is a Matlab piece-wise polynomial struct)
%      .time = time-grid to use for simulation
%      .pos = position reference trajectory
%      .vel = velocity reference trajectory
%      .acc = acceleration reference trajectory
%

% Construct the knot points of the spline
tLow = tBnd(1);
tUpp = tBnd(2);
[nDim, nKnot] = size(xKnot);
tKnot = linspace(tLow, tUpp, nKnot);

% Construct the grid for simulation:
nGrid = 1 + (nSubSample + 1)*(nKnot - 1);
tGrid = linspace(tLow, tUpp, nGrid);

% Zero boundary velocity:
vBnd = zeros(nDim, 1);

% Construct the spline (clamped cubic)
ref.time =  tGrid;
ref.pos = spline(tKnot, [vBnd, xKnot, vBnd]);
ref.vel = ppDer(ref.pos);
ref.acc = ppDer(ref.vel);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function runTrackingControllerAnalysis(model, xInitDel)
% runTrackingControllerAnalysis(model, xInitDel)
%
% This function runs a generic analysis on a fully actuated model system
% that has a pp-spline reference trajectory and a simple PD tracking
% controller. It also computes a torque-squared objective function along
% the trajectory.
%
% INPUTS:
%   model = model struct, produced by either:  (see their documentation)
%       getSimplePendulumModel()
%       getDoublePendulumModel()
%   xInitDel = scalar = initial perturbation to apply at the start of each
%              simulation to test the tracking controller.
%
% OUTPUTS:
%   Generates a plot showing:
%       - reference trajectory (pos, vel, torque)
%       - simulated trajectory (pos, vel, torque)
%       - value of the objective function (both for uRef and u)
%

fprintf('Running analysis for the %s model...\n', model.info.name);

% Initial conditions:
t0 = model.ref.time(1);
initPos = ppval(model.ref.pos, t0) + xInitDel;
initVel = ppval(model.ref.vel, t0);
zDyn0 = [initPos; initVel];  % initial state of the system
zObj0 = [0;0];  % [open-loop cost, closed-loop cost];
zInit = [zDyn0; zObj0];

% Created an augmented dynamics function to pass into the simulator:
dynFun = @(t, z)( augmentedDynamicsFunction(t, z, model) );

% Run the simulation of the augmented system:
tGrid = model.ref.time;
zGrid = runSimulation(dynFun, tGrid, zInit, 'rk4');

% Unpack the solution for plotting:
nDof = model.info.nDof;
idxPos = 1:nDof;  % indices for angles
idxVel = idxPos(end) + (1:nDof);  % indices for rates
idxObj = idxVel(end) + (1:2);  % indices for objective function
pos = zGrid(idxPos, :);
vel = zGrid(idxVel, :);
obj = zGrid(idxObj, :);

% Evaluate the objective function
objValOpen = obj(1, end);  % open loop obj fun: integral(uRef^2)
objValClosed = obj(2, end); % closed loop obj fun: integral(u^2)

% Evaluate the controller again, for plotting only:
[u, uRef, posRef, velRef] = trackingController(tGrid, [pos; vel], model);

% Make a plot!
figure(model.info.figNum); clf;
nRow = 3;   % [pos; vel; ctrl]
nCol = model.info.nDof;
hSub = zeros(1, nRow * nCol);
for iCol = 1:nCol
    
    % position
    iRow = 1;
    iSub = iCol + nCol * (iRow - 1);
    hSub(iSub) = subplot(nRow, nCol, iSub); hold on;
    plot(tGrid, posRef(iCol, :), 'k--', 'LineWidth', 2);
    plot(tGrid, pos(iCol, :), 'r-', 'LineWidth', 2);
    legend('ref','meas', 'Location', 'Best');
    xlabel('time (s)')
    ylabel('angle (rad)')
    plotTitle = sprintf('Joint %d Angle Trajectory', iCol);
    title({model.info.name; plotTitle});
        
    % velocity
    iRow = 2;
    iSub = iCol + nCol * (iRow - 1);
    hSub(iSub) = subplot(nRow, nCol, iSub); hold on;
    plot(tGrid, velRef(iCol, :), 'k--', 'LineWidth', 2);
    plot(tGrid, vel(iCol, :), 'r-', 'LineWidth', 2);
    legend('ref','meas', 'Location', 'Best');
    xlabel('time (s)')
    ylabel('rate (rad/s)')
    title(sprintf('Joint %d Rate Trajectory', iCol));
            
    % control
    iRow = 3;
    iSub = iCol + nCol * (iRow - 1);
    hSub(iSub) = subplot(nRow, nCol, iSub); hold on;
    plot(tGrid, uRef(iCol, :), 'k--', 'LineWidth', 2);
    plot(tGrid, u(iCol, :), 'r-', 'LineWidth', 2);
    legend('open-loop','closed-loop', 'Location', 'Best');
    xlabel('time (s)')
    ylabel('torque (N-m)')
    plotTitle = sprintf('Joint %d Torque Trajectory', iCol);
    objFunStrOpen = ['\int_0^T uRef^2 dt = ' num2str(objValOpen)];
    objFunStrClosed = ['\int_0^T u^2 dt = ' num2str(objValClosed)];
    title({plotTitle; [objFunStrOpen '    --    ' objFunStrClosed]});
    
    
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function dz = augmentedDynamicsFunction(t, z, model)
% dz = augmentedDynamicsFunction(t, z, model)
%
% This function computes the augmented system dynamics for the tracking
% controller, simultaneously solving the system dynamics and the objective
% function (for both the open-loop and closed-loop torques).
%
% INPUTS:
%   t = [1, nTime] = time vector
%   z = [2*nDof + 2, nTime] = [pos; vel; obj] = augmented state vector
%   model = model struct, produced by either:  (see their documentation)
%       getSimplePendulumModel()
%       getDoublePendulumModel()
% 
% OUTPUTS:
%   dz = [2*nDof + 2, nTime] = [vel; acc; dObj] = derivative of augmented state
%

% Unpack the state of the system dynamics and objective function integrand
nDof = model.info.nDof;
idxDyn = 1:(2*nDof);  % indices of the system dynamics
zDyn = z(idxDyn, :);  % system state:  [angles; rates];

% Evaluate the tracking controller:
[u, uRef] = trackingController(t, zDyn, model);

% Evaluate the system dynamics:
dzDyn = model.dynamics(zDyn, u);

% Evaluate the objective function:
dzObj = [sum(uRef.^2, 1);   % open-loop actuation-squared
        sum(u.^2, 1)]; % closed-loop actuation-squared
    
% Derivative of the augmented state:
dz = [dzDyn; dzObj];
    
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [u, uRef, posRef, velRef] = trackingController(t, z, model)
% [u, uRef, posRef, velRef] = trackingController(t, z, model)
%
% Simple tracking controller. Uses inverse dynamics to compute the
% feed-forward reference control and a simple PD controller for the
% feed-back trajectory stabilization.
%
% INPUTS:
%   t = [1, nTime] = time vector
%   z = [2*nDof, nTime] = [pos; vel] = state vector
%   model = model struct, produced by either:  (see their documentation)
%       getSimplePendulumModel()
%       getDoublePendulumModel()
%
% OUTPUTS:
%   u = [nDof, 1] = control torque
%   uRef = [nDof, 1] = feed-forward (reference) control torque
%   posRef = [nDof, 1] = open-loop reference position
%   velRef = [nDof, 1] = open-loop reference velocity
%
% NOTES: 
%   Here we use the reference position, velocity, and acceleration to
%   generate the feed-forward torques uRef. This keeps the reference
%   trajectory (pos, vel, ctrl) independent of what is actually happening
%   with the system; the feedback controller then completely handles any
%   tracking error. There are other ways to do this, for example, using the
%   measured position or the measured velocity instead of the reference.
%   The choice here depends on your system and what performs best.
%
%   Another reason to use "pure" feed-forward torque (dependent only on the
%   reference trajectory) is because that is often what we will get out of
%   a trajectory optimization. This is particularily true for underactuated
%   systems where it is not practical to call the inverse dynamics
%   directly.
%

% reference angles and rates
posRef = ppval(model.ref.pos, t);
velRef = ppval(model.ref.vel, t);
accRef = ppval(model.ref.acc, t);

% gains for the PD contoller
kp = model.gains.kp;
kd = model.gains.kd;

% measured angles and rates
nDof = model.info.nDof;
idxPos = 1:nDof;
idxVel = (nDof+1):(2*nDof);
pos = z(idxPos, :);
vel = z(idxVel, :);

% feed-forward torques
uRef = model.invDyn([posRef; velRef], accRef);

% traking controller:
u = uRef + kp * (pos - posRef) + kd * (vel - velRef);

end





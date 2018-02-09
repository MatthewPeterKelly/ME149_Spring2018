function DEMO_2D_tracking()
%
% DEMO: 2D tracking controller (point mass)
%
% This demo shows how to set up a reference trajectory for a system with 2 DoF
% and then generate a tracking controller and run a simulation.
%
% This code is not optimized for speed - there are several calculations 
% that are performed multiple times. This is done to break the code into
% independent pieces that are each able to be understood on its own.
%

run('../../../codeLibrary/addLibraryToPath.m');

%%%% open-loop reference trajectory
tSpan = [0, 10];  % time span
posKnot = [0, 3, 6, 3, 4, 9;  % x-position at each knot point
         0, 1, 3, 5, 8, 9]; % y-position at each knot point
[nDim, nKnot] = size(posKnot);
tKnot = linspace(tSpan(1), tSpan(end), nKnot);  % time at each knot point
velBnd = zeros(nDim,1);  % velocity is zero at each boundary
ref.pos = spline(tKnot, [velBnd, posKnot, velBnd]);  % position reference spline
ref.vel = ppDer(ref.pos);
ref.acc = ppDer(ref.vel);

%%%% Set up the function handles:
invDynFun = @pointMassInvDyn;

%%%% Set the grid for simulation and cost function evaluation:
nGridSim = 1 + 10*(nKnot-1);  % ensure that each knot point is at a grid point
tGridSim = linspace(tSpan(1), tSpan(end), nGridSim);

%%%% Evaluate the objective function along the reference trajectory
objFunVal = evaluateObjectiveFunction(tGridSim, ref, invDynFun);
fprintf('Effort-Squared for Reference Trajectory: %6.6f\n', objFunVal);

%%%% Create the gains for the PD tracking controller
% For now, use unit mass and apply the same gains to each motor
ctrlFreq = 2.0;
ctrlDamp = 1.0;
[Kp, Kd] = secondOrderSystemGains(ctrlFreq, ctrlDamp);
gains.Kp = Kp;
gains.Kd = Kd;
ctrlFun = @(t,z)( trackingController(t, z, ref, gains, invDynFun) );

%%%% Set up the closed-loop dynamics function:
dynFun = @(t, z)( pointMassDynamics(z, ctrlFun(t,z)) );

%%%% Set up and run a simulation:
initPosErr = [0.4; 0.8];
posInit = ppval(ref.pos, tSpan(1)) + initPosErr;
velInit = ppval(ref.vel, tSpan(1));
z0 = [posInit; velInit];
zGridSim = runSimulation(dynFun, tGridSim, z0);

%%%% Plot the open-loop reference trajectory in cartesian space
figure(50010); clf;
plotCartesianReference(ref, zGridSim);

%%%% Plot the open-loop reference trajectory against time
figure(50011); clf;
plotTrajectory(ref, invDynFun, tGridSim, zGridSim, ctrlFun);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [u, uRef] = trackingController(t, z, ref, gains, invDynFun)

% Unpack the gains
Kp = gains.Kp;
Kd = gains.Kd;

% Get the current state
pos = z(1:2, :);  
vel = z(3:4, :);

% Get the reference position and velocity
posRef = ppval(ref.pos, t);
velRef = ppval(ref.vel, t);

% Get the feed-forward actuation
uRef = getFeedForwardActuation(t, ref, invDynFun);

% Compute the overall control effort:
u = uRef + Kp * (pos - posRef) + Kd * (vel - velRef);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function uRef = getFeedForwardActuation(t, ref, invDynFun)

posRef = ppval(ref.pos, t);  % position reference
velRef = ppval(ref.vel, t);  % velocity reference
accRef = ppval(ref.acc, t);  % acceleration reference

zRef = [posRef; velRef];  % full state

uRef = invDynFun(zRef, accRef);  % feed-forward actuation!

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function objFunVal = evaluateObjectiveFunction(tGrid, ref, invDynFun)

% Create the function handle to evaluate the objective function
% Note the similarity to the the function handle that we use for dynamics
objFun = @(t,z)( objectiveFunctionIntegrand(t, ref, invDynFun) );

% Use the simulator to compute the integral of the objective function
objValInit = 0;  % constant of integration (initial cost)
objFunIntegral = runSimulation(objFun, tGrid, objValInit);
objFunVal = objFunIntegral(end);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function objVal = objectiveFunctionIntegrand(t, ref, invDynFun)

uRef = getFeedForwardActuation(t, ref, invDynFun);

objVal = sum(uRef.^2, 1);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotTrajectory(ref, invDynFun, tSim, zSim, ctrlFun)

% Interpolate from the spline:
tLow = ref.pos.breaks(1);
tUpp = ref.pos.breaks(end);
tRef = linspace(tLow, tUpp, 250);
posRef = ppval(ref.pos, tRef);
velRef = ppval(ref.vel, tRef);

% Compute the feed-forward control
uRef = getFeedForwardActuation(tRef, ref, invDynFun);

% Interpolate at the knot points:
tKnot = ref.pos.breaks;
posKnot = ppval(ref.pos, tKnot);
velKnot = ppval(ref.vel, tKnot);

% Unpack the values from simulation:
posSim = zSim(1:2, :);
velSim = zSim(3:4, :);
ctrlSim = ctrlFun(tSim, zSim);

% Generate the plots:
nDim = size(posRef, 1);  % number of dimensions
nRow = 3;  % pos, vel, force  --- number of subplot rows
for iDim = 1:nDim
    
    subplot(nRow, nDim, iDim); hold on;
    plot(tRef, posRef(iDim,:), 'k-', 'LineWidth', 2);
    plot(tKnot, posKnot(iDim,:), 'ko', 'LineWidth', 2, 'MarkerSize', 8);
    plot(tSim, posSim(iDim,:), 'r-', 'LineWidth', 2);
    xlabel('time');
    ylabel(['pos-' num2str(iDim)]);
    
    subplot(nRow, nDim, iDim + nDim); hold on;
    plot(tRef, velRef(iDim,:), 'k-', 'LineWidth', 2);
    plot(tKnot, velKnot(iDim,:), 'ko', 'LineWidth', 2, 'MarkerSize', 8);
    plot(tSim, velSim(iDim,:), 'r-', 'LineWidth', 2);
    xlabel('time');
    ylabel(['vel-' num2str(iDim)]);
    
    subplot(nRow, nDim, iDim + 2*nDim); hold on;
    plot(tRef, uRef(iDim,:), 'k-', 'LineWidth', 2);
    plot(tSim, ctrlSim(iDim,:), 'r-', 'LineWidth', 2);
    xlabel('time');
    ylabel(['ctrl-' num2str(iDim)]);
    
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotCartesianReference(ref, zSim)

% Interpolate from the spline:
tLow = ref.pos.breaks(1);
tUpp = ref.pos.breaks(end);
tRef = linspace(tLow, tUpp, 250);
posRef = ppval(ref.pos, tRef);
xRef = posRef(1,:);  % x-position
yRef = posRef(2,:);  % y-posiiton

% Interpolate at the knot points:
tKnot = ref.pos.breaks;
posKnot = ppval(ref.pos, tKnot);
xKnot = posKnot(1,:);  % x-position knots
yKnot = posKnot(2,:);  % y-posiiton knots

% x and y position from the simulation
xPos = zSim(1,:);
yPos = zSim(2,:);

% Make the plot:
hold on;
plot(xRef, yRef, 'k-', 'LineWidth', 2);  % interpolant
plot(xKnot, yKnot, 'ko', 'LineWidth', 2, 'MarkerSize', 8);  % knot points
plot(xPos, yPos, 'r', 'LineWidth', 2);
axis equal; axis tight;
xlabel('x-position');
ylabel('y-position');

end

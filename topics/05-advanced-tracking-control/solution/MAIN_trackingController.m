function MAIN_trackingController()
% Tufts ME 149 - Optimal Control for Robotics - HW 5
%
% Assignment 5:  Advanced Tracking Control
%
% Assigned: Feb 15, 2018
% Due: Feb 27, 2018
%
% Student Name:  SOLUTION
%
% Run a simulation of the tracking controller

% Add the code library to the current path (needed for dynamics models)
run('../../../codeLibrary/addLibraryToPath.m');

% Decide which dynamic function to use:
useRealDynamics = true;  %#ok<*UNRCH>

% Import the reference trajectory for the quadrotor back-flip
refTrajFile = 'quadrotorOptimalFlipData.csv';
paramFile = 'quadrotorOptimalFlipParam.csv';
[ref, param] = importReferenceTrajectory(refTrajFile, paramFile);

% Write the closed-loop dynamics, including tracking controller
[ctrlFun, gains] = getTrackingController(ref, param);

if useRealDynamics
    % Set the real dynamics model (with wind)
    errModel.xDist = 0.085;
    errModel.yDist = 0.075;
    errModel.qDist = 0.045;
    errModel.nTerm = 5;
    errModel.freqBnd = [0.1, 7];  % Hz
    planarQuadrotorRealDyn(randi(100000), errModel);
    dynFun = @(t,z)( planarQuadrotorRealDyn(t, z, ctrlFun(t, z), param) ); 
else
    % Ideal model (no disturbance)
    dynFun = @(t,z)( planarQuadrotorDynamics(z, ctrlFun(t, z), param) );     
end

% Run a simulation:
tBnd = ref.time([1,end]);
tGrid = linspace(tBnd(1), tBnd(2) + 0.5, 1000);
zInit = ppval(ref.state, tGrid(1));
zGrid = runSimulation(dynFun, tGrid, zInit, 'rk4');
uGrid = ctrlFun(tGrid, zGrid);

% Plot the trajectory as function of time
figure(5035); clf;
planarQuadrotorPlot(tGrid, zGrid, uGrid, param);

% Plot the gains:
figure(5036); clf;
plot(tGrid, ppval(gains, min(tGrid, gains.breaks(end))));
xlabel('time (s)')
ylabel('gains');
title('LQR gains over time')

end



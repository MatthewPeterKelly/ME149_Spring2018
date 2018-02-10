function hw_03_soln()
% Solution to ME 149 - Optimal Control for Robotics - HW 3
%
% Matthew P. Kelly  --  January 28, 2018
%
% Outline:
%
%   - Simulate two systems:
%       - driven damped pendulum
%       - passive double pendulum
%
%   - Analysis:
%       - compare 1st-, 2nd- , and 4th-order Runge--Kutta methods
%         to a high-accuracy solution obtained via ode45()
%
%   - Plots:
%       - driven-damped pendulum:
%           [angle]        [rate]
%           [angle error]  [rate error]
%       - passive double-pendulum:
%            [angle 1]        [angle 2]       [rate 1]        [rate 2]       
%            [angle 1 error]  [angle 2 error] [rate 1 error]  [rate 2 error]
%

run('../../../codeLibrary/addLibraryToPath.m');

% Part One: simulate the driven-damped pendulum
analysisDrivenDampedPendulum();

% Part Two: simulate the passive double pendulum
analysisPassiveDoublePendulum();

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function analysisDrivenDampedPendulum()
% Run simulation of the driven-damped pendulum and then make plots

% Set up the function handle:
dynFun = @drivenDampedPendulumDynamics;

% Simulation parameters:
tGrid = linspace(0, 20, 150); % (start time, final time, steps-1);
zInit = [...
    1.2;  % initial angle
    0.8];  % initial angular rate
info.methodList = {'euler','heun','rk4'};  % list of methods to use
info.tol = 1e-12;  % tolerance for ode45

% System information:
info.systemName = 'driven-damped pendulum';
info.stateNames = {'angle', 'rate'};
info.stateUnits = {'rad', 'rad/sec'};
info.figNum = 30001;

% Call the analysis function:
runSystemAnalysis(dynFun, tGrid, zInit, info);

end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function analysisPassiveDoublePendulum()
% Run simulation of the passive double pendulum and then make plots

% Set up the parameters:   (set all to unity)
param.m1 = 1;
param.m2 = 1;
param.d1 = 1;
param.d2 = 1;
param.g = 1;

% Set up the function handle:
ctrlFun = @(t)( zeros(2, length(t)) );  % passive controller (zero torque)
dynFun = @(t, z)( doublePendulumDynamics(z, ctrlFun(t), param) );

% Simulation parameters:
tGrid = linspace(0, 10, 100);
zInit = [...
    0.6;  % link one angle
    0.9;  % link two angle
    0.0;  % link one rate
    0.0];  % link two rate
info.methodList = {'euler','ralston','rk4'};  % list of methods to use
info.tol = 1e-12;  % tolerance for ode45

% System information:
info.systemName = 'double pendulum';
info.stateNames = {'angle 1', 'angle 2', 'rate 1', 'rate 2'};
info.stateUnits = {'rad', 'rad', 'rad/s', 'rad/s'};
info.figNum = 30002;

% Run the analysis:
runSystemAnalysis(dynFun, tGrid, zInit, info);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function runSystemAnalysis(dynFun, tGrid, zInit, info)
% runSystemAnalysis(dynFun, tGrid, zInit, info)
%
% INPUTS:
%   dynFun = a function handle:  dz = dynFun(t, z)
%       IN:  t = [1, nTime] = row vector of time
%       IN:  z = [nState, nTime] = matrix of states corresponding to each time
%       OUT: dz = [nState, nTime] = time-derivative of the state at each point
%   tGrid = [1, nGrid] = time grid to evaluate the simulation
%   zInit = [nDim, 1] = initial state
%   info = struct with meta-data about the system and analysis
%     .stateNames = cell array with the names of each state
%     .stateUnits = cell array with the units for each state
%     .systemName = name of the system that we are simulating
%     .figNum = figure on which to plot
%     .methodList = list of methods to compare
%     .tol = tolerance to use for ode45 solution
%

% Compute the solution using ode45:
zSoln = runSimOde45(dynFun, tGrid, zInit, info.tol);

% Run each simulation:
data = struct();
for iMethod = 1:length(info.methodList)
    method = info.methodList{iMethod};
    data.(method) = runSimulation(dynFun, tGrid, zInit, method);
end

% Set up for plotting
nRow = 2;  % [state; error];
nCol = length(info.stateNames);  %[state_1, state_2, ...];
figure(info.figNum); clf;
names = info.stateNames;
units = info.stateUnits;

% Plot the solution:
for iCol = 1:nCol
    % State:
    subplot(nRow, nCol, iCol); hold on;
    plot(tGrid, zSoln(iCol, :), 'k-', 'LineWidth', 4);
    xlabel('time (sec)');
    ylabel([names{iCol}, ' (', units{iCol}, ')']);
    title([info.systemName, ': ' names{iCol}]);
    
    % Error:
    subplot(nRow, nCol, iCol + nCol); hold on;
    plot(tGrid([1,end]), info.tol*[1,1], 'k-', 'LineWidth', 4);
    xlabel('time (sec)');
    ylabel([names{iCol}, ' (', units{iCol}, ')']);
    title(['abs error: ' names{iCol}]);
end

% Plot each of the methods:
methodList = fieldnames(data);
for iMethod = 1:length(methodList)
    method = methodList{iMethod};
    for iCol = 1:nCol
        % State:
        subplot(nRow, nCol, iCol); hold on;
        plot(tGrid, data.(method)(iCol, :), '-', 'LineWidth', 2);
        
        % Error:
        err = max(info.tol, abs(zSoln(iCol, :) - data.(method)(iCol, :)));
        subplot(nRow, nCol, iCol + nCol); hold on;
        plot(tGrid, err, '-', 'LineWidth', 2);
        set(gca,'YScale','log');
    end
end

% Add legends and link axes:
legendNames = ['soln'; methodList];
for iSub = 1:(2*nCol)
    hSub(iSub) = subplot(nRow, nCol, iSub); %#ok<AGROW>
    legend(legendNames, 'Location', 'best')
end
linkaxes(hSub,'x');

end

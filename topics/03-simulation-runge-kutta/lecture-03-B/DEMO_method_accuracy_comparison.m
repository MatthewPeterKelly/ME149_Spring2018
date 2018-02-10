% DEMO_method_accuracy_comparison()
%
% In this demo we will look at the relationship between number of function
% evaluations and the accuracy of the simulation, for several integration
% methods. We will use a test system that has an analytic solution, and
% then test the absolute error for each method at the final point in the
% simulation.
%
clc; clear;

% Add the code library to the current path
run('../../../codeLibrary/addLibraryToPath.m');

%% Function handle for a simple dynamical system:
dynFun = @(t, z)( z - t );

% Analytic solution to the dynamical system:
C = 1.0;  % Constant of integration;
dynSoln = @(t)( C*exp(t) + t + 1 );  % Function handle for the solution

% Simulation parameters:
t0 = 0;  % initial time
tF = 1;  % final time
z0 = dynSoln(t0);  % initial state
zF = dynSoln(tF);  % final state

%% Compute the results for methods in the ode suite
result = struct();
odeMethod.ode45 = @ode45;
odeMethod.ode23 = @ode23;
% odeMethod.ode15s = @ode15s;
% odeMethod.ode113 = @ode113;
tolVec = logspace(-13, -3, 25);
odeMethodNames = fieldnames(odeMethod);
for iMethod = 1:length(odeMethodNames)
    for iTrial = 1:length(tolVec)
        method = odeMethodNames{iMethod};
        tol = tolVec(iTrial);
        options = odeset('RelTol', tol, 'AbsTol', tol);
        odeFun = odeMethod.(method);
        soln = odeFun(dynFun, [t0, tF], z0, options);
        result.(method).absErr(iTrial) = abs(deval(soln, tF) - zF);
        result.(method).nEval(iTrial) = soln.stats.nfevals;
    end
end

%% Compute the results for Bulirsch-Stoer:
%
% Burlirsch-Stoer is a fancy method for smooth systems. It requires a few
% extra parameters: an initial grid and mesh refinement. 
tGrid = linspace(t0, tF, 2);
for iTrial = 1:length(tolVec)
    tol = tolVec(iTrial);
    [zGrid, nEval] = runSimBulirschStoer(dynFun, tGrid, z0, tol);
    result.bulSto.absErr(iTrial) = abs(zGrid(end) - zF);
    result.bulSto.nEval(iTrial) = nEval;
end

%% Setup for the Runge-Kutta methods:

methodList = {'euler','ralston','rk4'};

% Setup for the Runge-Kutta experiments:
nGridList = [1:2:9, 10:5:50, 75:25:150, 200:200:800, logspace(3,5,10)];

% Run the experiment:
for iMethod = 1:length(methodList)
    method = methodList{iMethod};
    for iTrial = 1:length(nGridList)
        tGrid = linspace(t0, tF, nGridList(iTrial));
        result.(method).tGrid = tGrid;
        [zGrid, nEval] = runSimulation(dynFun, tGrid, z0, method);
        result.(method).absErr(iTrial) = abs(zGrid(end) - zF);
        result.(method).nEval(iTrial) = nEval;
    end
end

%% Generate plot:
figure(100300); clf; hold on;
methodList = fieldnames(result);
for iMethod = 1:length(methodList)
    R = result.(methodList{iMethod});
    plot(R.nEval, R.absErr, '-o', 'LineWidth', 2);
end
hPlt = gca;
set(hPlt, 'XScale', 'log');
set(hPlt, 'YScale', 'log');
legend(methodList)
title('Method accuracy comparison')
xlabel('Number of function evaluations')
ylabel('Absolute error')






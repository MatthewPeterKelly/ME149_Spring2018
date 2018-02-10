function [zGrid, nEval] = runSimulation(dynFun, tGrid, zInit, method)
%  [zGrid, nEval] = runSimulation(dynFun, tGrid, zInit, method)
%
% Simulate a dynamical system, given an integration routine, time grid,
% and initial state. Select from several explicit Runge-Kutta methods.
%
% INPUTS:
%    dynFun = a function handle:  dz = dynFun(t, z)
%        IN:  t = [1, nTime] = row vector of time
%        IN:  z = [nState, nTime] = matrix of states corresponding to each time
%        OUT: dz = [nState, nTime] = time-derivative of the state at each point
%    tGrid = [1, nGrid] = time grid to evaluate the simulation
%    zInit = [nDim, 1] = initial state
%    method = string = name of the desired method
%      'euler' = Euler's method (first-order)
%      'heun' = Heun's method (second-order)
%      'midpoint' = the midpoint method (second-order)
%      'ralston' = Ralston's method (second-order)
%      'rk4' = "The" Runge--Kutta method (forth-order)  --  default
%
% OUTPUTS:
%   zGrid = [nDim, nGrid] = state at each point in tGrid. zGrid(:,1) = zInit
%   nEval = scalar = total number of calls to the dynamics function
%

% Input validation:
[nDim, nOne] = size(zInit);
if nOne ~= 1
    error('zInit must be a column vector!');
end
[nOne, nGrid] = size(tGrid);
if nOne ~= 1
    error('tGrid must be a row vector!');
end
if min(abs(diff(tGrid))) < eps
    error('Cannot have a zero-duration time-step!');
end
if nargin < 4
    method = 'rk4';
end

% Select the desired simulation method:
switch method
    case 'euler'
        simStep = @simStepEulerMethod;
    case 'heun'
        % alternate implementation: simStepRungeKutta2 with alpha = 1.0
        simStep = @simStepHeunMethod;
    case 'midpoint'
        % alternate implementation: simStepRungeKutta2 with alpha = 0.5
        simStep = @simStepMidpointMethod;
    case 'ralston'
        alpha = 2.0 / 3.0;
        simStep = @(dynFun, tPrev, tNext, zPrev)( ...
            simStepRungeKutta2(dynFun, tPrev, tNext, zPrev, alpha) );
    case 'rk4'
        simStep = @simStepRungeKutta4;
    otherwise
        error('method is invalid!');
end

% Set up the state grid:
zGrid = zeros(nDim, nGrid);
zGrid(:, 1) = zInit;

% Step through time:
nEval = 0;
for i = 2:nGrid
    tPrev = tGrid(i - 1);
    tNext = tGrid(i);
    zPrev = zGrid(:, i - 1);
    [zNext, nTmp] = simStep(dynFun, tPrev, tNext, zPrev);
    zGrid(:,i) = zNext;
    nEval = nEval + nTmp;
end

end

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
%      'rk4' = "The" Runge--Kutta method (forth-order)
%
% OUTPUTS:
%   zGrid = [nDim, nGrid] = state at each point in tGrid. zGrid(:,1) = zInit
%   nEval = scalar = total number of calls to the dynamics function
%

%%%% TODO:  implement this function

end

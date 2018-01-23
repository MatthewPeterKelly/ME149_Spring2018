function [tGrid, zGrid] = EulerMethodSimulation(dynFun, tSpan, zInit, hMax)
% [tGrid, zGrid] = EulerMethodSimulation(dynFun, tSpan, zInit, hMax)
%
% Simulate a dynamical system over a set time span using Euler's method,
% given the initial state and the maximum time step. Use a uniform time grid.
%
% INPUTS:
%    dynFun = a function handle:  dz = dynFun(t, z)
%        IN:  t = [1, nTime] = row vector of time
%        IN:  z = [nState, nTime] = matrix of states corresponding to each time
%        OUT: dz = [nState, nTime] = time-derivative of the state at each point
%    tSpan = [startTime, finalTime] = [1, 2] = time span
%    zInit = [nState, 1] = state of the system at start time
%    hMax = scalar = maximum time step to use for the uniform time grid.
%
% OUTPUTS:
%    tGrid = [1, nTime] = time grid on which the integration was performed
%    zGrid = [nState, nTime] = state at each point in tGrid
%
%

%%%% TODO: Implement this function

end

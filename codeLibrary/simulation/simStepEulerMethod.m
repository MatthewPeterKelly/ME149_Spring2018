function [zNext, nEval] = simStepEulerMethod(dynFun, tPrev, tNext, zPrev)
% [zNext, nEval] = simStepEulerMethod(dynFun, tPrev, tNext, zPrev)
%
% This function computes a single integration step using Euler's method.
%
% INPUTS:
%    dynFun = a function handle:  dz = dynFun(t, z)
%        IN:  t = [1, nTime] = row vector of time
%        IN:  z = [nState, nTime] = matrix of states corresponding to each time
%        OUT: dz = [nState, nTime] = time-derivative of the state at each point
%    tPrev = scalar = previous time grid point
%    tNext = scalar = next time grid point
%    zPrev = [nDim, 1] = state at tPrev
%
% OUTPUTS:
%    zNext = [nDim, 1] = state at tNext
%    nEval = scalar = numer of internal calls to dynamics function
%

h = tNext - tPrev;
zNext = zPrev + h * dynFun(tPrev, zPrev);
nEval = 1;

end

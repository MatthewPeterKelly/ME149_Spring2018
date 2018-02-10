function [zNext, nEval] = simStepMidpointMethod(dynFun, tPrev, tNext, zPrev)
% [zNext, nEval] = simStepMidpointMethod(dynFun, tPrev, tNext, zPrev)
%
% This function computes a single integration step using the midpoint method.
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

% Compute the state estimate at the midpoint, using Euler step
tMid = tPrev + 0.5 * h;
zMid = zPrev + 0.5 * h * dynFun(tPrev, zPrev);

% Compute the state at the next point, using dynamics at the midpoint:
zNext = zPrev + h * dynFun(tMid, zMid);

nEval = 2;

end

function [zNext, nEval] = simStepHeunMethod(dynFun, tPrev, tNext, zPrev)
% [zNext, nEval] = simStepHeunMethod(dynFun, tPrev, tNext, zPrev)
%
% This function computes a single integration step using Heun's method.
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

% Eulers method to approximate the next state
zNextApprox = zPrev + h * dynFun(tPrev, zPrev);

% Approximate the state at the midpoint:
tMid = tPrev + 0.5 * h;
zMid = 0.5 * (zPrev + zNextApprox);

% Compute the state at the next point, using dynamics at the midpoint:
zNext = zPrev + h * dynFun(tMid, zMid);

nEval = 2;

end

function [zNext, nEval] = simStepMidpoint(dynFun, tPrev, tNext, zPrev)
% [zNext, nEval] = simStepMidpoint(dynFun, tPrev, tNext, zPrev)
%
% Compute a single integration step using the midpoint method.
%
% INPUTS:
%    dynFun = a function handle:  dz = dynFun(t, z)
%        IN:  t = [1, nTime] = row vector of time
%        IN:  z = [nState, nTime] = matrix of states at times t
%        OUT: dz = [nState, nTime] = time-derivative of z
%    tPrev = scalar = previous time grid point
%    tNext = scalar = next time grid point
%    zPrev = [nDim, 1] = state at tPrev
%
% OUTPUTS:
%    zNext = [nDim, 1] = state at tNext
%    nEval = scalar = numer of internal calls to dynamics function
%


% time-step for the integration method
h = tNext - tPrev;

% Compute the state estimate at the midpoint, using Euler step
tMid = tPrev + 0.5 * h;
zMid = zPrev + 0.5 * h * dynFun(tPrev, zPrev);

% Evaluate the dynamics at the midpoint state estimate:
dzMid = dynFun(tMid, zMid);

% Compute the state at the next point, using dynamics at the midpoint:
zNext = zPrev + h * dzMid;

% There are always two function evaluations in the midpoint method
nEval = 2;

end

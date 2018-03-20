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

% Step size:
h = tNext - tPrev;

% Function evaluations at initial point
dzPrevEst = dynFun(tPrev, zPrev);

% State estimate at final point
zNextEst = zPrev + h * dzPrevEst;

% Function evaluation at estimate of final point
dzNextEst = dynFun(tNext, zNextEst);

% Combine the two estimates to compute the second-order step
zNext = zPrev + 0.5 * h * (dzPrevEst + dzNextEst);

% Two function evaluations
nEval = 2;  % second-order method  (two function evaluations)

end

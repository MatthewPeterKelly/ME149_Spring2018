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
































end

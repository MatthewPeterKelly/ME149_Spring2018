function [zNext, nEval] = simStepRungeKutta4(dynFun, tPrev, tNext, zPrev)
% [zNext, nEval] = simStepRungeKutta4(dynFun, tPrev, tNext, zPrev)
%
% This function computes a single integration step using "the" standard
% fourth-order explicit Runge-Kutta method.

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
tMid = tPrev + 0.5 * h;

k1 = h * dynFun(tPrev, zPrev);  % zDel estimate at initial point
k2 = h * dynFun(tMid, zPrev + 0.5 * k1);  % zDel estimate at midpoint
k3 = h * dynFun(tMid, zPrev + 0.5 * k2);  % better zDel est. at midpoint
k4 = h * dynFun(tNext, zPrev + k3);  % zDel estimate at final point
zDel = (1 / 6) * (k1 + 2*k2 + 2*k3 + k4);  % weighted zDel estimate
zNext = zPrev + zDel;

nEval = 4;  % fourth-order method  (four function evaluations)

end

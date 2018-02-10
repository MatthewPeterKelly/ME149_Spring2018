function [zNext, nEval] = simStepRungeKutta2(dynFun, tPrev, tNext, zPrev, alpha)
% [zNext, nEval] = simStepRungeKutta2(dynFun, tPrev, tNext, zPrev, alpha)
%
% Performs a single second-order (explicit) Runge-Kutta step.

% INPUTS:
%    dynFun = a function handle:  dz = dynFun(t, z)
%        IN:  t = [1, nTime] = row vector of time
%        IN:  z = [nState, nTime] = matrix of states corresponding to each time
%        OUT: dz = [nState, nTime] = time-derivative of the state at each point
%    tPrev = scalar = previous time grid point
%    tNext = scalar = next time grid point
%    zPrev = [nDim, 1] = state at tPrev
%    alpha = scalar = method parameter:
%        1  == Heun's method
%       2/3 == Ralston's method
%       1/2 == midpoint methods
%
% OUTPUTS:
%    zNext = [nDim, 1] = state at tNext
%    nEval = scalar = numer of internal calls to dynamics function
%

if nargin < 5
    alpha = 2.0 / 3.0;  %Ralston's method
end

% Step size:
h = tNext - tPrev;

% Quadrature weights
w2 = 1 / (2 * alpha);
w1 = 1 - w2;

% Function evaluations:
k1 = h * dynFun(tPrev, zPrev);
k2 = h * dynFun(tPrev + alpha * h, zPrev + alpha * k1);
zNext = zPrev + (w1 * k1 + w2 * k2);

nEval = 2;  % second-order method  (two function evaluations)

end

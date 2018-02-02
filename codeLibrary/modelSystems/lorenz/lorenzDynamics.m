function dState = lorenzDynamics(state)
%  dState = lorenzDynamics(state)
%
% This function computes the dynamics for the famous 'Lorenz Attractor'
% See the matlab function lorenz.m for a neat demo.
%
% INPUTS:
%   state = [3, nTime] = current state of the system
%
% OUTPUTS:
%   dState = [3, nTime] = time-derivative at current state
%
% NOTES:
%   https://en.wikipedia.org/wiki/Lorenz_system
%
% dx = sigma * (y - x)
% dy = x * (rho - z) - y
% dz = x * y - beta * z
%

sigma = 10.0;
rho = 28.0;
beta = 8.0 / 3.0;

x = state(1,:);
y = state(2,:);
z = state(3,:);

dx = sigma * (y - x);
dy = x .* (rho - z) - y;
dz = x .* y - beta * z;

dState = [dx; dy; dz];

end

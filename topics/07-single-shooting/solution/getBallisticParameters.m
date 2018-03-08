function param = getBallisticParameters()
% param = getBallisticParameters()
%
% Returns an example set of parameters for use in the ballistic trajectory
% calculation.
%
% OUTPUT:
%   param = parameters for the simulation and ballistic model:
%       .gravity = scalar = gravity constant
%       .wind = [3,1] = [w1; w2; w3] = wind velocity
%       .drag = scalar = quadratic drag constant
%       .mass = scalar = mass of the projectile
%       .start = [3,1] = initial position of the trajectory
%       .target = [3,1] = target final position on the trajectory
%
% NOTES:
%   Your code should work for any reasonable set of parameters.
%

param.gravity = 10;  % gravitational acceleration
param.wind = [2; 4; 0]; % nominal wind speed
param.drag = 0.01;  % quadratic drag coefficient
param.mass = 1.0;  % projectile mass
param.start = [0; 0; 0];  % initial position on the trajectory
param.target = [80; -20; 0];  % target position at the end of the trajectory

end

function u = planarQuadrotorHoverThrust(param)
% u = planarQuadrotorHoverThrust(param)
%
% This function returns the thrust that is required to maintain a static 
% hover at any position (angle must be zero).
%
% INPUTS:
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%
% OUTPUTS:
%   u = [2, n] = [u1; u2] = control
%       u1 = left rotor force
%       u2 = right rotor force
%

[u1,u2] = autoGen_planarQuadrotorHoverThrust(param.m, param.g);
u = [u1; u2];

end
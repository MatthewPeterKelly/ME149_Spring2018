function [A, B, dzRef] = planarQuadrotorLinDyn(z, u, param)
% [A, B, dzRef] = planarQuadrotorLinDyn(z, u, param)
%
% This function computes the linearized equations of motion that describe
% the dynamics around some nominal point.
%
% dz = dzRef + A * (z - zRef) + B * (u - uRef)
%
% INPUTS:
%   z = [6, 1] = [x; y; q; dx; dy; dq] = state
%        x = horizontal position
%        y = vertical position
%        q = absolute angle (zero for hover)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq = time-derivative of absolute angle (zero for hover)
%   u = [2, 1] = [u1; u2] = control
%       u1 = left rotor force
%       u2 = right rotor force
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%
% OUTPUTS:
%   A = [6, 6] = jacobian(dz, z);
%   B = [6, 2] = jacobian(dz, u);
%   dzRef = [6, 1] = [dx; dy; dq; ddx; ddy; ddq]
%         = dynamics at the reference state and control
%
% NOTES:
%   For a stationary hover:  q == 0,  u1 = u2 = m * g / 2
%

% Unpack the state and control:
if size(u,2) ~= 1 || size(z,2) ~= 1
    error('Linearized dynamics are not vectorized!');
end
q = z(3,:);
u1 = u(1);
u2 = u(2);

% Unpack the parameters:
m = param.m;
w = param.w;

% Call the automatically generated dynamics function:
[A, B] = autoGen_planarQuadrotorLinDyn(q, u1, u2, m, w);

% Compute the nominal dynamics (if desired)
if nargout > 2
   dzRef = planarQuadrotorDynamics(z, u, param); 
end

end

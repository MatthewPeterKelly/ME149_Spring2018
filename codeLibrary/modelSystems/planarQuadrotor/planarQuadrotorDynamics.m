function dz = planarQuadrotorDynamics(z, u, param)
% dz = planarQuadrotorDynamics(z, u, param)
%
% This function computes the equations of motion for a planar quadrotor.
%
% INPUTS:
%   z = [6, n] = [x; y; q; dx; dy; dq] = state
%        x = horizontal position
%        y = vertical position
%        q = absolute angle (zero for hover)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq = time-derivative of absolute angle (zero for hover)
%   u = [2, n] = [u1; u2] = control
%       u1 = left rotor force
%       u2 = right rotor force
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%
% OUTPUTS:
%   dz = [6, n] = [dx; dy; dq; ddx; ddy; ddq] = state derivative
%
% NOTES:
%   For a stationary hover:  q == 0,  u1 = u2 = m * g / 2
%

% Unpack the state:
q = z(3,:);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);

% Unpack the parameters:
m = param.m;
w = param.w;
g = param.g;

% Zero disturbance forces:
ux = 0;
uy = 0;
uq = 0;

% Call the automatically generated dynamics function:
[ddx, ddy, ddq] = autoGen_planarQuadrotorDynamics(q, u1, u2, ux, uy, uq, m, w, g);

% Pack up the derivative of the state:
dz = [z(4:6,:); ddx; ddy; ddq];

end

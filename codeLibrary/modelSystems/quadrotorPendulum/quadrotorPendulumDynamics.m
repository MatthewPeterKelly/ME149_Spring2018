function dz = quadrotorPendulumDynamics(z, u, param)
% dz = quadrotorPendulumDynamics(z, u, param)
%
% This function computes the equations of motion for a planar quadrotor.
%
% INPUTS:
%   z = [8, n] = [x; y; q1; q2; dx; dy; dq1; dq2] = state
%        x = horizontal position
%        y = vertical position
%        q1 = absolute angle of quadrotor (zero for hover)
%        q2 = absolute angle of pendulum (zero for minimum energy)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq1 = time-derivative of absolute quadrotor 
%        dq2 = time-derivative of absolute pendulum
%   u = [3, n] = [u1; u2; uq] = control
%       u1 = left rotor force
%       u2 = right rotor force
%       uq = control torque on the pendulum
%   param = struct with constant scalar parameters:
%       .m1 = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%       .m1 = mass of the pendulum
%       .l = length of the pendulum
%
% OUTPUTS:
%   dz = [8, n] = [dx; dy; dq1; dq2; ddx; ddy; ddq1; ddq2] = state derivative
%
% NOTES:
%   For a stationary hover:  q1 = q2 = 0,  u1 = u2 = (m1 + m2) * g / 2
%

% Unpack the state:
q1 = z(3,:);
q2 = z(4,:);
dq2 = z(8,:);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);
uq = u(3, :);

% Unpack the parameters:
m1 = param.m1;
m2 = param.m2;
w = param.w;
g = param.g;
l = param.l;

% Zero disturbance forces:
ux = 0;
uy = 0;

% Call the automatically generated dynamics function:
[ddx,ddy,ddq1,ddq2] = autoGen_quadrotorPendulumDynamics(q1, q2, dq2, u1, u2, uq, ux, uy, m1, w, g, m2, l);

% Pack up the derivative of the state:
dz = [z(5:8, :); ddx; ddy; ddq1; ddq2];

end

function [A, B] = quadrotorPendulumLinDyn(z, u, param)
% [A, B] = quadrotorPendulumLinDyn(z, u, param)
%
% This function computes the linearized equations of motion that describe
% the dynamics around some nominal point.
%
% dz = dzRef + A * (z - zRef) + B * (u - uRef)
%
% INPUTS:
%   z = [8, 1] = [x; y; q1; q2; dx; dy; dq1; dq2] = state
%        x = horizontal position
%        y = vertical position
%        q1 = absolute angle of quadrotor (zero for hover)
%        q2 = absolute angle of pendulum (zero for minimum energy)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq1 = time-derivative of absolute quadrotor 
%        dq2 = time-derivative of absolute pendulum
%   u = [2, 1] = [u1; u2] = control
%       u1 = left rotor force
%       u2 = right rotor force
%   param = struct with constant scalar parameters:
%       .m1 = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%       .m1 = mass of the pendulum
%       .l = length of the pendulum
%
% OUTPUTS:
%   A = [8, 8] = jacobian(dz, z);
%   B = [8, 2] = jacobian(dz, u);
%

% Unpack the state and control:
if size(u,2) ~= 1 || size(z,2) ~= 1
    error('Linearized dynamics are not vectorized!');
end

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
l = param.l;

% Call the automatically generated dynamics function:
[A,B] = autoGen_quadrotorPendulumLinDyn(q1,q2,dq2,u1,u2,uq,m1,w,m2,l);

% Drop the rows that correspond to the disturbance forces:
B = B(:, 1:3);

end

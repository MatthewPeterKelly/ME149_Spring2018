function dz = doublePendulumDynamics(z, u, param)
% dz = doublePendulumDynamics(z, u, param)
%
% This function computes the equations of motion for a simple double
% pendulum: point-mass at elbow and wrist with massless rigid links.
%
% INPUTS:
%   z = [4, n] = [q1; q2; dq1; dq2] = state
%        q1 = absolute angle of first link
%        q2 = absolute angle of the second link
%        dq1 = time-derivative of q1
%        dq2 = time-derivative of q2
%   u = [2, n] = [u1; u2] = control
%       u1 = torque acting on link one from the base
%       u2 = torque acting on link two from link one
%   param = struct with constant scalar parameters:
%       .m1 = mass at the elbow
%       .m2 = mass at the wrist
%       .d1 = link one length
%       .d2 = link two length
%       .g = gravity acceleration
%
% OUTPUTS:
%   dz = [4, n] = [dq1; dq2; ddq1; ddq2] = derivative
%
% NOTES:
%   Angles are measured such that z = zeros(4,1) corresponds to the point at
%   which the pendulum is balancing completely inverted, at the point of
%   maximum potential energy.
%

% Unpack the state:
q1 = z(1, :);
q2 = z(2, :);
dq1 = z(3, :);
dq2 = z(4, :);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);

% Unpack the parameters:
m1 = param.m1;
m2 = param.m2;
d1 = param.d1;
d2 = param.d2;
g = param.g;

% Call the automatically generated dynamics function:
[ddq1,ddq2] = autoGen_doublePendulumDynamics(q1,q2,dq1,dq2,u1,u2,m1,m2,d1,d2,g);

% Pack up the derivative of the state:
dz = [dq1; dq2; ddq1; ddq2];

end

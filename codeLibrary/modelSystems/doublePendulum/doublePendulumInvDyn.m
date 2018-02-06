function u = doublePendulumInvDyn(z, ddq, param)
% u = doublePendulumInvDyn(z, ddq, param)
%
% This function computes the torques that are required to achieve a desired
% acceleration, given the current state of the system.
%
% INPUTS:
%   z = [4, n] = [q1; q2; dq1; dq2] = state
%        q1 = absolute angle of first link
%        q2 = absolute angle of the second link
%        dq1 = time-derivative of q1
%        dq2 = time-derivative of q2
%   ddq = [2, n] = [ddq1, ddq2] = acceleration of each link 
%   param = struct with constant scalar parameters:
%       .m1 = mass at the elbow
%       .m2 = mass at the wrist
%       .d1 = link one length
%       .d2 = link two length
%       .g = gravity acceleration
%
% OUTPUTS:
%   u = [2, n] = [u1; u2] = control
%       u1 = torque acting on link one from the base
%       u2 = torque acting on link two from link one
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
ddq1 = ddq(1, :);
ddq2 = ddq(2, :);

% Unpack the parameters:
m1 = param.m1;
m2 = param.m2;
d1 = param.d1;
d2 = param.d2;
g = param.g;

% Call the automatically generated inverse-dynamics function:
[u1,u2] = autoGen_doublePendulumInvDyn(q1,q2,dq1,dq2,ddq1,ddq2,m1,m2,d1,d2,g);
u = [u1; u2];

end

function [totalEnergy, kineticEnergy, potentialEnergy] = doublePendulumEnergy(z, param)
% [totalEnergy, kineticEnergy, potentialEnergy] = doublePendulumEnergy(z, param)
%
% This function computes the mechanical energy associated with the system.
%
% INPUTS:
%   z = [4, n] = [q1; q2; dq1; dq2] = state
%        q1 = absolute angle of first link
%        q2 = absolute angle of the second link
%        dq1 = time-derivative of q1
%        dq2 = time-derivative of q2
%   param = struct with constant scalar parameters:
%       .m1 = mass at the elbow
%       .m2 = mass at the wrist
%       .d1 = link one length
%       .d2 = link two length
%       .g = gravity acceleration
%
% OUTPUTS:
%   totalEnergy = [1, n] = total mechanical energy of the double pendulum
%   kineticEnergy = [1, n] = total kinetic energy of the double pendulum
%   potentialEnergy = [1, n] = total potential energy of the double pendulum
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

% Unpack the parameters:
m1 = param.m1;
m2 = param.m2;
d1 = param.d1;
d2 = param.d2;
g = param.g;

% Call the automatically generated energy function:
[totalEnergy, kineticEnergy, potentialEnergy] = autoGen_doublePendulumEnergy(q1,q2,dq1,dq2,m1,m2,d1,d2,g);

end

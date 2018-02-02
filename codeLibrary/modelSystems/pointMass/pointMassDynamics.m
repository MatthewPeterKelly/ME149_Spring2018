function dz = pointMassDynamics(z, u)
% dz = pointMassDynamics(z, u)
%
% This function computes the dynamics for a unit point mass.
%
% INPUTS:
%   z = [2*nDof, nTime] = [position; velocity] = current state of the system
%   u = [nDof, nTime] = [torque] = force applied to the system
%
% OUTPUTS:
%   dz = [2*nDof, nTime] = [velocity, accel] = time-derivative at current state
%

nDof = size(u, 1);  % number of degrees of freedom

iVel = (nDof+1) : 2*nDof;  % row index corresponding to velocity states
vel = z(iVel, :);  % velocity

dPos = vel;  % dynamics in first-order form
dVel = u;  % force = mass * acceleration --> accel = force / (mass = 1)

dz = [dPos; dVel];  % pack up the derivative

end

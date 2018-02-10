function u = pointMassInvDyn(~, acc)
%  u = pointMassInvDyn(z, acc)
%
% This function computes the inverse dynamics for a unit point mass.
%
% INPUTS:
%   z = [2*nDof, nTime] = [position; velocity] = current state of the system
%   acc = [nDof, nTime] = [accel] = time-derivative at current state
%
% OUTPUTS:
%   u = [nDof, nTime] = [torque] = force applied to the system
%

u = acc;  % the mass is one, with no other terms (system is simple integrator)

end

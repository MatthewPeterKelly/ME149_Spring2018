function dz = PendulumDynamics(~, z)
% dz = PendulumDynamics(t, z)
%
% This function computes the dynamics for a simple pendulum.
% All parameters are set to unity and there is no friction.
%
% INPUTS:
%   t = [1, nTime] = row vector of query times
%   z = [2, nTime] = [angle; rate] = current state of the system
%
% OUTPUTS:
%   dz = [2, nTime] = [rate, accel] = time-derivative at current state
%
% NOTES:
%   q = angle of the pendulum
%   w = angular rate of the pendulum (derivative of angle)
%   dw = angular acceleration of the pendulum (derivative of rate)
%   dynamics:
%       dw = -sin(q)
%

%%%% TODO: Implement this function

end

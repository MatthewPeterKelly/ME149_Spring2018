function dz = drivenDampedPendulumDynamics(t, z)
%  dz = drivenDampedPendulumDynamics(t, z)
%
% Compute the dynamics of the canonical "driven damped pendulum", a system
% that is famous for its chaotic behavior (and neat fractals).
%
% This function computes the dynamics of a single pendulum with linear
% viscous friction and a sinusoidal (torque) forcing function.
%
% INPUTS:
%   t = [1, nTime] = query times
%   z = [2, nTime] = [q; dq] = [angles; rates] = states
%
% OUTPUTS:
%   dz = [2, nTime] = [dq; ddq] = [rates; accel] = time-derivative of state
%
% NOTES:
%
% q'' = cos(t)-0.1*q'-sin(q)
%

% unpack the state of the system
q = z(1,:);
qd = z(2,:);

% accel = (driving torque - damping torque - gravity torque) / mass
qdd = cos(t) - 0.1*qd - sin(q);

% pack up the derivative
dz = [qd;qdd];

end

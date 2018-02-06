function u = simplePendulumInvDyn(z, ddq, param)
% u = simplePendulumInvDyn(z, ddq, param)
%
% This function computes the inverse dynamics for a simple pendulum.
%
% INPUTS:
%   z = [2, nTime] = [angle; rate] = current state of the system
%   ddq = [1, nTime] = accel
%   param = struct = parameters of the pendulum
%     .freq = scalar = undamped natural frequency squared
%                    = (gravity / length) for a point mass pendulum
%     .damp = scalar = normalized linear viscous friction term
%
% OUTPUTS:
%   u = [1, nTime] = [torque] = torque applied to the system
%
% INVERSE DYNAMICS:
%   u = ddq + (param.freq) * sin(q) + (param.damp) * dq
%
% NOTES:
%   q = angle of the pendulum (measured from stable configuration)
%   dq = w = angular rate of the pendulum (derivative of angle)
%   ddq = dw = angular acceleration of the pendulum (derivative of rate)
%
%   --> Be careful when including a damping term in the inverse dynamics
%   calculation (like is done here). This can cause problems on any real
%   system where the rate is computed by differentiating the angle sensor.
%   The first problem is that damping is typically a poorly-modeled aspect
%   of a given system, increasing the chance that there will be a
%   significant discrepancy between the predicted and measured damping.
%   The second problem is that a discrepancy in the damping model can lead
%   to a negative damping term: a numerical instability. 
%   One solution to this issue is to reduce the damping coefficient that is
%   passed to the inverse dynamics, or to remove it entirely.
%

q = z(1,:);  % angle
w = z(2,:);  % rate

k = param.freq;
b = param.damp;  % be careful with the damping parameter - see note.

u = ddq + k * sin(q) + b * w; % torque required for inverse dynamics

end

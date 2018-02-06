function dz = simplePendulumDynamics(z, u, param)
% dz = simplePendulumDynamics(z, u, param)
%
% This function computes the dynamics for a simple pendulum.
%
% INPUTS:
%   z = [2, nTime] = [angle; rate] = current state of the system
%   u = [1, nTime] = [torque] = torque applied to the system
%   param = struct = parameters of the pendulum
%     .freq = scalar = undamped natural frequency squared
%                    = (gravity / length) for a point mass pendulum
%     .damp = scalar = normalized linear viscous friction term
%
% OUTPUTS:
%   dz = [2, nTime] = [rate, accel] = time-derivative at current state
%
% NOTES:
%   q = angle of the pendulum (measured from stable configuration)
%   dq = w = angular rate of the pendulum (derivative of angle)
%   ddq = dw = angular acceleration of the pendulum (derivative of rate)
%
% DYNAMICS:
%   ddq = u - (param.freq) * sin(q) - (param.damp) * dq
%

q = z(1,:);  % angle
w = z(2,:);  % rate

k = param.freq;
b = param.damp;

dq = w;  % time-derivative of angle (rate)
dw = u - k * sin(q) - b * w; % time-derivative of rate (acceleration)

dz = [dq; dw];

end

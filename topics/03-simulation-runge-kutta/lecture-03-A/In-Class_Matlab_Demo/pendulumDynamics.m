function dz = pendulumDynamics(~, z, param)
% dz = pendulumDynamics(t, z, param)
%
% Computes the pendulum dynamics
%
% INPUTS:
%   t = [1, nTime] = time vector 
%   z = [2, nTime] = [q; w] = [angle; rate] = state vector
%   param = struct with parameters
%     .g = scalar = gravity
%     .l  = scalar = length
%
% OUTPUTS:
%   dz = [2, nTime] = [dq; dw] = [rate; accel] = state derivative
%

% unpack the parameters
g = param.g;
l = param.l;

% unpack the state
q = z(1, :);
w = z(2, :);

% compute dynamics
dq = w;
dw = -g*sin(q)/l;

% pack up the state
dz =[dq; dw];

end

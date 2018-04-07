function [hoverController, zHover, uHover] = quadrotorPendulumHoverController(xRef, yRef, param, inverted)
% [hoverController, zHover, uHover] = quadrotorPendulumHoverController(xRef, yRef, param, inverted)
%
% This function designs a controller that will allow the quadrotor to
% hover at [xRef, yRef] with the pendulum in either the stable or the
% inverted configuration.
%
% INPUTS:
%   xRef = scalar = horizontal position for the hover
%   yRef = scalar = vertical position for the hover
%   param = struct with constant scalar parameters:
%       .m1 = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%       .m1 = mass of the pendulum
%       .l = length of the pendulum
%   inverted = boolean = should the pendulum be inverted?
%
% OUTPUTS:
%   hoverController = function handle:  u = hoverController(z)
%       IN: z = [8, n] = [x; y; q1; q2; dx; dy; dq1; dq2] = state
%              x = horizontal position
%              y = vertical position
%              q1 = absolute angle of quadrotor (zero for hover)
%              q2 = absolute angle of pendulum (zero for minimum energy)
%              dx = time-derivative of horizontal position
%              dy = time-derivative of vertical position
%              dq1 = time-derivative of absolute quadrotor 
%              dq2 = time-derivative of absolute pendulum
%       OUT: u = [3, n] = [u1; u2; uq] = control
%              u1 = left rotor force
%              u2 = right rotor force
%              uq = control torque on the pendulum
%

if inverted
    qRef = pi;
else
    qRef = 0;
end

% Target at which to hover
zHover = [xRef;  % x-pos
    yRef;  % y-pos
    0;  % quadrotor angle
    qRef;  % pendulum angle
    zeros(4,1)];  

% Nominal inputs for hover
weight = (param.m1 + param.m2) * param.g;
uHover = 0.5 * weight * [1;1;0];

% Linearized system dynamics about hover state:
[A, B] = quadrotorPendulumLinDyn(zHover, uHover, param);

% Set the tolerable errors in state and values in actuation
zTol = [0.1;  % x
        0.1;  % y
        0.8;  % q1
        0.4;  % q2
        0.3;  % dx
        0.3;  % dy
        1.0; % dq1
        0.4];  % dq2
uTol = 0.6 * [1;1;0.3];  % tolerable actuation effort above nominal

% Cost terms for the infinite-horizon LQR controller:
Q = diag(1./(zTol.^2));  % cost on state errors
R = diag(1./(uTol.^2));  % cost on actuator effort
N = [];  % cost on coupling between state and actuation

% Compute the infinite-horizon LQR controller:
K = lqr(A, B, Q, R, N);

% Define the feed-back controller (hover controller)
hoverController = @(z)( quadrotorHoverController(z, K, zHover, uHover) );

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function u = quadrotorHoverController(z, K, zHover, uHover)
% u = quadrotorHoverController(z, K, zHover, uHover)
%
% Stabilize zHover with a linear feed-back controller.
%

% Target position and nominal thrust
nTime = size(z, 2);
if nTime > 1
    zHover = zHover * ones(1, nTime);
end

% Control law:
u = uHover - K * (z - zHover);

end

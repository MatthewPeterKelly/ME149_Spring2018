function hoverController = getHoverController(xRef, yRef, param)
% hoverController = getHoverController(xRef, yRef, param)
%
% This function designs a controller that will allow the quadrotor to
% hover at a fixed position, despite the presence of various disturbances.
% The linear controller gains are designed using infinite-horizon LQR
%
% INPUTS:
%   xRef = scalar = horizontal position for the hover
%   yRef = scalar = vertical position for the hover
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
% OUTPUTS:
%   hoverController = function handle:  u = hoverController(z)
%       IN: z = [6, n] = [x; y; q; dx; dy; dq] = state
%             x = horizontal position
%             y = vertical position
%             q = absolute angle (zero for hover)
%             dx = time-derivative of horizontal position
%             dy = time-derivative of vertical position
%             dq = time-derivative of absolute angle (zero for hover)
%       OUT: u = [2, n] = [u1; u2] = control
%             u1 = left rotor force
%             u2 = right rotor force
%
% NOTES:
%   The nominal system dynamics for the quadrotor are defined in:
%
%        ME149/codeLibrary/modelSystems/planarQuadrotor/
%

% Target at which to hover
zHover = [xRef;  % x-pos
    yRef;  % y-pos
    0;  % angle
    zeros(3,1)];  % hover one meter off the ground at the origin

% Nominal inputs for hover
uHover = planarQuadrotorHoverThrust(param);

% Linearized system dynamics about hover state:
[A, B] = planarQuadrotorLinDyn(zHover, uHover, param);

% TODO: normalize the following by the hover parameters

% Set the tolerable errors in state and values in actuation
zTol = [0.1;  % tolerable error in horizontal position (m)
    0.1;  % tolerable error in vertical position (m)
    0.8;  % tolerable error in angle (rad)
    0.3;  % tol. error in horiz. vel. (m/s)
    0.3;  % tol. error in vert. vel. (m/s)
    1.0];  % tol. error in ang. vel. (m/s)
uTol = 0.6 * [1;1];  % tolerable actuation effort above nominal

% Cost terms for the infinite-horizon LQR controller:
Q = diag(1./(zTol.^2));  % cost on state errors
R = diag(1./(uTol.^2));  % cost on actuator effort
N = [];  % cost on coupling between state and actuation

% Compute the infinite-horizon LQR controller:
K = lqr(A, B, Q, R, N);

% Define the feed-back controller (hover controller)
hoverController = @(z)( quadrotorHoverController(z, K, param, zHover(1:2)) );

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function u = quadrotorHoverController(z, K, param, pos)
% u = quadrotorHoverController(z, K, param, pos)
%
% Compute the thrust to regular a hover at pos.
%
% INPUTS:
%   z = [6, n] = [x; y; q; dx; dy; dq] = state
%        x = horizontal position
%        y = vertical position
%        q = absolute angle (zero for hover)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq = time-derivative of absolute angle (zero for hover)
%   K = [6, 6] = linear gain matrix
%       u = uHover - K * (z - zTarget)
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%   pos = [2, n] = [x; y]; = target hover position
%
% OUTPUTS
%   u = [2, n] = thrust force at each rotor to regular the hover
%

% Target position and nominal thrust
nTime = size(z, 2);
if size(pos,2) == 1 && nTime > 1
    pos = pos * ones(1, nTime);
end
zTarget = [pos; zeros(4, nTime)];  % target pose
uHover = 0.5 * param.m * param.g * ones(2, nTime);  % gravity thrust

% Control law:
u = uHover - K * (z - zTarget);

end

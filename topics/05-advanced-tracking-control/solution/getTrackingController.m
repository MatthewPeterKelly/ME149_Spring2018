function [controller, gains] = getTrackingController(ref, param)
% [controller, gains] = getTrackingController(ref, param)
%
% This function designs a controller that will track a specified reference
% trajectory using finite-horizon LQR.
%
% INPUT REQUIREMENTS:
%   - the reference trajectory must be feasible
%   - the reference trajectory must end in a fixed-point (hover)
%
% CONTROLLER REQUIREMENTS:
%   - let [tLow, tUpp] be the time domain of the reference trajectory
%   - the behavior is undefined if input time t < tLow
%   - the controller must regulate the final state on the trajectory for any
%     input time t > tUpp.
%
% INPUTS:
%   ref = struct with a reference trajectory
%     .state = Matlab PP struct = state reference trajectory
%     .control = Matlab PP struct = nominal (feed-forward) control
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%
% OUTPUTS:
%   controller = function handle:  u = controller(t, z)
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
%   gains = Matlab PP struct = LQR gains along the trajectory
%       K(t) = reshape(ppval(gains, t), nState, nControl);
%
% NOTES:
%   The nominal system dynamics for the quadrotor are defined in:
%        ME149/codeLibrary/modelSystems/planarQuadrotor/
%

%%%% Compute the LQR cost matricies:
%
% TODO
%

% Set the tolerable errors in state and values in actuation
zTol = [0.1;  % tolerable error in horizontal position (m)
    0.1;  % tolerable error in vertical position (m)
    0.8;  % tolerable error in angle (rad)
    0.3;  % tol. error in horiz. vel. (m/s)
    0.3;  % tol. error in vert. vel. (m/s)
    0.7];  % tol. error in ang. vel. (m/s)
uTol = 0.6 * [1;1];  % tolerable actuation effort above nominal

% Cost terms for the LQR controller:
Q = diag(1./(zTol.^2));  % cost on state errors
R = diag(1./(uTol.^2));  % cost on actuator effort

% Linearized system dynamics as a function of time (for the ref. traj.)
linSys = @(t)( quadrotorLinearSystem(t, ref, param) );

% Compute the LQR gains along the trajectory
refTime = ref.state.breaks;
refGains = trajectoryLqr(refTime, linSys, Q, R);
gains = pchip(refTime, refGains);

% Write the closed-loop dynamics, including tracking controller
controller = @(t, z)( quadrotorTrackingController(t, z, ref, gains) );

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [A, B] = quadrotorLinearSystem(t, ref, param)
%
% Wrapper for the planar quadrotor linearized dynamics about a reference
% trajectory. Used to abstract the reference trajectory away before passing
% to the trajectory LQR function.
%

% Evaluate the reference trajectory
refState = ppval(ref.state, t);
refCtrl = ppval(ref.control, t);

% Evaluate the linearized dynamics at this specific point.
[A, B] = planarQuadrotorLinDyn(refState, refCtrl, param);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function u = quadrotorTrackingController(t, z, ref, gains)
%
% Compute the controller to follow the reference trajectory
%

nTime = length(t);
if nTime > 1  % Special case: loop over time
    u = zeros(2, nTime);
    for iTime = 1:nTime
       u(:, iTime) = quadrotorTrackingController(t(iTime), z(:, iTime), ref, gains);
    end
    return;
end

% Clamp the time to the domain of the reference trajectory
t = min(max(ref.time(1), t), ref.time(end));

% Compute the reference position and velocity:
refState = ppval(ref.state, t);

% Compute the feed-forward actuation:
refCtrl = ppval(ref.control, t);

% Compute the perturbed position and velocity:
zDel = z - refState;

% Compute the linear feed-back gains:
k = ppval(gains, t);  % feedback gains, vector form
nInput = 2;  % TODO: clean up
nState = 6;  % TODO: clean up
K = reshape(k, nInput, nState);

% Tracking controller:
u = refCtrl - K * zDel;

end

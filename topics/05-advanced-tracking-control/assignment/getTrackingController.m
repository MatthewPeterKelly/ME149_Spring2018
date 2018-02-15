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

%%%% TODO: specify the maximum "tolerable" state perturbation and control effort

%%%% TODO: set the (constant) state (Q) and actuator (R) cost matricies

%%%% TODO: call trajectoryLqr() to compute gains along the trajectory

%%%% TODO: fit a cubic spline to the gains using pchip()

%%%% TODO: return the function handle for the controller

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function u = quadrotorTrackingController(t, z, ref, gains)
%
%%%% TODO: document this function if you choose to use it (delete it otherwise)
%

%%%% TODO: compute reference state and control

%%%% TODO: compute the feed-back gain matrix K

%%%% TODO: compute the output control (nominal + feedback)

end

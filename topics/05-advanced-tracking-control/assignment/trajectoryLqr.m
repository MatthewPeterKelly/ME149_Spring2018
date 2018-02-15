function kGrid = trajectoryLqr(tGrid, linSys, Q, R)
% kGrid = trajectoryLqr(tGrid, linSys, Q, R)
%
% Computes the LQR gains along a linearized reference trajectory.
%
% INPUTS:
%   tGrid = [1, nGrid] = monotonically increasing time grid
%                        used to perform back-propagation of cost to go
%   linSys = function handle:   [A, B] = linRefTraj(t)
%         IN: time (scalar) - query time
%         OUT: A = [nState, nState] = df/dz
%         OUT: B = [nState, nInput] = df/du
%   Q = [nState, nState] = cost matrix: deviation from state reference
%                          should be symmetric (and typically > 0)
%   R = [nInput, nInput] = cost matrix: actuator effort
%                          should be symmetric (and typically > 0)
%   tol = scalar = tolerance for back-propagation
%
% OUTPUTS:
%   kGrid = [nState*nState, nGrid] = linear gain matrix at each time in tGrid
%
%                  K(t(i)) = reshape(kGrid(:,i), nState, nState);
%
%                  kGrid(:,i) = reshape(K(t(i)), nState*nState, 1);
%
% NOTES:
%
%   J = x'Fx + Integral {x'Qx + u'Ru} dt
%
%   Each column in K is a single gain matrix, flattened into a vector.
%
%   This solver assumes that the trajectory starts and ends at a
%   fixed-point (the dynamics are zero). This is used to set the terminal
%   cost such that there is a smooth transition to a regulating controller
%   at the final point.
%
%   This implementation assumes that the cost matricies Q, R, and F are
%   constant. The implementation could be trivially extended such that
%   these matricies are time-varying along with the dynamics.
%
%   How to compute the infinite-horizon LQR gains? Set S(0) = 0 and then
%   backpropagate the solution with a constant A, B, Q, R matrix until you
%   reach a fixed point dS = 0. At that point you compute the gains K as
%   below and then return.
%
% REFERENCE:
%
% The equations implemented in this function are from the paper:
%
% "LQR-Trees: Feedback Motion Planning via Sums-of-Squares Verification"
%  2010   (originally presented at RSS 2009)
%  Russ Tedrake, Ian R. Manchester, Mark Tobenkin, John W. Roberts
%
% See Also LQR

% Compute the steady-state controller at the final position:
Qf = computeTerminalCost(tGrid, linSys, Q, R);

%%%% TODO: Compute the cost to go S(t) via back-propagation
% hint: you can use any simulation method. I suggest RK4 or ode45.

%%%% TODO: use the cost to go at each time to compute the gains:

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function Qf = computeTerminalCost(tGrid, linSys, Q, R)
%
% This function computes the terminal cost for the LQR trajectory tracking
% controller assuming that the final point on the trajectory is at a fixed
% point and that the controller will just use the final gain matrix to
% stabilize that fixed point indefinitely. In this special case, the
% terminal cost can be computed by solving the infinite-horizon LQR
% controller at the final point on the trajectory.
%
% Inputs are the same as for the primary function in this file.
%
% Note: The terminal cost is the solution of the algebraic ricatti equation
% that is associated with the linearized system at the tGrid(end)
%

%%%% TODO: implement this function (hint: it only requires two lines of code)

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function dS = ricattiDynFun(t, S, linSys, Q, R, nState)
%
% This function computes the differential equation that is solved to
% compute the cost-to-go. The key equation is:
%
%   K = R \ B' * S
% −dS = Q − S * B * K + S * A + A' * S
%
% When solved with the boundary condition: S(tf) = Qf the cost to go is:
%
% J(xBar, t) = xBar' * S(t) * xBar
%
% The optimal feedback policy is:
%
% uBar(t) = -inv(R) * B' * S(t) * xBar
%

%%%% TODO: you may find this function useful. If so, then implement it.

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function kGrid = computeGainMatrix(tGrid, sGrid, linSys, R, nState)
%
% Compute the gain matrix (formatted as a column vector) at each time step,
% given the cost-to-go matrix (S), the linear system (B), and the actuation
% cost (R) at each time step.
%
% NOTES:
%   This function is redundant: these gains are already computed during the
%   back-propagation step. This is done to help keep the code readable and
%   to call an independent simulation method.
%   If you were planning to use time-varying LQR gains in a time-critical
%   application then it would be good to optimize the code, only computing
%   these gains a single time during the back-propagation step.
%
%   The gain at any single step is given by the following matrix equation:
%       K = R \ B' * S;
%
%   Reshaping between vectors and matricies:
%       S(tGrid(i)) = reshape(sGrid(:,iGrid), nState, nState);
%       kGrid(:,iGrid) = reshape(K, numel(K), 1);
%
% INPUTS are the same as for the primary function in this file, except:
%   sGrid = [nState*nState, nTime] = cost to go at each time in tGrid
%

%%%% TODO: implement this function if you find it useful.

end

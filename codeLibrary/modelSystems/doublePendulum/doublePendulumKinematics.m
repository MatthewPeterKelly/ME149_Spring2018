function [p1, p2, dp1, dp2] = doublePendulumKinematics(z, param)
% [p1, p2, dp1, dp2] = doublePendulumKinematics(z, param)
%
% This function computes the forward kinematics for a double pendulum.
%
% INPUTS:
%   z = [4, n] = [q1; q2; dq1; dq2] = state
%        q1 = absolute angle of first link
%        q2 = absolute angle of the second link
%        dq1 = time-derivative of q1
%        dq2 = time-derivative of q2
%   param = struct with constant scalar parameters:
%       .m1 = mass at the elbow
%       .m2 = mass at the wrist
%       .d1 = link one length
%       .d2 = link two length
%       .g = gravity acceleration
%
% OUTPUTS:
%   p1 = [2, n] = [p1x; p1y] = position of the elbow
%   p2 = [2, n] = [p2x; p2y] = position of the wrist
%   dp1 = [2, n] = [dp1x; dp1y] = velocity of the elbow
%   dp2 = [2, n] = [dp2x; dp2y] = velocity of the wrist
%
% NOTES:
%   Angles are measured such that z = zeros(4,1) corresponds to the point at
%   which the pendulum is balancing completely inverted, at the point of
%   maximum potential energy.
%

% Unpack the state:
q1 = z(1, :);
q2 = z(2, :);
dq1 = z(3, :);
dq2 = z(4, :);

% Unpack the parameters:
m1 = param.m1;
m2 = param.m2;
d1 = param.d1;
d2 = param.d2;

% Call the automatically generated kinematics function:
if nargout >= 3  % Compute the full kinematics
  [p1x,p1y,p2x,p2y,dp1x,dp1y,dp2x,dp2y] = autoGen_doublePendulumKinematics(q1,q2,dq1,dq2,d1,d2);
else  % compute position only
  [p1x,p1y,p2x,p2y] = autoGen_doublePendulumKinematics(q1,q2,dq1,dq2,d1,d2);
end

% Pack up the position:
p1 = [p1x; p1y];
p2 = [p2x; p2y];

% Pack up the velocity:
if nargout >= 3
  dp1 = [dp1x; dp1y];
  dp2 = [dp2x; dp2y];
end

end

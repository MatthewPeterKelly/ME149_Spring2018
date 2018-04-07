function quadrotorPendulumAnimate(t, z, u, param, playbackSpeed)
% quadrotorPendulumAnimate(t, z, u, param, playbackSpeed)
%
% Generate an animation of the quadrotor on the current figure.
%
% INPUTS:
%   t = [1, n] = monotonically increasing vector of times
%   z = [8, n] = [x; y; q1; q2; dx; dy; dq1; dq2] = state
%        x = horizontal position
%        y = vertical position
%        q1 = absolute angle of quadrotor (zero for hover)
%        q2 = absolute angle of pendulum (zero for minimum energy)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq1 = time-derivative of absolute quadrotor 
%        dq2 = time-derivative of absolute pendulum
%   u = [2, n] = [u1; u2] = control
%       u1 = left rotor force
%       u2 = right rotor force
%   param = struct with constant scalar parameters:
%       .m1 = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%       .m1 = mass of the pendulum
%       .l = length of the pendulum
%   playbackSpeed = scalar = default: 0.5
%       how fast to play the animation (1.0 == real time)
%

if nargin < 5
    playbackSpeed = 0.5;
end

d = 0.55 * param.w;
x = z(1, :);
y = z(2, :);
xLim = [min(x) - d, max(x) + d];
yLim = [min(y) - d, max(y) + d];
P.plotFunc = @(t, zu)( quadrotorPendulumDraw(t, zu(1:8), zu(9:10), param, xLim, yLim) );
P.speed = playbackSpeed;
P.figNum = gcf();
animate(t, [z; u], P);

end
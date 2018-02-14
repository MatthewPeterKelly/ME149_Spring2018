function planarQuadrotorAnimate(t, z, u, param, playbackSpeed)
% planarQuadrotorAnimate(t, z, u, param, playbackSpeed)
%
% Generate an animation of the quadrotor on the current figure.
%
% INPUTS:
%   t = [1, n] = monotonically increasing vector of times
%   z = [6, n] = [x; y; q; dx; dy; dq] = state
%        x = horizontal position
%        y = vertical position
%        q = absolute angle (zero for hover)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq = time-derivative of absolute angle (zero for hover)
%   u = [2, n] = [u1; u2] = control
%       u1 = left rotor force
%       u2 = right rotor force
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
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
P.plotFunc = @(t, zu)( planarQuadrotorDraw(t, zu(1:6), zu(7:8), param, xLim, yLim) );
P.speed = playbackSpeed;
P.figNum = gcf();
animate(t, [z; u], P);

end
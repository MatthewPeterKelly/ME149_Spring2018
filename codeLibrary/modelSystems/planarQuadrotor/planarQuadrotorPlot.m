function planarQuadrotorPlot(t, z, u, param, showAnimation)
% planarQuadrotorPlot(t, z, u, param, showAnimation)
%
% Creates a plot the the state and control vs time for the planar quadrotor
%
% INPUTS:
%   t = [1, n] = simulation time
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
%   showAnimation = boolean = optional (default = false)
%                   if true, then show a stop-action animation
%
%
clf;
if nargin < 5
    showAnimation = false;
end

% Unpack the state:
x = z(1, :);
y = z(2, :);
q = z(3, :);
dx = z(4, :);
dy = z(5, :);
dq = z(6, :);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);

% Plots:
hSub(1) = subplot(3, 2, 1); hold on;
plot(t, x, 'r-', 'lineWidth', 2);
plot(t, y, 'b-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('position (m)')
title('center of mass position')
legend('x','y');

hSub(2) = subplot(3, 2, 2); hold on;
plot(t, dx, 'r-', 'lineWidth', 2);
plot(t, dy, 'b-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('velocity (m/s)')
title('center of mass velocity')
legend('dx','dy');

hSub(3) = subplot(3, 2, 3);
plot(t, q, 'k-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('angle (rad)')
title('quadrotor angle')

hSub(4) = subplot(3, 2, 4);
plot(t, dq, 'k-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('rate (rad/s)')
title('quadrotor anglular rate')

hSub(5) = subplot(3, 2, 5); hold on;
plot(t, u1, 'g-', 'lineWidth', 2);
plot(t, u2, 'm-', 'lineWidth', 2);
xlabel('time (s)')
ylabel('thrust (N)')
title('rotor thrust')
legend('u1','u2');

linkaxes(hSub, 'x');

% Draw a stop-action animation for the final figure
if showAnimation
    subplot(3, 2, 6); hold on;
    d = 0.55 * param.w;
    xLim = [min(x) - d, max(x) + d];
    yLim = [min(y) - d, max(y) + d];
    tFrame = linspace(t(1), t(end), 10);  % frames to plot
    zFrame = interp1(t', z', tFrame')';
    uFrame = interp1(t', u', tFrame')';
    for iFrame = 1:length(tFrame)
        planarQuadrotorDraw(tFrame(iFrame), zFrame(:, iFrame), ...
            uFrame(:, iFrame),  param, xLim, yLim);
    end
end

end

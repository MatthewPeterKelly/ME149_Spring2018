function quadrotorPendulumPlot(t, z, u)
% quadrotorPendulumPlot(t, z, u)
%
% Creates a plot the the state and control vs time for the planar quadrotor
%
% INPUTS:
%   t = [1, n] = simulation time
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
%
%
clf;

% Unpack the state:
x = z(1, :);
y = z(2, :);
q1 = z(3, :);
q2 = z(4, :);
dx = z(5, :);
dy = z(6, :);
dq1 = z(7, :);
dq2 = z(8, :);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);
uq = u(3, :);

% Colors:
colors = lines(7);

% Plots:
hSub(1) = subplot(3, 2, 1); hold on;
plot(t, x, '-', 'lineWidth', 2, 'Color', colors(1,:));
plot(t, y, '-', 'lineWidth', 2, 'Color', colors(2,:));
xlabel('time (s)')
ylabel('position (m)')
title('center of mass position')
legend('x','y');

hSub(2) = subplot(3, 2, 2); hold on;
plot(t, dx, '-', 'lineWidth', 2, 'Color', colors(1,:));
plot(t, dy, '-', 'lineWidth', 2, 'Color', colors(2,:));
xlabel('time (s)')
ylabel('velocity (m/s)')
title('center of mass velocity')
legend('dx','dy');

hSub(3) = subplot(3, 2, 3); hold on;
plot(t, q1, '-', 'lineWidth', 2, 'Color', colors(3,:));
plot(t, q2, '-', 'lineWidth', 2, 'Color', colors(4,:));
xlabel('time (s)')
ylabel('angle (rad)')
title('angle')
legend('q1','q2');

hSub(4) = subplot(3, 2, 4); hold on;
plot(t, dq1, '-', 'lineWidth', 2, 'Color', colors(3,:));
plot(t, dq2, '-', 'lineWidth', 2, 'Color', colors(4,:));
xlabel('time (s)')
ylabel('rate (rad/s)')
title('anglular rate')
legend('dq1','dq2');

hSub(5) = subplot(3, 2, 5); hold on;
plot(t, u1, '-', 'lineWidth', 2, 'Color', colors(5,:));
plot(t, u2, '-', 'lineWidth', 2, 'Color', colors(6,:));
xlabel('time (s)')
ylabel('thrust (N)')
title('rotor thrust')
legend('u1','u2');

hSub(6) = subplot(3, 2, 6); hold on;
plot(t, uq, '-', 'lineWidth', 2, 'Color', colors(4,:));
xlabel('time (s)')
ylabel('torque (Nm)')
title('pendulum stabilization')

linkaxes(hSub, 'x');

end

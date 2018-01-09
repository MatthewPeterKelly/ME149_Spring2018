function doublePendulumPlot(t, z, u, param)
% doublePendulumPlot(t, z, u, param)
%
% INPUTS:
%   t = [1, n] = simulation time
%   z = [4, n] = [q1; q2; dq1; dq2] = state
%        q1 = absolute angle of first link
%        q2 = absolute angle of the second link
%        dq1 = time-derivative of q1
%        dq2 = time-derivative of q2
%   u = [2, n] = [u1; u2] = control
%       u1 = torque acting on link one from the base
%       u2 = torque acting on link two from link one
%   param = struct with constant scalar parameters:
%       .m1 = mass at the elbow
%       .m2 = mass at the wrist
%       .d1 = link one length
%       .d2 = link two length
%       .g = gravity acceleration
%
% NOTES:
%   Angles are measured such that z = zeros(4,1) corresponds to the point at
%   which the pendulum is balancing completely inverted, at the point of
%   maximum potential energy.
%

[totalEnergy, kineticEnergy, potentialEnergy] = doublePendulumEnergy(z, param);

% Unpack the state:
q1 = z(1, :);
q2 = z(2, :);
dq1 = z(3, :);
dq2 = z(4, :);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);

% Plots:
hSub(1) = subplot(2, 3, 1);
plot(t, q1, 'r-', 'lineWidth', 2);
xlabel('t')
ylabel('q1')
title('link one angle')

hSub(2) = subplot(2, 3, 2);
plot(t, q2, 'b-', 'lineWidth', 2);
xlabel('t')
ylabel('q2')
title('link two angle')

hSub(4) = subplot(2, 3, 4);
plot(t, dq1, 'r-', 'lineWidth', 2)
xlabel('t')
ylabel('dq1')
title('link one rate')

hSub(5) = subplot(2, 3, 5);
plot(t, dq2, 'b-', 'lineWidth', 2)
xlabel('t')
ylabel('dq2')
title('link two rate')

hSub(3) = subplot(2, 3, 3); hold on
plot(t, totalEnergy, 'k', 'lineWidth', 2)
plot(t, kineticEnergy, 'g', 'lineWidth', 2)
plot(t, potentialEnergy, 'm', 'lineWidth', 2)
legend('total','kinetic','potential')
xlabel('t')
ylabel('e');
title('mechanical energy')

hSub(6) = subplot(2, 3, 6); hold on
plot(t, u1, 'r-', 'lineWidth', 2);
plot(t, u2, 'b-', 'lineWidth', 2);
xlabel('t')
ylabel('u')
legend('u1','u2');
title('control torque')

linkaxes(hSub, 'x');

end

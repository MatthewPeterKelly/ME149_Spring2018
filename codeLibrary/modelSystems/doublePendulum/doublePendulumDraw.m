function doublePendulumDraw(t, z, param)
% doublePendulumDraw(t, z, param)
%
% Draw a double pendulum. Designed to be used inside of an animation callback.
%
% INPUTS:
%   t = scalar = simulation time
%   z = [4, 1] = [q1; q2; dq1; dq2] = state
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

clf; hold on;
lengthScale = param.d1 + param.d2;
axis equal; axis(lengthScale*[-1,1,-1,1]);

[p1, p2] = doublePendulumKinematics(z, param);
pos = [[0; 0], p1, p2];

plot(0, 0, 'ks', 'MarkerSize', 25, 'LineWidth', 4);
plot(pos(1,:), pos(2,:), 'Color', [0.1, 0.8, 0.1], 'LineWidth', 4);
plot(pos(1,:), pos(2,:), 'ko', 'MarkerSize', 15, 'LineWidth', 3);

title(sprintf('Passive Double Pendulum Animation,  t = %6.4f',t));

drawnow; pause(0.01);

end

function quadrotorPendulumDraw(t, z, u, param, xLim, yLim)
% quadrotorPendulumDraw(t, z, u, param, xLim, yLim)
%
% Creates a visualization of the quadrotor at a single point in time.
%
% INPUTS:
%   t = scalar = simulation time
%   z = [8, 1] = [x; y; q1; q2; dx; dy; dq1; dq2] = state
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
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%   xLim = [1, 2] = [xLow, xUpp] = horizontal limits on plot axis
%   yLim = [1, 2] = [yLow, yUpp] = vertical limits on plot axis
%
%
hold on;

% Unpack the state:
x = z(1, :);
y = z(2, :);
q1 = z(3, :);
q2 = z(4, :);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);

% Unpack the parameters:
m1 = param.m1;
w = param.w;
g = param.g;
l = param.l;

% Kinematics (get positions for plotting)
[p0, p1, p2, ~, ~, p1v, p2v] = autoGen_quadrotorPendulumKinematics(x, y, q1, q2, u1, u2, m1, w, g, l);

% Draw the ground:
plot(xLim(:), [0; 0], 'Color', [0.4, 0.2, 0.1], 'LineWidth', 3);

% Draw the quadrotor itself:
drawQuadrotor(x, y, q1, w, 'k');

% Draw the center of mass:
plot(p0(1), p0(2), 'y.', 'MarkerSize', 25);

% Draw the pendulum:
drawPendulum(p0(1), p0(2), q2, l, [0.2, 0.3, 0.7]);

% Draw the thrust vectors:
drawArrow(p1v, p1, 'g');
drawArrow(p2v, p2, 'm');

% Simulation time:
title(['Time: ', num2str(t), ' (s)']);

% Final formatting on the axes
axis equal;axis off;
set(gca,'XLim',xLim);
set(gca,'YLim',yLim);
drawnow;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function hQuadRotor = drawQuadrotor(x, y, q, w, color)
%
% Draws a cartoon of a quadrotor helicopter using the patch command
%

% Start by drawing from -1 to 1 on the x-axis
P = [...
    -1,  -1, -0.4, -0.3, 0.3, 0.4, 1, 1;
     0, 0.1,  0.1, 0.25, 0.25, 0.1, 0.1, 0];

% Scale,rotate, shift and plot:
P = 0.5 * w * P;   %Scale
P = [cos(q), -sin(q); sin(q), cos(q)]*P;  %Rotate
P = P + [x*ones(1,8); y*ones(1,8)];  %Shift

% Plot!
hQuadRotor = patch(P(1,:), P(2,:),color);  axis equal;
hQuadRotor.EdgeColor = color;

end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function hQuadRotor = drawPendulum(x, y, q, l, color)
%
% Draws a cartoon of a pendulum
%

% Start by drawing from -1 to 1 on the x-axis
scale = 0.02;
P = [...
     -1, -1, 1, 1;
     0, 1, 1, 0];

% Scale,rotate, shift and plot:
q = q + pi;
P(1,:) = P(1,:) * scale;
P = l * P;   %Scale
P = [cos(q), -sin(q); 
     sin(q), cos(q)]*P;  %Rotate*P;  %Rotate
P = P + [x*ones(1,4); y*ones(1,4)];  %Shift

% Plot!
hQuadRotor = patch(P(1,:), P(2,:),color);  axis equal;
hQuadRotor.EdgeColor = color;

end
function planarQuadrotorDraw(t, z, u, param, xLim, yLim)
% planarQuadrotorDraw(t, z, u, param, xLim, yLim)
%
% Creates a visualization of the quadrotor at a single point in time.
%
% INPUTS:
%   t = scalar = simulation time
%   z = [6, 1] = [x; y; q; dx; dy; dq] = state
%        x = horizontal position
%        y = vertical position
%        q = absolute angle (zero for hover)
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
q = z(3, :);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);

% Unpack the parameters:
m = param.m;
w = param.w;
g = param.g;

% Kinematics (get positions for plotting)
[p0, p1, p2, p1v, p2v] = autoGen_planarQuadrotorKinematics(x, y, q, u1, u2, m, w, g);

% Draw the ground:
plot(xLim(:), [0; 0], 'Color', [0.4, 0.2, 0.1], 'LineWidth', 3);

% Draw the quadrotor itself:
drawQuadrotor(x, y, q, w, 'k');

% Draw the center of mass:
plot(p0(1), p0(2), 'y.', 'MarkerSize', 25);

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

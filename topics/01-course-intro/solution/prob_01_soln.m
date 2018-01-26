function prob_01_soln()

N_SAMPLES = 5000;

%%%% PART ONE:

N_CONTROL_POINTS = 3;
ALPHA = 1/(N_CONTROL_POINTS - 1);

figure(1010); clf; 
subplot(1,2,1); hold on;
DrawSerpinskyFractal(N_CONTROL_POINTS, N_SAMPLES, ALPHA);
title({'Part One: N = 3'; ''});  % add a line of space below title

%%%% PART TWO:

N_CONTROL_POINTS = 4;  
ALPHA = 1/(N_CONTROL_POINTS - 1);

subplot(1,2,2); hold on;
DrawSerpinskyFractal(N_CONTROL_POINTS, N_SAMPLES, ALPHA);
title({'Part Two: N = 4'; ''});  % add a line of space below title

% NOTE:
% 
%    It turns out that there is a whole family of related fractals here.
%    Just set ALPHA = N, where N > 2
%
%

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function DrawSerpinskyFractal(N_CONTROL_POINTS, N_SAMPLES, ALPHA)
% DrawSerpinskyFractal(N_CONTROL_POINTS, N_SAMPLES, ALPHA)
%
% Draws a serpinsky fractal using a random sequence
%
% INPUTS:
%   N_CONTROL_POINTS: how many control points to use along the unit circle.
%         3 --> serpinsky triangle
%         4 --> I forget what it is called, but you'll regonize it
%   N_SAMPLES: How many points in the sequence to compute and plot
%   ALPHA: where to move between the control point and the previous point
%
% OUTPUTS:
%   A neat plot.

% Select three points that are uniformly spaced around a circle:
angles = linspace(0, 2*pi, N_CONTROL_POINTS+1); angles(end) = [];
C = pointsOnACircle(angles);

% Plot the control points
plot(C(1,:), C(2,:), 'ro', 'MarkerSize', 9, 'LineWidth', 3);

% Plot the circle that the points lie on:
% Yes... the Matlab command to plot a circle is called rectangle.
rectangle('Position',[-1, -1, 2, 2], ...
          'Curvature',[1,1],...
          'LineWidth',1,...
          'EdgeColor',[0,0,0]);

% Make sure that the circle looks like a circle
axis equal;   axis off;  axis tight;

% Set the starting point at first control point. 
P0 = C(:, 1);
plot(P0(1), P0(2), 'gx', 'MarkerSize', 9, 'LineWidth', 3);

% Generate the random sequence:
P = zeros(2, N_SAMPLES);  % Store the points here
P(:,1) = P0;
I = randi(N_CONTROL_POINTS, 1, N_SAMPLES);  % Which control point to move towards?
for i=2:N_SAMPLES
    P(:,i) = ALPHA * P(:, i-1) + (1.0 - ALPHA) * C(:,I(i));
end
plot(P(1,:), P(2,:), 'b.')


end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function C = pointsOnACircle(angles)
% C = pointsOnACircle(angles)
%
% Given a list of angles, compute the points along the unit circle that
% correspond to those angles.
%
% INPUTS:
%   angles = [1, n] = row vector of angles, from positive x axis
%
% OUTPUTS:
%  C = [2, n] = points along the circle = [x; y];
%
%

C = [cos(angles); sin(angles)];

end
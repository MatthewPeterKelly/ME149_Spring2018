function prob_02_soln

% Create a figure to add all of the plots to
figure(1003); clf;

% Add plots for both parts of the assignment:
partOne();
partTwo();

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function partOne()

t = linspace(0, 5, 100);
[x, dx, ddx, T, Dx, DDx] = testFunOne(t);

hPos = subplot(3, 2, 1); hold on;
plot(t, x, 'r-', 'LineWidth', 2) ;  % function 
ylabel('t')
ylabel('x')
title('x(t)')
axis tight;

hVel = subplot(3, 2, 3); hold on;
plot(t, dx, 'r-', 'LineWidth', 2);  % analytic derivative
plot(T, Dx, 'k.', 'MarkerSize', 12);  % finite difference derivative
ylabel('t')
ylabel('dx')
title('dx(t)')
legend('analytic','numerical','Location','SouthWest')
axis tight;

hAcc = subplot(3, 2, 5); hold on;
plot(t, ddx, 'r-', 'LineWidth', 2);  % analytic derivative
plot(T, DDx, 'k.', 'MarkerSize', 12);  % finite difference derivative
ylabel('t')
ylabel('dx')
title('ddx(t)')
legend('analytic','numerical','Location','SouthWest')
axis tight;

linkaxes([hPos, hVel, hAcc], 'x'); % link the x-axes of the sub-plots together

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function partTwo()

%%%% The second test function is a polynomial - derivatives are easy:
P = [1, -6, 2, 5];  % coefficients of the polynomial
dP = polyder(P);  % coefficients of the derivative
ddP = polyder(dP);  % coefficients of the second derivative

% Compute the min and max values of y(t) by checking roots of dy(t)
tCrit = roots(dP);
yCrit = polyval(P, tCrit);
[yMax, iMax] = max(yCrit);
tMax = tCrit(iMax);
[yMin, iMin] = min(yCrit);
tMin = tCrit(iMin);

% Evaluate the function
t = linspace(0, 5, 100);
y = polyval(P, t);
dy = polyval(dP, t);
ddy = polyval(ddP, t);

hSubTwo(1) = subplot(3, 2, 2); hold on;
plot(t, y, '-k', 'LineWidth', 2)
plot(tMin, yMin, 'rx', 'LineWidth', 3, 'MarkerSize', 10)
plot(tMax, yMax, 'bo', 'LineWidth', 3, 'MarkerSize', 10)
ylabel('t')
ylabel('y')
title('y(t)')
legend('y(t)', 'yMin', 'yMax');
axis tight;

hSubTwo(2) = subplot(3, 2, 4); hold on;
plot(t, dy, '-k', 'LineWidth', 2)
ylabel('t')
ylabel('dy')
title('dy(t)')
axis tight;

hSubTwo(3) = subplot(3, 2, 6); hold on;
plot(t, ddy, '-k', 'LineWidth', 2)
ylabel('t')
ylabel('dy')
title('ddy(t)')
axis tight;

linkaxes(hSubTwo, 'x'); % link the x-axes of the sub-plots together

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [x, dx, ddx, T, Dx, DDx] = testFunOne(t)
% [x, dx, ddx, T, Dx, DDx] = testFunOne(t)
%
% Compute the function:
%  x(t) = (1 + (t - 2).^2) * sin(3 * t);
%
% INPUTS:
%   t = [1, n] = time vector
%
% OUTPUTS:
%   x = [1, n] = position vector
%   dx = [1, n] = velocity vector
%   ddx = [1, n] = acceleration vector
%   T = [1, n-1] = time grid for finite difference values
%   dx = [1, n] = velocity vector (finite difference)
%   ddx = [1, n] = acceleration vector (finite difference)
%
% NOTES:
%  Symbolic solution is shown below:
%
%     % Code:
%     syms t
%     x = (1 + (t - 2).^2) * sin(3 * t)
%     dx = diff(x, t)
%     ddx = diff(dx, t)
%     
%     % Output:  (formatted to be readable here)
%     x = sin(3*t)*((t - 2)^2 + 1)
%     dx = 3*cos(3*t)*((t - 2)^2 + 1) + sin(3*t)*(2*t - 4)
%     ddx = 2*sin(3*t) - 9*sin(3*t)*((t - 2)^2 + 1) + 6*cos(3*t)*(2*t - 4)
%

% parameters
a = 3; 
b = 2;
c = 1;

% First term and derivatives
f1 = sin(a*t);
df1 = a*cos(a*t);
ddf1 = -a*a*sin(a*t);

% Second term and derivatives
f2 = c + (t-b).^2;
df2 = 2*(t-b);
ddf2 = 2*ones(size(t));

% Combine terms (and then use product rule)
x = f1.*f2;
dx = df1.*f2 + f1.*df2;  % product rule
% ddx = (ddf1*f2 + df1*df2) + (df1*df2 + f1*ddf2);
ddx = ddf1.*f2 + 2*df1.*df2 + f1.*ddf2; %product rule again

% Check the derivatives numerically:
T = 0.5*(t(2:end) + t(1:(end-1))); % time at the midpoint of each segment
h = diff(t);  % Duration of each segment:
xDel = diff(x);  % Change in position over each segment
Dx = xDel ./ h;  % finite difference approximation of dx
vDel = diff(dx); % change in velocity over each segment
DDx = vDel ./ h;  % finite difference approxiimation of ddx

end

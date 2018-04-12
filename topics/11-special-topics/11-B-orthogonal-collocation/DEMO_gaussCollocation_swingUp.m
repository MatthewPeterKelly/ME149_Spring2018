% DEMO  --  Gauss Pseudospectral methods
%
% References...  
%
%    https://epubs.siam.org/doi/pdf/10.1137/16M1062569   (appendix D)
%
%    https://people.maths.ox.ac.uk/trefethen/barycentric.pdf
%
%    https://hal.archives-ouvertes.fr/hal-01615132/file/GPHR.pdf
%


clc; clear;
run('../../../codeLibrary/addLibraryToPath.m');
if ~checkForChebFun()
   error('This example required the ChebFun toolbox!'); 
end

% Polynomial order:
n = 20;

% Solve the pendulum swing-up bvp
dynFun = @(x)( [x(2,:); -sin(x(1,:))] );

% Boundary constraints
tBnd = [0, 2];
startAngle = 0;
finalAngle = 3.14;

% Boundary constraint function:
bndCst = @(x0, xF)( [x0(1) - startAngle; xF(1) - finalAngle] );

% Guess function (linear interpolate beteen boundaries)
guess = @(t)( [interp1(tBnd', [startAngle; finalAngle], t); 
               ones(size(t))*(finalAngle-startAngle)/diff(tBnd)] );

% Solve BVP
soln = gaussCollocationBvp(tBnd, dynFun, bndCst, guess, n);

% Plot the solution:
figure(12); clf;
t = soln.interp.t;
x = soln.interp.x;
q = x(1,:);
w = x(2,:);

tColl = soln.colloc.t;
xColl = soln.colloc.x;
dxColl = soln.colloc.dx;
qColl = xColl(1,:);
wColl = xColl(2,:);

subplot(2,1,1); hold on;
plot(t, q, 'LineWidth', 2)
plot(tBnd, [startAngle, finalAngle],...
    'rs', 'MarkerSize', 12, 'LineWidth', 3)
plot(tColl, qColl, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
xlabel('time')
ylabel('angle (rad)')
title('Pendulum Swing-up Bvp')

subplot(2,1,2); hold on;
plot(t, w, 'LineWidth', 2)
plot(tColl, wColl, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
xlabel('time')
ylabel('rate (rad/s)')

% Plot the error in the approximation of the dynamics:
figure(13); clf;
tErr = soln.collErr.t;
xErr = soln.collErr.x;
qErr = xErr(1, :);
wErr = xErr(2, :);

subplot(2,1,1); hold on;
plot(t, qErr, 'LineWidth', 2)
ylabel('angle err (rad)')
xlabel('time')
title('Pendulum Swing-up Bvp Collocation Error')

subplot(2,1,2); hold on;
plot(t, wErr, 'LineWidth', 2)
xlabel('time')
ylabel('rate err (rad/s)')


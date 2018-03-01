function DEMO_simplePendulum_bvp4c()
%
% This demo shows how to use bvp4c to solve a simple boundary value
% problem.
%
% dq = w
% dw = -sin(q)
%
% q(0) = 0
% q(T) = pi
%
run('../../../codeLibrary/addLibraryToPath.m');

% Problem setup:
T = 1.0;  % duration of the trajectory
qBnd = [0, pi];  % angles for boundary constraint

% Passive dynamics function:
param = struct('freq',1,'damp',1);
ctrlFun = @(t)( zeros(1, length(t)) );
dynFun = @(t, x)( simplePendulumDynamics( x, ctrlFun(t), param) );

% Initial guess for BVP4c
nGrid = 20;
init.x = linspace(0, T, nGrid);   % time grid points
init.y = [linspace(qBnd(1), qBnd(2), nGrid);  % angle guess
          zeros(1, nGrid)];  % rate guess
      
% Boundary constraint function:
bndCst = @(x0, xT)( boundaryConstraint(x0, xT, qBnd(1), qBnd(2)) );

% Solve using BVP4c
soln = bvp4c(dynFun, bndCst, init);

% Interpolate the solution
t = linspace(0, T, 201);
x = deval(soln, t);
q = x(1,:);
w = x(2,:);

% Plot the result:
figure(70010); clf;

subplot(2,1,1); hold on;
plot(t, q, 'LineWidth', 2);
xlabel('time (s)');
ylabel('angle (rad)');
title('Simple Pendulum Boundary Value Problem')

subplot(2,1,2); hold on;
plot(t, w, 'LineWidth', 2);
xlabel('time (s)');
ylabel('rate (rad/s)');

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function ceq = boundaryConstraint(x0, xT, q0, qT)
%
% Applies a boundary value constraint on the initial and final angle
%
% INPUTS:
%   x0 = [q0; w0] = initial state
%   xT = [qT; wT] = final state
%   q0 = initial angle (desired)
%   qT = final angle (desired) 
%
% OUTPUTS:
%   ceq = [2,1] = column vector of boundary constraints
%

ceq = [...         % boundary constraints
    x0(1) - q0;    % initial angle constraint
    xT(1) - qT];   % terminal angle constraint

end

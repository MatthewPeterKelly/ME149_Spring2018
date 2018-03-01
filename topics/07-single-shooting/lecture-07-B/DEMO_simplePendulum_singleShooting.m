function DEMO_simplePendulum_singleShooting()
%
% This demo shows how to use a variety of methods to solve a simple
% boundary value problem:
% 
% simple pendulum dynamics
% dq = w
% dw = -sin(q)
%
% q(0) = 0
% q(T) = pi
%
run('../../../codeLibrary/addLibraryToPath.m');

% Problem setup:
T = 1.0;  % duration of the trajectory
q0 = 0;  % initial angle
qT = pi;  % final angle

% Passive dynamics function:
param = struct('freq',1,'damp',1);
ctrlFun = @(t)( zeros(1, length(t)) );
dynFun = @(t, x)( simplePendulumDynamics( x, ctrlFun(t), param) );

% Options for the solver:
options = optimoptions('fsolve');
options.Display = 'iter';

% Options for single shooting:
method = 'rk4';
nGrid = 50;
tGrid = linspace(0, T, nGrid);
      
% Initial guess for the decision variable (w0 = initial rate)
w0 = 1;  % this problem is simple enough that any reasonable value will do

% Boundary constraint function:
cstFun = @(w0)( constraintFunction(w0, q0, qT, dynFun, tGrid, method) );
      
% Solve using fsolve
[soln.w0, soln.err, soln.exitFlag] = fsolve(cstFun, w0, options);

% Call constraint function again to get the entire simulation
[~, xSoln] = cstFun(soln.w0);

% Interpolate the solution
q = xSoln(1,:);
w = xSoln(2,:);

% Plot the result:
figure(70020); clf;

subplot(2,1,1); hold on;
plot(tGrid, q, 'LineWidth', 2);
xlabel('time (s)');
ylabel('angle (rad)');
title('Simple Pendulum Boundary Value Problem')

subplot(2,1,2); hold on;
plot(tGrid, w, 'LineWidth', 2);
xlabel('time (s)');
ylabel('rate (rad/s)');

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [ceq, xGrid] = constraintFunction(w0, q0, qT, dynFun, tGrid, method)
%
% Nonlinear constraint function: applies boundary constraint
%
% INPUTS:
%   w0 = initial angular rate
%   q0 = initial angle
%   qT = final angle (desired) 
%   dynFun = dynamics function handle to pass to the simulator
%   tGrid = [1, nGrid] = time grid for the simulation
%   method = method string for the simulation
%
% OUTPUTS:
%   ceq = scalar = defect in the final angle
%

x0 = [q0; w0];  % initial state
xGrid = runSimulation(dynFun, tGrid, x0, method);  % solve initial value problem
xT = xGrid(:, end);  % final state

% Compute the "defect"
ceq = xT(1) - qT;  % error in final angle

end

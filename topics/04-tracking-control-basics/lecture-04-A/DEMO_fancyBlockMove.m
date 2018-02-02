% DEMO:  fancy block move
%
% This demo shows how to use a simple reference trajectory to move a 
% point mass between two points.
%
% Students: Experiment with all of the parameters!
%
% Follow-up question: how would you compute a feed-forward term to improve
% the performance further?

clc; clear;

% Add the code library to the current path
run('../../../codeLibrary/addLibraryToPath.m');

% Parameters:
x0 = 1.0;  % initial position
v0 = 0.0;  % initial velocity
xF = 0.0;  % final (target) position
vF = 0.0;  % final (target) velocity
tF = 2.0;  % time at which the reference reaches the target
duration = 1.5*tF;  % total simulation time
uMax = 100;  % maximum actuator force  (nonlinearity)

% Controller design:   ( pole placement! )
xi = 1.0;  % damping ratio
wn = 8.0;  % undamped natural frequency

% Compute controller gains: 
%     >> help secondOrderSystemGains   % from ME149/codeLibrary/
%  --> this could also be achieved with the `place()` function in Matlab
Kp = - wn * wn;
Kd = -2 * wn * xi;

% Compute the reference trajectory:
tKnot = [0, tF, duration];
xKnot = [x0, xF, xF];
vKnot = [v0, vF, vF];
xRefPp = pwch(tKnot, xKnot, vKnot);  % create a cubic hermite spline
vRefPp = ppDer(xRefPp);  % take the derivative of that spline

% Controller:   u = Kp * (x - xRef) + Kd * (v - vRef)
ctrlFun = @(t, z)( linearTrackingController(t, z, Kp, Kd, xRefPp, vRefPp, uMax) );

% System dynamics:
dynFun = @(t, z)( pointMassDynamics(z, ctrlFun(t, z)) );

% Set up for the simulation:
tSpan = [0, duration];
z0 = [x0; v0];

% Run the simulation. Use single-output version of ode45().
simSoln = ode45(dynFun, tSpan, z0);

% Interpolate the solution:
tSoln = linspace(tSpan(1), tSpan(2), 250);
zSoln = deval(simSoln, tSoln);
xSoln = zSoln(1, :);  % position
vSoln = zSoln(2, :);  % velocity
[uSoln, xRef, vRef] = ctrlFun(tSoln, zSoln);  % force

% Plot!
figure(40000); clf;
systemName = 'Point-Mass';

h1 = subplot(3,1,1); hold on;
plot(tSoln, xRef,'k--','LineWidth',2);
plot(tSoln, xSoln, 'r-','LineWidth',2);
xlabel('time (s)');
ylabel('position (m)');
title([systemName, 'Position']);
legend('xRef','x','Location','best');

h2 = subplot(3,1,2); hold on;
plot(tSoln, vRef,'k--','LineWidth',2);
plot(tSoln, vSoln, 'r-','LineWidth',2);
xlabel('time (s)');
ylabel('velocity (m/s)');
title([systemName, 'Velocity']);
legend('vRef','v','Location','best');

h3 = subplot(3,1,3); hold on;
plot(tSpan, [0,0],'k--','LineWidth',2);
plot(tSoln, uSoln, 'r-','LineWidth',2);
xlabel('time (s)');
ylabel('force (N)');
legend('zero','u','Location','best');
title([systemName, 'Force']);

linkaxes([h1,h2],'x');

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [u, xRef, vRef] = linearTrackingController(t, z, Kp, Kd, xRefPp, vRefPp, uMax)

% Unpack the state
x = z(1,:);
v = z(2,:);

% Evaluate the reference trajectory:
xRef = ppval(xRefPp, t);
vRef = ppval(vRefPp, t);

% Ideal controller:
u = Kp * (x - xRef) + Kd * (v - vRef);

% Saturate the controller:
u (u > uMax) = uMax;
u (u < -uMax) = -uMax;

end


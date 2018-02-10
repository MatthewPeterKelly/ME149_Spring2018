function DEMO_simpleBlockMove()
%
% DEMO:  simple block move
%
% This demo shows how to use a simple PD controller to move a point mass
% from point A to point B, and then looks at how motor saturation affects
% performance.
%
% For students:
%   - experiment with changing all of the parameters: see what happens!
%
% Examples:
%
%   - set the damping (xi) to each of the following values:
%       xi = 0  --> no damping = oscillate forever
%       xi = 0.2  --> under-damped: slowly decaying oscillations
%       xi = 0.8  --> under-damped: rapidly decaying oscillations
%       xi = 1.0  --> critically damped: fastest response w/o overshoot
%       xi = 1.2  --> overdamped: fast response, no overshoot
%       xi = 3.5  --> overdamped: slow response, no overshoot
%
%   - adjust the natural frequency of the controller (wn), keeping other
%   parameters fixed. Notice that larger wn will cause larger actuation an
%   a faster response.
%
%   - if the maximum actuation (uMax) is large enough, then this system
%   will behave exactly like a linear system. As uMax is reduced you will
%   eventually notice that it clips the actuation for the beginning of the
%   simulation. When this occurs we get two issues:
%
%       1) actuator saturation is handled with a simple clamping function,
%       which introduces a discontinuity in the controller. This means that
%       the dynamics that are passed to ode45 are now discontinuous. As a
%       result, the solution that ode45 gives wil not actully satisfy the
%       accuracy that it promises, and we may see "ringing" in the
%       solution: a numerical artifact that happens when we use a
%       high-order method to simulate a system with a discontinuity. That
%       being said, for practical purposes the solution obtained by ode45
%       is good enough to illustrate out point. The correct way to handle
%       this discontinuity is with the events feature in ode45, but this
%       would introduce a significant amount of extra code and is a topic
%       for another time.
%
%       2) the pole-placement method that we used for setting Kp and Kd
%       implicitly assumes that the system is perfectly linear. If the
%       actuator saturates then we no longer have any guarentees about what
%       the behavior will be. For example, it is possible to get an
%       overdamped controller to overshoot, even though this will never
%       happen for a truely linear system.
%
%   - What happens if you set a non-zero reference velocity? The system
%   will never reach its target! There is no steady-state solution where
%   you can satisfy a constant position and a non-zero constant velocity.
%   As a result, you will get a steady-state error in both position and
%   velocity.
%

% Add the code library to the current path
run('../../../codeLibrary/addLibraryToPath.m');

% Parameters:
x0 = 1.0;  % initial position
v0 = 0.0;  % initial velocity
duration = 2.0;
xRef = 0.0;  % reference position
vRef = 0.0;  % reference velocity
uMax = 100.0;  % maximum actuator force  (nonlinearity)

% Controller design:   ( pole placement! )
xi = 1.0;  % damping ratio
wn = 5.0;  % undamped natural frequency

% Compute controller gains:
%     >> help secondOrderSystemGains   % from ME149/codeLibrary/
%  --> this could also be achieved with the `place()` function in Matlab
Kp = - wn * wn;
Kd = -2 * wn * xi;

% Controller:   u = Kp * (x - xRef) + Kd * (v - vRef)
ctrlFun = @(z)( simpleLinearController(z, Kp, Kd, xRef, vRef, uMax) );

% System dynamics:
dynFun = @(t, z)( pointMassDynamics(z, ctrlFun(z)) );

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
uSoln = ctrlFun(zSoln);  % force

% Plot!
figure(40000); clf;
systemName = 'Point-Mass';

h1 = subplot(3,1,1); hold on;
plot(tSpan, xRef*[1,1],'k--','LineWidth',2);
plot(tSoln, xSoln, 'r-','LineWidth',2);
xlabel('time (s)');
ylabel('position (m)');
title([systemName, 'Position']);
legend('xRef','x');

h2 = subplot(3,1,2); hold on;
%
plot(tSpan, vRef*[1,1],'k--','LineWidth',2);
plot(tSoln, vSoln, 'r-','LineWidth',2);
xlabel('time (s)');
ylabel('velocity (m/s)');
title([systemName, 'Velocity']);
legend('vRef','v');

h3 = subplot(3,1,3); hold on;
plot(tSpan, [0,0],'k--','LineWidth',2);
plot(tSoln, uSoln, 'r-','LineWidth',2);
xlabel('time (s)');
ylabel('force (N)');
legend('zero','u');
title([systemName, 'Force']);

linkaxes([h1,h2],'x');

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function u = simpleLinearController(z, Kp, Kd, xRef, vRef, uMax)

% Unpack the state
x = z(1,:);
v = z(2,:);

% Ideal controller:
u = Kp * (x - xRef) + Kd * (v - vRef);

% Saturate the controller:
u (u > uMax) = uMax;
u (u < -uMax) = -uMax;

end

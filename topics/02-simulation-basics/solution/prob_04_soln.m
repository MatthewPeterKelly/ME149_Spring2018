function prob_04_soln()
%
% This function computes a simulation of a the Lorenz system, creating
% a visualization of the Lorenz attractor fractal.
%

%~~~~~~~~~~~~~~~~~  Set up for the simulation  ~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Duration of 10 seconds, with a maximum time-step of 0.005 seconds.
% x(0) is randomly selected from [5, 35] 
% y(0) is randomly selected from [-30, 5] 
% z(0) is randomly selected from [-5, 35] 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Set up the dynamics function and timing details:
dynFun = @(t, z)( LorenzDynamics(t, z) );
tSpan = [0, 10];
hMax = 0.005;

% Initial state:
xInit = 5 + 30*rand();
yInit = 35*rand() - 30;
zInit = 40*rand() - 5;
stateInit = [xInit; yInit; zInit];

%~~~~~~~~~~~~~~~~~~~~~~~~  Run the simulation  ~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[time, state] = EulerMethodSimulation(dynFun, tSpan, stateInit, hMax);


%~~~~~~~~~~~~~~~~  Plot the trajectory in state space ~~~~~~~~~~~~~~~~~~~~%
% Use the plot3() command to plot (x vs. y vs. z) on a single plot
% Set the axis commands so that the axis are equal in scale and not visible
% Add a title to the subplot
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

figure(1040); clf;
subplot(2,3,[3,6])
plot3(state(1,:), state(2,:), state(3,:));
axis equal; axis tight; axis off;
title('Lorenz Attractor');

%~~~~~~~~~~~~~~~  Plot the state as a function of time ~~~~~~~~~~~~~~~~~~~%
% Create a single figure with two sub-plots
% The top sub-plot shows all three states as a function of time
% The bottom sub-plot shows the derivative of each state
% Use the legend command to label each curve
% Label both axis and add a title
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Plot the state as a function of time:
h1 = subplot(2, 3, [1, 2]); hold on;
for i=1:3
   plot(time, state(i,:), 'LineWidth', 2); 
end
title('Time-Evolution, Lorenz System');
xlabel('time');
ylabel('state');
legend('x','y','z');

% Plot the derivative of each state as a function of time:
dState = LorenzDynamics(time, state);
h2 = subplot(2, 3, [4, 5]); hold on;
for i=1:3
   plot(time, dState(i,:), 'LineWidth', 2); 
end
xlabel('time');
ylabel('derivative');
legend('dx','dy','dz');

linkaxes([h1, h2], 'x');
end
function prob_04_studentName()
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

%%%% TODO:  set up for the simulation

%~~~~~~~~~~~~~~~~~~~~~~~~  Run the simulation  ~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[time, state] = EulerMethodSimulation(dynFun, tSpan, stateInit, hMax);


%~~~~~~~~~~~~~~~~  Plot the trajectory in state space ~~~~~~~~~~~~~~~~~~~~%
% Use the plot3() command to plot (x(t) vs. y(t) vs. z(t)) on a single plot
% Set the axis commands so that the axis are equal in scale and not visible
% Add a title to the subplot
% The subplot() command places this plot on the right side of the figure.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Set up the figure
figure(1040); clf;
subplot(2, 3, [3,6]);

%%%% TODO:  plot the Lorenz attractor  (trajectory in state space)

%~~~~~~~~~~~~~~~  Plot the state as a function of time ~~~~~~~~~~~~~~~~~~~%
% The top sub-plot shows all three states as a function of time
% The bottom sub-plot shows the derivative of each state
% Use the legend command to label each curve
% Label both axis and add a title
% The subplot() commands split the left side of the figure into top and bottom.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Plot the state as a function of time:
h1 = subplot(2, 3, [1, 2]); hold on;

%%%% TODO: plot the state vs time

% Plot the derivative of each state as a function of time:
h2 = subplot(2, 3, [4, 5]); hold on;

%%%% TODO: plot the derivative of each state vs time

end

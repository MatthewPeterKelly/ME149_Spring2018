function prob_03_studentName()
%
% This function computes a simulation of a simple pendulum.
%

%~~~~~~~~~~~~~~~~~  Set up for the simulation  ~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Duration of 20 seconds, with a maximum time-step of 0.01 seconds.
% Initial angle is randomly selected from [-3, 3] radians
% Initial angular rate is randomly selected from [-1, 1] radians / second
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%%%% TODO: Set up for the simulation

%~~~~~~~~~~~~~~~~~~~~~~~~  Run the simulation  ~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[t, z] = EulerMethodSimulation(dynFun, tSpan, zInit, hMax);

%~~~~~~~~~~~~~~~~~~~  Make plots of the simulation  ~~~~~~~~~~~~~~~~~~~~~~%
% Create a single figure with three sub-plots (three rows, one column)
% The top sub-plot is pendulum angle vs time
% The middle sub-plot is angular rate vs time
% The botom sub-plot is angular acceleration vs time
% All axis should be clearly labeled (including units)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Set up the figure:
figure(1030); clf;

%%%% TODO: Make plots

end

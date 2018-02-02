function [tGrid, zGrid] = EulerMethodSimulation(dynFun, tSpan, zInit, hMax)
% [tGrid, zGrid] = EulerMethodSimulation(dynFun, tSpan, zInit, hMax)
%
% Simulate a dynamical system over a set time span using Euler's method,
% given the initial state and the maximum time step. Use a uniform time grid.
%
% INPUTS:
%    dynFun = a function handle:  dz = dynFun(t, z)
%        IN:  t = [1, nTime] = row vector of time
%        IN:  z = [nState, nTime] = matrix of states corresponding to each time
%        OUT: dz = [nState, nTime] = time-derivative of the state at each point
%    tSpan = [startTime, finalTime] = [1, 2] = time span
%    zInit = [nState, 1] = state of the system at start time
%    hMax = scalar = maximum time step to use for the uniform time grid.
%
% OUTPUTS:
%    tGrid = [1, nTime] = time grid on which the integration was performed
%    zGrid = [nState, nTime] = state at each point in tGrid
%
%

% Input validation:
[nDim, nOne] = size(zInit);
if nOne ~= 1
    error('zInit must be a column vector!');
end
if numel(tSpan) ~= 2
    error('tSpan must have precisely two elements!');
end
if hMax <= 0
    error('hMax must be positive!');
end

% Set up the time grid:
nGrid = max(2, ceil(tSpan(2) - tSpan(1)) / hMax);
tGrid = linspace(tSpan(1), tSpan(2), nGrid);

% Set up the state grid:
zGrid = zeros(nDim, nGrid);
zGrid(:, 1) = zInit;

% Step through time:
h = tGrid(2) - tGrid(1);  % constant time step, due to uniform grid
for i = 2:nGrid
   iPrev = i - 1;
   tPrev = tGrid(iPrev);
   zPrev = zGrid(:, iPrev);
   zNext = zPrev + h*dynFun(tPrev, zPrev);
   zGrid(:,i) = zNext;
end

end

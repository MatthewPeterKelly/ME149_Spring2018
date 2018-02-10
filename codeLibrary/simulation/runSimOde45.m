function [zGrid, nEval, soln] = runSimOde45(dynFun, tGrid, zInit, tol)
%  [zGrid, nEval, soln] = runSimOde45(dynFun, tGrid, zInit, tol)
%
% Simulate a dynamical system using ode45 and a prescribed tolerance.
% Interpolates the result on tGrid.
%
% INPUTS:
%    dynFun = a function handle:  dz = dynFun(t, z)
%        IN:  t = [1, nTime] = row vector of time
%        IN:  z = [nState, nTime] = matrix of states corresponding to each time
%        OUT: dz = [nState, nTime] = time-derivative of the state at each point
%        OUT: nEval = scalar = numer of internal calls to dynamics function
%    tGrid = [1, nGrid] = time grid to interpolate the result of the simulation
%    zInit = [nDim, 1] = initial state
%    tol = scalar = tolerance to pass to ode45()
%
% OUTPUTS:
%   zGrid = [nDim, nGrid] = state at each point in tGrid. zGrid(:,1) = zInit
%   nEval = scalar = total number of calls to the dynamics function
%   soln = ode45 solution strucutre
%

% Input validation:
[~, nOne] = size(zInit);
if nOne ~= 1
    error('zInit must be a column vector!');
end
[nOne, ~] = size(tGrid);
if nOne ~= 1
    error('tGrid must be a row vector!');
end
if tol < eps
  error('tol must be positive!');
end

% Specify tolerance for the simulation:
opt = odeset(...
    'RelTol', tol, ...
    'AbsTol', tol);

% Run the simulation. Use single argument to obtain full solver data.
tSpan = tGrid([1, end]);
soln = ode45(dynFun, tSpan, zInit, opt);   %  >> help ode45

% method-consistent interpolation.
zGrid = deval(soln, tGrid);  %    >> help deval

% Compute the number of evaluations:
nEval = soln.stats.nfevals;
end

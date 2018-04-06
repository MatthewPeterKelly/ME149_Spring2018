function soln = dirColBvpTrap(problem)
% soln = dirColBvpTrap(problem)
%
% This function computes the solution to a simple trajectory optimization
% problem using the trapezoid method for direct collocation.
%
% minimize: J = integral(pathObj(t, x, u))
%
% subject to:
%
%       dynamics:  dx = dynamics(t, x, u)
%
%       boundary constraints:  [c, ceq] = bndCst(x0, xF)
%
% given: time grid and initialization for state and control
%
%
% INPUT: "problem" -- struct with fields:
%
%     func -- struct for user-defined functions, passed as function handles
%
%         Input Notes:  square braces show size:  [a,b] = size()
%                 t = [1, nTime] = time vector (grid points)
%                 x = [nState, nTime] = state vector at each grid point
%                 u = [nControl, nTime] = control vector at each grid point
%                 x0 = [nState, 1] = initial state
%                 xF = [nState, 1] = final state
%
%         dx = dynamics(t, x, u)
%                 dx = [nState, nTime] = dx/dt = derivative of state wrt time
%
%         dObj = pathObj(t, x, u)
%                 dObj = [1, nTime] = integrand from the cost function
%
%         [c, ceq] = bndCst(t0, tF, x0, xF)
%                 c = column vector of inequality constraints  ( c <= 0 )
%                 ceq = column vector of equality constraints ( c == 0 )
%
%     guess - struct with an initial guess at the trajectory
%
%         .time = [1, nGrid] = time grid for the transcription (constant)
%         .state = [nState, nGrid] = guess for state at gridpoints
%         .control = [nControl, nGrid] = guess for control at gridpoints
%
%     nlpOpt = solver options object, created by:
%           >> nlpOpt = optimset('fmincon')
%       Useful options (set using "." operator, eg: nlpOpt.Display = 'off')
%           --> Display = {'iter', 'final', 'off'}
%           --> OptimalityTolerance = {1e-3, 1e-6}
%           --> ConstraintTolerance = {1e-3, 1e-5, 1e-10}
%
%
%   OUTPUT: "soln"  --  struct with fields:
%
%     .grid = solution at the grid-points
%         .time = [1, nTime]
%         .state = [nState, nTime] = state at each grid point
%         .control = [nControl, nTime] = control at each grid point
%         .dState = [nState, nTime] = derivative of state at grid points
%
%     .spline = method-consistent spline interpolation of the trajectory
%          .state = matlab PP struct = contains state trajectory
%          .control = matlab PP struct = contains control trajectory
%
%     .info = information about the optimization run
%         .nlpTime = time (seconds) spent in fmincon
%         .exitFlag = fmincon exit flag
%         .objVal = value of the objective function
%         .[all fields in the fmincon "output" struct]
%
%
% NOTES:
%
%   guess.time is used as the time grid for the transcription
%

% Get problem description:
D = getProblemDescription(problem);

% Objective function:  (path objective)
P.objective = @(decVars)( objectiveFunction(decVars, problem, D) );

% Initial guess:
P.x0 = packDecVars(problem.guess.state, problem.guess.control, D);

% No linear constraints:
P.Aineq = [];
P.bineq = [];
P.Aeq = [];
P.beq = [];

% No limits on the state or control
P.lb = [];
P.ub = [];

% Final setup
P.options = problem.nlpOpt;
P.solver = 'fmincon';

% System dynamics: (nonlinear constraint)
P.nonlcon = @(decVars)( nonlinearConstraint(decVars, problem, D) );

% Solve the optimization problem
startTime = tic;
[decVarSoln, objVal, exitFlag, info] = fmincon(P);
info.nlpTime = toc(startTime);
info.objVal = objVal;
info.exitFlag = exitFlag;

% Unpack the grid:
grid.time = D.tGrid;
[grid.state, grid.control] = unpackDecVars(decVarSoln, D);

% Create the interpolating splines:
grid.dState = problem.func.dynamics(grid.time, grid.state, grid.control);
spline.state = ppSpline2a(grid.time, grid.state, grid.dState);
spline.control = ppSpline1(grid.time, grid.control);

% Pack up the output
soln.grid = grid;
soln.spline = spline;
soln.info = info;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function D = getProblemDescription(problem)
% D = getProblemDescription(problem)
%
% This function checks the consistency of the inputs and then constructs
% the problem description, which is used throughout the code..
%
% INPUTS:
%   problem = input structure for dirColBvpTrap
%
% OUTPUTS:
%   D = struct with problem details
%       .nGrid = integer = number of grid points
%       .nState = integer = dimension of the state space
%       .nControl = integer = dimension of the control space
%       .tGrid = [1, nGrid] = time grid
%       .hSeg = [1, nGrid - 1] = duration of each segment
%       .hSegState = [nState, nGrid - 1] = duration of each segment
%       .iLow = [1, nGrid-1] = index for the lower edge of each segment
%       .iUpp = [1, nGrid-1] = index for the upper edge of each segment
%

% Problem dimensions:
D.nGrid = length(problem.guess.time);
[D.nState, nGridState] = size(problem.guess.state);
if nGridState ~= D.nGrid
   error('problem.guess.state is an invalid size!');
end
[D.nControl, nGridControl] = size(problem.guess.control);
if nGridControl ~= D.nGrid
   error('problem.guess.control is an invalid size!');
end
D.nDecVar = (D.nControl + D.nState) * D.nGrid;

% Set up the time grid:
D.tGrid = problem.guess.time;
D.hSeg = diff(D.tGrid);
D.hSegState = ones(D.nState, 1) * D.hSeg;

% Index grids:
D.iLow = 1:(D.nGrid - 1);
D.iUpp = 2:D.nGrid;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function decVars = packDecVars(xGrid, uGrid, D)
% decVars = packDecVars(xGrid, uGrid, D)
%
% Converts from the easy-to-use format of xGrid and uGrid into the
% decision variable column vector that is required by fmincon
%
% INPUTS:
%   xGrid = [nState, nGrid] = state at the grid points
%   uGrid = [nControl, nGrid] = control at the grid points
%   D = problem description struct
%
% OUTPUTS:
%   decVars = [nDecVar, 1] = column vector of decision variables
%              nDecVar = (nState + nControl)*nGrid
%

decVars = reshape([xGrid; uGrid], D.nDecVar, 1);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [xGrid, uGrid] = unpackDecVars(decVars, D)
% [xGrid, uGrid] = unpackDecVars(decVars, D)
%
% Converts from the decision variable column vector that is required by
% fmincon into the easy-to-use state and control grids.
%
% INPUTS:
%   decVars = [nDecVar, 1] = column vector of decision variables
%              nDecVar = (nState + nControl)*nGrid
%   D = problem description struct
%
% OUTPUTS:
%   xGrid = [nState, nGrid] = state at the grid points
%   uGrid = [nControl, nGrid] = control at the grid points
%

% Reshape into a square matrix
zTmp = reshape(decVars, D.nState + D.nControl, D.nGrid);

% Figure out the indicies for state and control:
idxState = 1:D.nState;
idxControl = idxState(end) + (1:D.nControl);

% pull out the state and control components
xGrid = zTmp(idxState, :);
uGrid = zTmp(idxControl, :);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function J = objectiveFunction(decVars, problem, D)
% J = objectiveFunction(decVars, problem, D)
%
% This function computes the integral objective function.
%
% INPUTS:
%   decVars = vector of decision variables
%   problem = problem struct: see dirColBvpTrap()
%   D = problem description struct: see getProblemDescription()
%
% OUTPUTS:
%   J = scalar = value of the path integral objective
%
% NOTES:
%   The path integral is computed using the trapezoid rule for quadrature.
%

% Extract the state and control grids
[xGrid, uGrid] = unpackDecVars(decVars, D);

% Evaluate the path objective integrand
dJ = problem.func.pathObj(D.tGrid, xGrid, uGrid);

% Trapezoid rule to compute integral
J = 0.5 * sum(D.hSeg .* (dJ(D.iLow) + dJ(D.iUpp)));

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [c, ceq] = nonlinearConstraint(decVars, problem, D)
% [c, ceq] = nonlinearConstraint(decVars, problem, D)
%
% This function computes the nonlinear constraints that are passed to 
% FMINCON. This function should handle both the boundary constraints and
% the system dynamics.
%
% INPUTS:
%
% INPUTS:
%   decVars = vector of decision variables
%   problem = problem struct: see dirColBvpTrap()
%   D = problem description struct: see getProblemDescription()
%
% OUTPUTS:
%   c = column vector of inequality constraints
%   ceq = column vector of equality constraints
%


% Extract the state and control grids
[xGrid, uGrid] = unpackDecVars(decVars, D);

% Compute the state and control at the lower and upper edge of each segment
xLow = xGrid(:, D.iLow);
xUpp = xGrid(:, D.iUpp);

% Compute the dynamics at the lower and upper edge of each segment
dxGrid = problem.func.dynamics(D.tGrid, xGrid, uGrid);
dxLow = dxGrid(:, D.iLow);
dxUpp = dxGrid(:, D.iUpp);

% Defect constraint:   (apply trapezoid rule)
defects = (xUpp - xLow) - 0.5 * D.hSegState .* (dxLow + dxUpp);

% Boundary constraint:
t0 = D.tGrid(1);
tF = D.tGrid(end);
x0 = xGrid(:, 1);
xF = xGrid(:, end);
[bndCstIneq, bndCstEq] = problem.func.bndCst(t0, tF, x0, xF);

% Collapse defect matrix into a vector
c = bndCstIneq;
ceq = [reshape(defects, numel(defects), 1); bndCstEq];

end

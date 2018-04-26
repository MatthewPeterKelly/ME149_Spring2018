function soln = dirColBvpHermiteSimpson(problem)
% soln = dirColBvpHermiteSimpson(problem)
%
% This function computes the solution to a simple trajectory optimization
% problem using the Hermite--Simpson method for direct collocation.
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
%         .time = [1, nSeg+1] = time grid for the transcription (constant)
%         .state = [nState, nSeg+1] = guess for state at gridpoints
%         .control = [nControl, nSeg+1] = guess for control at gridpoints
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
%     .knots = solution at the knot-points
%         .time = [1, nKnot]
%         .state = [nState, nKnot] = state at each knot point
%         .control = [nControl, nKnot] = control at each knot point
%         .dState = [nState, nKnot] = derivative of state at knot points
%
%     .spline = method-consistent spline interpolation of the trajectory
%          .state = matlab PP struct = contains state trajectory
%          .control = matlab PP struct = contains control trajectory
%          .dState = matlab PP struct = time derivative of state spline
%
%     .analysis = discretization error in the collocation equations
%          .collCstErr = function handle
%               IN: t = [1, n] = query time
%               OUT: cstErr = [nState, n] = collocation error
%                           = dState(t) - dynFun(t, state(t), control(t))
%          .meshErr = [nState, nSeg] = integral(|collCstErr|) for each segment
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
P.x0 = computeInitialization(problem, D);

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
grid.dState = problem.func.dynamics(grid.time, grid.state, grid.control);

% Extract knot points:
knots.time = grid.time(D.iKnot);
knots.state = grid.state(:, D.iKnot);
knots.control = grid.control(:, D.iKnot);
knots.dState = grid.dState(:, D.iKnot);

% Create the interpolating splines:
spline.state = ppSpline3a(grid.time, grid.state, grid.dState);
spline.control = ppSpline2b(grid.time, grid.control);
spline.dState = ppDer(spline.state);

% Pack up the output
soln.grid = grid;
soln.knots = knots;
soln.spline = spline;
soln.info = info;
soln.analysis = getErrorAnalysis(problem.func.dynamics, knots, spline);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function analysis = getErrorAnalysis(dynFun, knots, spline)
% analysis = getErrorAnalysis(dynFun, knots, spline)
%
% This function computes the error analysis: a metric that determines how
% much error is introduced by the transcription (discretization) method.
% This can then be used to perform mesh refinement.
%
% INPUTS:
%     dynFun = function handle: dx = dynamics(t, x, u)
%         IN: t = [1, nTime] = time vector (grid points)
%         IN: x = [nState, nTime] = state vector at each grid point
%         IN: u = [nControl, nTime] = control vector at each grid point
%         OUT: dx = [nState, nTime] = dx/dt = derivative of state wrt time
%     knots = solution at the knot-points
%         .time = [1, nKnot]
%         .state = [nState, nKnot] = state at each knot point
%         .control = [nControl, nKnot] = control at each knot point
%         .dState = [nState, nKnot] = derivative of state at knot points
%     spline = method-consistent spline interpolation of the trajectory
%          .state = matlab PP struct = contains state trajectory
%          .control = matlab PP struct = contains control trajectory
%          .dState = matlab PP struct = time derivative of state spline
% OUTPUTS:
%     analysis = discretization error in the collocation equations
%          .collCstErr = function handle
%               IN: t = [1, n] = query time
%               OUT: cstErr = [nState, n] = collocation error
%                           = dState(t) - dynFun(t, state(t), control(t))
%          .meshErr = [nState, nSeg] = integral(|collCstErr|) for each segment
%

% Compute the continuous defect constraint equation:
%   -->  err = dState(t) - dynFun(t, state(t), control(t));
analysis.collCstErr = @(t)(ppval(spline.dState, t) - ...
                           dynFun(t, ...
                              ppval(spline.state, t), ...
                              ppval(spline.control, t)));

% Integrate the continuous defect constraints to compute an estimate of 
% the total error (integrator drift) caused by the discretization.
[nState, nGrid] = size(knots.state);
nSeg = nGrid - 1;
analysis.meshErr = zeros(nState, nSeg);                          
absErrFun = @(t)( abs(analysis.collCstErr(t)) );
for iSeg = 1:nSeg
   analysis.meshErr(:, iSeg) = integral(absErrFun, ...
                                        knots.time(iSeg), ...
                                        knots.time(iSeg+1), ...
                                        'ArrayValued', true, ...
                                        'AbsTol', 1e-12, ...
                                        'RelTol', 1e-12);
end

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
%       .nSeg = integer = number of segments
%       .nGrid = 2*nSeg+1 = integer = number of grid points
%       .nState = integer = dimension of the state space
%       .nControl = integer = dimension of the control space
%       .tKnot = [1, nSeg+1] = time at the knot points
%       .tGrid = [1, nGrid] = time grid (knot and collocation points)
%       .hSeg = [1, nSEg] = duration of each segment
%       .hSegState = [nState, nSeg] = duration of each segment
%       .iKnot = [1, nSeg+1] = index for the knot points
%       .iLow = [1, nSeg] = index for the lower edge of each segment
%       .iMid = [1, nSeg] = index for the midpoint of each segment
%       .iUpp = [1, nSeg] = index for the upper edge of each segment
%

% Problem dimensions:
D.nKnot = length(problem.guess.time);
D.nSeg =  D.nKnot - 1;
D.nGrid = 2 * D.nSeg + 1;
[D.nState, nGridState] = size(problem.guess.state);
if nGridState ~= D.nKnot
   error('problem.guess.state is an invalid size!');
end
[D.nControl, nGridControl] = size(problem.guess.control);
if nGridControl ~= D.nKnot
   error('problem.guess.control is an invalid size!');
end
D.nDecVar = (D.nControl + D.nState) * D.nGrid;

% Index grids:
D.iKnot = 1:2:D.nGrid;
D.iLow = D.iKnot(1:(end-1));
D.iMid = D.iLow + 1;
D.iUpp = D.iMid + 1;

% Set up the time grids:
D.tKnot = problem.guess.time;
D.tGrid = zeros(1, D.nGrid);
D.tGrid(D.iKnot) = problem.guess.time;
D.tGrid(D.iMid) = 0.5 * (D.tGrid(D.iLow) + D.tGrid(D.iUpp));
D.hSeg = diff(D.tKnot);
D.hSegState = ones(D.nState, 1) * D.hSeg;

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

function decVarGuess = computeInitialization(problem, D)
% decVarGuess = computeInitialization(problem, D)
%
% This function computes an initialization (guess) for the decision 
% variables by interpolating the guess provided by the user.
%
% INPUTS:
%   problem = problem struct: see dirColBvpTrap()
%   D = problem description struct: see getProblemDescription()
%
% OUTPUTS:
%   decVarGuess = [nDecVar, 1] = decision variables for initialization
%

% Memory allocation
xGuess = zeros(D.nState, D.nGrid);
uGuess = zeros(D.nControl, D.nGrid);

% Set knot values:
xGuess(:, D.iKnot) = problem.guess.state;
xGuess(:, D.iMid) = 0.5 * (xGuess(:, D.iLow) + xGuess(:, D.iUpp));
uGuess(:, D.iKnot) = problem.guess.control;
uGuess(:, D.iMid) = 0.5 * (uGuess(:, D.iLow) + uGuess(:, D.iUpp));

% Pack the decision variables
decVarGuess = packDecVars(xGuess, uGuess, D);

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
%   The path integral is computed using the simpson quadrature.
%

% Extract the state and control grids
[xGrid, uGrid] = unpackDecVars(decVars, D);

% Evaluate the path objective integrand
dJ = problem.func.pathObj(D.tGrid, xGrid, uGrid);

% Trapezoid rule to compute integral
J = (1.0 / 6.0) * sum(D.hSeg .* (dJ(D.iLow) + 4*dJ(D.iMid) + dJ(D.iUpp)));

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
xMid = xGrid(:, D.iMid);
xUpp = xGrid(:, D.iUpp);

% Compute the dynamics at the lower and upper edge of each segment
dxGrid = problem.func.dynamics(D.tGrid, xGrid, uGrid);
dxLow = dxGrid(:, D.iLow);
dxMid = dxGrid(:, D.iMid);
dxUpp = dxGrid(:, D.iUpp);

% Defect constraint:   (apply simpson quadrature rule)
xDelGrid = xUpp - xLow;
xDelQuad = (1.0 / 6.0) * D.hSegState .* (dxLow + 4*dxMid + dxUpp);
quadDefect = xDelGrid - xDelQuad;

% Midpoint constraint:  (Hermite interpolant)
xMidHermite = 0.5 * (xLow + xUpp) + (D.hSegState / 8.0) .* (dxLow - dxUpp);
midptCst = xMid - xMidHermite;


% Boundary constraint:
t0 = D.tGrid(1);
tF = D.tGrid(end);
x0 = xGrid(:, 1);
xF = xGrid(:, end);
[bndCstIneq, bndCstEq] = problem.func.bndCst(t0, tF, x0, xF);

% Collapse defect matrix into a vector
c = bndCstIneq;
ceq = [reshape(quadDefect, numel(quadDefect), 1); 
       reshape(midptCst, numel(midptCst), 1);
       bndCstEq];

end

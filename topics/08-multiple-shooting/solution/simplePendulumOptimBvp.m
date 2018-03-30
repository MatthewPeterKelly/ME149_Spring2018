function soln = simplePendulumOptimBvp(config, param, nlpOpt)
% soln = simplePendulumOptimBvp(config, param, nlpOpt)
%
% Compute the minimum-torque solution to move the simple pendulum between
% two prescribed states in a specified duration. The transcription of the
% trajectory optimiatization problem is performed using Euler's method
% and multiple shooting with one step per segment.
%
% INPUTS:
%   config = struct = configuration options for the trajectory optimization
%       .nStep = scalar = number of simulation steps
%       .beginState = [2, 1] = initial [angle; rate] 
%       .finalState = [2, 1] = final [angle; rate] 
%       .duration = scalar = duration of the trajectory
%   param = struct = parameters of the simple pendulum
%     .freq = scalar = undamped natural frequency squared
%                    = (gravity / length) for a point mass pendulum
%     .damp = scalar = normalized linear viscous friction term
%   nlpOpt = solver options object, created by:
%        >> nlpOpt = optimset('fmincon')
%       Useful options (set using "." operator, eg: nlpOpt.Display = 'off')
%           --> Display = {'iter', 'final', 'off'}
%           --> OptimalityTolerance = {1e-3, 1e-6}
%           --> ConstraintTolerance = {1e-3, 1e-5, 1e-10}
%
% OUTPUTS:
%   soln = struct = solution data
%    .grid = struct = values of the trajectory at the grid points
%       .time = [1, nStep+1] = knot points
%       .state = [2, nStep+1] = state at the knot points
%       .control = [1, nStep] = control over each step (constant)
%   .info = information about the optimization run
%       .nlpTime = time (seconds) spent in fmincon
%       .exitFlag = fmincon exit flag
%       .objVal = value of the objective function
%       .[all fields in the fmincon "output" struct]
%

% Constant data that is used throughout problem:
D.nState = 2;  % [angle; rate];
D.nControl = 1; % torque
D.tBnd = [0, config.duration];
D.xBnd = [config.beginState, config.finalState];
D.nGrid = config.nStep + 1;
D.tGrid = linspace(0, config.duration, D.nGrid);
D.hStep = diff(D.tBnd) / config.nStep;

% Objective function:  (path objective)
P.objective = @(decVars)( objectiveFunction(decVars, D) );

% Initial guess:
xGrid = interp1(D.tBnd', D.xBnd', D.tGrid')';
uGrid = zeros(1, D.nGrid - 1);  % no control at the final point
P.x0 = packDecVars(xGrid, uGrid);

% No inequality constraints:
P.Aineq = [];
P.bineq = [];

% Set the boundary constraints:  (linear equality constraints)
[P.Aeq, P.beq] = setBoundaryConditions(config, D);

% No limits on the state or control
P.lb = [];
P.ub = [];

% Final setup
P.options = nlpOpt;
P.solver = 'fmincon';

% System dynamics: (nonlinear constraint)
P.nonlcon = @(decVars)( dynamicsConstraint(decVars, param, D) );

% Solve the optimization problem
startTime = tic; 
[decVarSoln, objVal, exitFlag, info] = fmincon(P);
info.nlpTime = toc(startTime);
info.objVal = objVal;
info.exitFlag = exitFlag;

% Unpack the grid:
grid.time = D.tGrid;
[grid.state, grid.control] = unpackDecVars(decVarSoln, D);

% Pack up the output
soln.grid = grid;
soln.info = info;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function decVars = packDecVars(zGrid, uGrid)
% decVars = packDecVars(zGrid, uGrid)
%
% Converts from the easy-to-use format of zGrid and uGrid into the 
% decision variable column vector that is required by fmincon
%
% INPUTS:
%   zGrid = [nState, nGrid] = state at the grid points
%   uGrid = [nControl, nGrid-1] = control at the grid points
%
% OUTPUTS: 
%   decVars = [nDecVar, 1] = column vector of decision variables
%              nDecVar = (nState + nControl)*nGrid
%

decVars = [reshape(zGrid, numel(zGrid), 1); 
           reshape(uGrid, numel(uGrid), 1)];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [zGrid, uGrid] = unpackDecVars(decVars, D)
% [zGrid, uGrid] = unpackDecVars(decVars, D)
%
% Converts from the decision variable column vector that is required by 
% fmincon into the easy-to-use state and control grids.
%
% INPUTS: 
%   decVars = [nDecVar, 1] = column vector of decision variables
%              nDecVar = (nState + nControl)*nGrid
%   D.nState = number of state dimensions
%   D.nControl = number of control dimensions
%   D.nGrid = number of grid points
%
% OUTPUTS:
%   zGrid = [nState, nGrid] = state at the grid points
%   uGrid = [nControl, nGrid-1] = control at the grid points
%


% Number of elements expected for both state and control
numelState = D.nState * D.nGrid;
numelControl = D.nControl * (D.nGrid-1);

% Indices of the decision variables that are for state and control
idxState = 1:numelState;
idxControl = idxState(end) + (1:numelControl);

% Unpack the decision variables now that we have the dimensions
zGrid = reshape(decVars(idxState), D.nState, D.nGrid);
uGrid = reshape(decVars(idxControl), D.nControl, D.nGrid-1);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [A, b] = setBoundaryConditions(config, D)
%
% Set the boundary constraints for the optimization problem
%
% INPUTS:
%   config = optimization configuration (boundary conditions)
%   D = transcription data
%
% OUTPUTS
%   A = linear equality constraint matrix
%   b = linear equality constraint constants
%

% Compute the index for each of the states:
nDecVar = D.nState*D.nGrid + D.nControl * (D.nGrid - 1);
zGrid = zeros(D.nState, D.nGrid);
zGrid(:, 1) = [1;2];  % initial boundary condition
zGrid(:, end) = [3;4];  % final boundary condition
uGrid = zeros(D.nControl, D.nGrid-1);
decVarIdx = packDecVars(zGrid, uGrid);  % Trick to get indices right

% Set the matrices:
A = zeros(4, nDecVar);
b = [config.beginState; config.finalState];
decVarIdx = decVarIdx';
for iCst = 1:4
   A(iCst, :) = (decVarIdx == iCst);  
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function dJ = pathIntegrand(decVars, D)

% Get the control at the grid points
[~, uGrid] = unpackDecVars(decVars, D);

% Torque-squared cost function
dJ = uGrid.^2;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function J = objectiveFunction(decVars, D)

% Euler's method to integrate the cost function:
J = sum(pathIntegrand(decVars, D) * D.hStep);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [c, ceq] = dynamicsConstraint(decVars, param, D)

% Extract the state and control grids
[xGrid, uGrid] = unpackDecVars(decVars, D);

% Break the state into two parts:
xLow = xGrid(:,1:(end-1));
xUpp = xGrid(:, 2:end);

% Simulate the entire system forwward one step in parallel
dxLow = simplePendulumDynamics(xLow, uGrid, param);
xNext = xLow + D.hStep * dxLow;

% Compute the defect in each state at each step in parallel
defect = xNext - xUpp;

% Collapse defect matrix into a vector
c = [];
ceq = reshape(defect, numel(defect), 1);

end

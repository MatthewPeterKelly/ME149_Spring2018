function soln = computeBallisticTrajectory(param, nGrid, method, nlpOpt)
%  soln = computeBallisticTrajectory(param, nGrid, method, nlpOpt)
%
% Computes a ballistic trajectory, given a model of
% the projectile motion and the start and target locations.
%
% INPUTS:
%   param = parameters for the simulation and ballistic model:
%       .gravity = scalar = gravity constant
%       .wind = [3,1] = [w1; w2; w3] = wind velocity
%       .drag = scalar = quadratic drag constant
%       .mass = scalar = mass of the projectile
%       .start = [3,1] = initial position of the trajectory
%       .target = [3,1] = target final position on the trajectory
%   nGrid = scalar = number of gridpoints for the integration method
%           --> use a uniform time grid
%   method = string = name of the desired method
%        'euler' = Euler's method (first-order)
%        'heun' = Heun's method (second-order)
%        'midpoint' = the midpoint method (second-order)
%        'ralston' = Ralston's method (second-order)
%        'rk4' = "The" Runge--Kutta method (forth-order)
%   nlpOpt = solver options object, created by:
%        >> nlpOpt = optimset('fmincon')
%       Useful options (set using "." operator, eg: nlpOpt.Display = 'off')
%           --> Display = {'iter', 'final', 'off'}
%           --> OptimalityTolerance = {1e-3, 1e-6}
%           --> ConstraintTolerance = {1e-3, 1e-5, 1e-10}
%
% OUTPUT:
%   soln = struct with the solution to the ballistic trajectory:
%     .tGrid = [1, nTime] = time grid for the ballistic trajectory
%     .zGrid = [6, nTime] = [x1;x2;x3;  dx1; dx2; dx3] = state trajectory
%
% NOTES:
%   
%   Method: Single Shooting with uniform time grid
%
%   NLP Solver:  fmincon()
%
%   Simulation Method:  runSimulation()
%       - explicit Runge--Kutta methods, order 1, 2, or 4.
%
%   Physics Model:  projectileDynamics()
%

% Dynamical system:
dynFun = @(t,z)( ...
    projectileDynamics(z, param) );

% Initial guess:
% Note:  heuristics!! There are many ways good ways to create a guess.
xDel = param.target - param.start;
dist = norm(xDel);  % distance to the target
xDel(3) = xDel(3) + 0.5*dist;  % aim above the target
guess.T = sqrt(2*param.gravity*xDel(3));  % time to fall
guess.v0 = xDel / guess.T;  % rough guess at the vector

% Set-up for FMINCON:    (hint:    help fmincon    )
problem.objective = @objFun;
problem.x0 = packDecVar(guess.T, guess.v0);
problem.Aineq = [];
problem.bineq = [];
problem.Aeq = [];
problem.beq = [];
problem.lb = [];
problem.ub = [];
problem.nonlcon = @(decVar)( cstFun(decVar, param, dynFun, nGrid, method) );
problem.options = nlpOpt;
problem.solver = 'fmincon';

% Solve the optimization:
[decVarSoln, soln.objVal, soln.exitFlag] = fmincon(problem);
[~,~,soln.tGrid, soln.zGrid] = problem.nonlcon(decVarSoln);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function decVar = packDecVar(T, v0)
% decVar = packDecVar(T, v0)
%
% Pack the components variables into a single decision variable vector
%
% INPUTS:
%   T = scalar = total duration of the simulation
%   v0 = [3, 1] = [dx1; dx2; dx3] = initial velocity
%
% OUTPUTS:
%   decVar = [nDecVar, 1] = vector of decision variables
%
%

decVar = [T; v0];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [T, v0] = unpackDecVar(decVar)
% [T, z0] = unpackDecVar(decVar)
%
% Unpack the decision variable vector into components
%
% INPUTS:
%   decVar = [nDecVar, 1] = vector of decision variables
%
% OUTPUTS:
%   T = scalar = total duration of the simulation
%   v0 = [3, 1] = [dx1; dx2; dx3] = initial velocity vector
%

T = decVar(1);   % total duration of the trajectory
v0 = decVar(2:4);  % initial velocity vector

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function launchSpeedSquared = objFun(decVar)
% launchSpeedSquared = objFun(decVar)
%
% Our goal is to minimize the launch speed
%
% INPUTS:
%   decVar = [nDecVar, 1] = vector of decision variables
%
% OUTPUTS:
%   launchSpeedSquared = scalar = speed at which the projectile is launched
%
% NOTES:
%   We return the launch speed squared, rather than the launch speed. This
%   is done for two reasons: first, it is faster to compute speed-squared,
%   since we avoid doing a sqrt() calculation; second, the gradients of the
%   optimization work out to be nicer when a square-root is not involved.
%   For this example problem the difference in both cases is negligable,
%   but it is good practice and might make a difference on harder problems.
%

[~, v0] = unpackDecVar(decVar);
launchSpeedSquared = sum(v0.^2);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [c, ceq, tGrid, zGrid] = cstFun(decVar, param, dynFun, nGrid, method)
% [c, ceq, tGrid, zGrid] = cstFun(decVar, param, dynFun, nGrid, method)
%
% The trajectory is subject to a single constraint: hit the target
%
% INPUTS:
%   decVar = [nDecVar, 1] = vector of decision variables
%   param = struct with parameters
%       .target = [3, 1] = target position
%       .start = [3, 1] = start position
%       .nGrid = scalar = number of simulation grid points to use
%   dynFun = a function handle:  dz = dynFun(t, z)
%          IN:  t = [1, nTime] = row vector of time
%          IN:  z = [nState, nTime] = matrix of states corresponding to each time
%          OUT: dz = [nState, nTime] = time-derivative of the state at each point
%    nGrid = scalar = number of grid points to use for the simulation
%    method = string = name of the desired method
%        'euler' = Euler's method (first-order)
%        'heun' = Heun's method (second-order)
%        'midpoint' = the midpoint method (second-order)
%        'ralston' = Ralston's method (second-order)
%        'rk4' = "The" Runge--Kutta method (forth-order)  --  default
%
% OUTPUTS:
%  c = [] = inequality constraint (unused, but needed for FMINCON)
%  ceq = [3,1] = final displacement from the target
%  tGrid = [1, nGrid] = time grid used for simulation
%  zGrid = [nDim, nGrid] = state at each point in tGrid
%
% NOTES:
%  We could have used a constraint that the final distance to the target is
%  zero, rather than that the displacement vector should be zero. Why pick
%  one over the other? It turns out that by returning the displacement
%  vector, also known more generally as a "defect vector" we given the
%  optimization more information, which lets it make more accurate updates
%  to the decision variables. In more technical terms: we make the jacobian
%  of the constraint function more sparse and less non-linear.
%
%

% Unpack the decision variables
[T, v0] = unpackDecVar(decVar);

% Set up for the simulation:
z0 = [param.start; v0];  % initial state
tGrid = linspace(0, T, nGrid);  % simulation grid

% Run the simulation:
zGrid = runSimulation(dynFun, tGrid, z0, method);

% Compute the defect vector:
xT = zGrid(1:3, end);  % final position

% Return to fmincon:
c = [];
ceq = xT - param.target;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

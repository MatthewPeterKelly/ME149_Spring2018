function results = EVALUATE_ballisticTrajectory(trajGenFun)
% results = EVALUATE_ballisticTrajectory(trajGenFun)
%
% This function is used to test a trajectory generation function against
% an open-loop simulation. It runs through a batch of different problems
% and assigns a score to each.
%
% INPUTS:
%   trajGenFun = function handle
%     IN: param = parameters for the simulation and ballistic model:
%           .gravity = scalar = gravity constant
%           .wind = [3,1] = [w1; w2; w3] = wind velocity
%           .drag = scalar = quadratic drag constant
%           .mass = scalar = mass of the projectile
%           .start = [3,1] = initial position of the trajectory
%           .target = [3,1] = target final position on the trajectory
%     OUT: soln = struct with the solution to the ballistic trajectory:
%           .tGrid = time grid for the ballistic trajectory
%           .zGrid = state grid for the ballistic trajectory
%
% OUTPUT:
%   results = struct with test results
%       .score = [1, N] = vector of scores for each test
%       .data = [1, N] = struct array of test results
%

if nargin == 0
    trajGenFun = @computeBallisticTrajectory;
end

fid = 1;  % Print to command

% Get the set of parameter structs:
nTest = 10;  % run this many test problems
params = getPseudoRandomParamSet(nTest);

% Number of integration steps:
nGrid = 70;

% Integration method:
method = 'rk4';  % {'euler','heun','midpoint','ralston','rk4'}

% Set the options for FMINCON
nlpOpt = optimoptions('fmincon');
nlpOpt.Display = 'off';
nlpOpt.OptimalityTolerance = 1e-6;
nlpOpt.ConstraintTolerance = 1e-10;

% Score for accepting the solution:
scoreWarn = 1e-6;
scoreFail = 1e-3;

% Generate each set of test results:
results.score = zeros(1, nTest);
fprintf(fid, '=====================================================================\n');
for iTest = 1:nTest
    fprintf(fid, 'Running test %2d / %2d...', iTest, nTest);
    startTime = tic;
    soln = trajGenFun(params(iTest), nGrid, method, nlpOpt);
    solveTime = toc(startTime);
    results.data(iTest) = runTest(soln, params(iTest), solveTime);
    score = results.data(iTest).score;
    nlpTime = results.data(iTest).solveTime;
    results.score(iTest) = score;
    if score < scoreWarn
        fprintf(fid, ' Passed!');
    else
        if score < scoreFail
            fprintf(fid, ' Warning:  close to solution, but low accuracy!\n');
        else
            fprintf(fid, ' Failed!\n');
        end
        fprintf(fid, '    -->  error at final point:  time=%4.4e, dist=%4.4e, speed=%4.4e\n', ...
            results.data(iTest).err.time, ...
            results.data(iTest).err.dist, ...
            results.data(iTest).err.speed);
    end
    fprintf(fid, '    -->  Score: %4.4e,  nlpTime:  %3.3f\n', score, nlpTime);
end
fprintf(fid, '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
fprintf(fid, 'TOTAL PASS: %d / %d\n', sum(results.score <= scoreFail), nTest);
fprintf(fid, '=====================================================================\n');

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function params = getPseudoRandomParamSet(nTest)
% params = getPseudoRandomParamSet(nTest)
%
% Generate a set of parameter structs. A random number genrator is used,
% but the seed is set deterministically. As a result, the output of this
% function will be deterministic. This is important to ensure that every
% example is getting the same set of input data.
%
% INPUTS:
%   nTest = scalar = number of parameter structs
%
% OUTPUT:
%   param = cell array of parameter structs, with fields:
%       .gravity = scalar = gravity constant
%       .wind = [3,1] = [w1; w2; w3] = wind velocity
%       .drag = scalar = quadratic drag constant
%       .mass = scalar = mass of the projectile
%       .start = [3,1] = initial position of the trajectory
%       .target = [3,1] = target final position on the trajectory
%

% Set the pseudo-random number generator, forcing determistic output.
rng(905792, 'twister');

% Loop over each parameter struct:
for iTest=1:nTest
    params(iTest).gravity = 10;  %#ok<AGROW>
    params(iTest).wind = randn(3,1) .* [4; 2; 0.1];  %#ok<AGROW>
    params(iTest).drag = 0.01 * rand(1);  %#ok<AGROW>
    params(iTest).mass = 0.5 + 1.5 * rand(1);  %#ok<AGROW>
    params(iTest).start = zeros(3, 1);  %#ok<AGROW>
    params(iTest).target = [20 + 80*rand(2,1); 0];  %#ok<AGROW>
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function result = runTest(soln, param, solveTime)
% result = runTest(soln, param, solveTime);
%
% Tests the solution to a ballistic trajectory calculation, given a model of
% the projectile motion and the start and target locations.
%
% INPUTS:
%   soln = struct with the solution to the ballistic trajectory:
%     .tGrid = time grid for the ballistic trajectory
%     .zGrid = state grid for the ballistic trajectory
%   param = parameters for the simulation and ballistic model:
%       .gravity = scalar = gravity constant
%       .wind = [3,1] = [w1; w2; w3] = wind velocity
%       .drag = scalar = quadratic drag constant
%       .mass = scalar = mass of the projectile
%       .start = [3,1] = initial position of the trajectory
%       .target = [3,1] = target final position on the trajectory
%   solveTime = scalar = how long did it take to compute the trajectory?
%
% OUTPUT:
%   result = struct with evaluation
%     .score = overall score for the solution
%     .err.time = error in total duration of the trajectory
%     .err.dist = distance from the target
%     .err.speed = error in predicted speed at the target
%     .sim = ode45 simulation data
%

% Set up for ode45 simulation:
dynFun = @(t, z)( projectileDynamics(z, param) );
duration = soln.tGrid(end) - soln.tGrid(1);
tSpan = [0, 1.2 * duration];
zInit = soln.zGrid(:, 1);
odeOpt = odeset(...
    'AbsTol', 1e-10, ...
    'RelTol', 1e-10, ...
    'Events', @ballisticEvents);

% Run the ode45 simulation:
odeSoln = ode45(dynFun, tSpan, zInit, odeOpt);

% Compute the final state from ode45
T = odeSoln.x(end);
pos = odeSoln.y(1:3, end);
vel = odeSoln.y(4:6, end);

% Compute the error metrics:
timeErr = abs(T - duration);
distErr = norm(pos - soln.zGrid(1:3, end));
speedErr = norm(vel - soln.zGrid(4:6, end));

% Compute the score:
result.score = distErr / norm(pos) + speedErr / norm(vel) + timeErr / T;
result.err.time = timeErr;
result.err.dist = distErr;
result.err.speed = speedErr;
result.solveTime = solveTime;
result.truthSim = odeSoln;
result.userSoln = soln;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [value, isTerminal, direction] = ballisticEvents(~, z)
% [value, isTerminal, direction] = ballisticEvents(~, z)
%
% This function is called by ode45 during the simulation to detect a collision
% with the ground. See the help file for ode45 to learn about syntax.
%
% INPUTS:
%   t = [1, n] = time = unused
%   z = [6, n] = [x1;x2;x3;  dx1; dx2; dx3] = state vector
%
% OUTPUTS:
%   value = [1, n] = height of the projectile above the ground
%   isTerminal = true(1, n) = stop when this event is detected
%   direction = -ones(1, n) = stop when the derivative of the event is negative
%
% NOTES:
%   What is going on here?  In simple terms, ode45 is performing a root-finding
%   operation inside of the simulation, such that it will place a grid point
%   exactly where value is zero. It then uses isTerminal and direction to
%   determine whether to stop the simulation or to continue. The non-terminal
%   events are used to detect discontinuities in the simulation, thus keeping
%   the high-order accuracy for systems that have discontinuous dynamics.
%

value = z(3,:);  % height above the ground
isTerminal = true(size(value));  % we want to stop when a collision is detected
direction = -ones(size(value));  % only detect event when approaching ground

end

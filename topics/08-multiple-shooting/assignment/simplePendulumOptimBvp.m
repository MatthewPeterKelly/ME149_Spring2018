function soln = simplePendulumOptimBvp(config, param, nlpOpt)
% soln = simplePendulumOptimBvp(config, param, nlpOpt)
%
% Compute the minimum-torque solution to move the simple pendulum between
% two prescribed states in a specified duration. The transcription of the
% trajectory optimiatization problem is performed using Euler's method
% and multiple shooting with one step per segment. The duration of each
% step is the same (uniform time grid).
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

%%%% TODO:  Implement this function

%%%% HINTS:   (not required, but will make things easier)
%
% Write sub-functions! I suggest at least four:
%   - objective function evaluation
%   - dynamics constraints
%   - unpack decision variables
%   - pack decision variables
%
% Write functions to convert between the decision variable vector (which is
% easy for fmincon to use, but incomprehensible to humans) and the state and
% control at the grid points (hard for fmincon, but easy for humans). This
% will make debugging MUCH easier. Trust me.
%
% Feel free to write a fancy initialization if you want, but I suggest starting
% with the following simple initialization routine:
%   - the state at the grid points varies linearly between the boundaries
%   - the control effort is set to zero
%
% Notice that the control value is constant over each segment - this comes from
% the definition of Euler's method. As a result there is one fewer columns in
% the control grid than the state grid.
%
%%%%%

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

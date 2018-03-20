function [xZero, fZero, nEval, exitCode] = rootSolve(func, xInit, tol, nEvalMax, options)
% [xZero, fZero, nEval, exitCode] = rootSolve(func, xInit, options, tol, nEvalMax, options)
%
% This function is a wrapper that can call six root finding methods:
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xInit = guess at the location of the root.
%   tol = tolerance on both function value and root bracket size
%   nEvalMax = maximum number of function evaluations
%   options = solver options, as a struct:
%     .dxInit = initial step size
%     .method = which method to use?
%         {'fzero', 'newton', 'secant', ...
%          'bisection', 'falsePosition', 'ridder'}
%
% OUTPUTS:
%   xZero = the root of the function on the domain [xLow, xUpp]
%   fZero = function value at xZero
%   nEval = number of function evaluations
%   exitCode = integer indicating the status of the solution:
%      1 --> successful convergence
%      0 --> maximum iteration count reached
%     -1 --> Algorithm terminated by output function.
%     -2 --> [xLow, xUpp] does not bracket a root
%     -3 --> NaN or Inf function value encountered during search for an interval
%            containing a sign change.
%     -4 --> Complex function value encountered during search for an interval
%            containing a sign change.
%     -5 --> fzero may have converged to a singular point.
%     -6 --> fzero can not detect a change in sign of the function.
%     -9 --> internal error

if nargin == 0
    rootSolve_test();
    return
end

% Update the options:
options.fTol = tol;
options.xTol = eps;
options.nEvalMax = nEvalMax;

% Methods without a bracketing step required:
if strcmp(options.method, 'fzero')
    [xZero, fZero, exitCode, output] = fzero(func, xInit);
    nEval = output.funcCount;
    if nEval > options.nEvalMax
        exitCode = 0;
    end
    return
end
if strcmp(options.method, 'newton') || strcmp(options.method, 'secant')
    [xZero, fZero, nEval, exitCode] = rootSolveSimple(func, xInit, options);
    return
end

% Perform root bracketing:
[xLow, xUpp, fLow, fUpp, nEvalBracket, exitCode] = ...
    expansionBracketSearch(func, xInit, options);
if exitCode ~= 1
    xZero = 0.5 * (xLow + xUpp);
    fZero = func(xZero); nEval = nEvalBracket + 1;
    return;
end

% Compute the root within the bracketed interval:
[xZero, fZero, nEvalRoot, exitCode] = ...
    rootSolveBracket(func, xLow, xUpp, fLow, fUpp, options);
nEval = nEvalBracket + nEvalRoot;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function rootSolve_test()

% Select the test problem and method:
iTest = randi(11);
iMethod = randi(6);
methodList = {'fzero', 'newton', 'secant', ...
              'bisection', 'falsePosition', 'ridder'};
method = methodList{iMethod};

% Set the options:
options.dxInit = 0.001;
options.bracketScale = 1.6;
options.method = method;
nEvalMax = 250;
tol = 1e-10;

% Get the problem:
[testFun, testInfo] = testProblem(iTest);
fprintf('Test problem: %d  --  Method: %s\n', iTest, method);

% Get data for a plot of the test function
x = linspace(testInfo.xLow, testInfo.xUpp, 250);
y = testFun(x);

% Set up for root finding
xInit = testInfo.xInit;
[xRoot, yRoot, nEval, exitCode] = rootSolve(testFun, xInit, tol, nEvalMax, options);

% Plot the results:
figure(100034); clf; hold on;

xlabel('x')
ylabel('y')
plot(x, y, 'k-', 'LineWidth', 2);
plot(x([1,end]), [0,0], 'k--','LineWidth',1);
plot(xInit, testFun(xInit), 'ro', 'MarkerSize', 10, 'LineWidth', 3);
if exitCode == 1
    plot(xRoot, yRoot, 'bx', 'MarkerSize', 10, 'LineWidth', 3);
end
plot(testInfo.xRoot, 0.0, 'go', 'MarkerSize', 10, 'LineWidth', 3);
title(['Test problem: ', num2str(iTest), ...
       '  --  Method: ', method, ...
       '  --  Exit: ', num2str(exitCode), ...
       '  --  nEval: ', num2str(nEval)]);
 
fprintf('xRoot: %6.6f,  fRoot: %6.6g,  nEval: %d,  exit: %d\n', ...
    xRoot, yRoot, nEval, exitCode);

end




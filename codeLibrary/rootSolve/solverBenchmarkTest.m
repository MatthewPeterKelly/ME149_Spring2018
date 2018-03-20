function results = solverBenchmarkTest(rootSolveFun)
% results = solverBenchmarkTest(rootSolveFun)
%
% This function is used to benchmark a root solver for scalar functions.
% It works by running the solver on several test problems, each starting
% from a variety of initial points. The total score for each method is
% based on the number of problems on which it found a root, as well as the
% total number of iterations used to find those roots. A penalty is
% assessed if the number of function calls is reported incorrectly.
%
% INPUTS:
%   rootSolveFun = function handle
%       IN: func = a function for a SISO function: [y, dy] = f(x)
%       IN: xInit = initial guess to start the iteration
%       IN: tol = return xZero if abs(func(xZero)) < tol
%       IN: nEvalMax = maximum number of function evaluations
%       OUT: xZero = the root of the function on the domain [xLow, xUpp]
%       OUT: fZero = function value at xZero
%       OUT: nEval = number of function evaluations
%       OUT: exitCode = 1 for success, other integers for error states
%
% OUTPUT:
%   results = struct with test results
%       .score = [N, M] = array of scores for each test
%       .data = [N, M] = struct array of test results
%

global TEST_ROOT_SOLVE_EVAL_COUNT

% Test parameters
nTest = 11;  % Number of test problems defined in testProblem
nInit = 15;  % Number of initializations to use for each problem

% Solver parameters:
tol = 1e-10;
nEvalMax = 100;

% Loop over test problems:
results.nEval = zeros(nTest, nInit);
results.validRoot = zeros(nTest, nInit);
results.success = zeros(nTest, nInit);
for iTest = 1:nTest

    % Get the test problem:
    [testFun, testInfo] = rootSolverTestProblem(iTest);
    func = @(x)( testFunWrapper(x, testFun) );  % wrapper to log eval count
    xInitList = linspace(testInfo.xLow, testInfo.xUpp, nInit + 2);
    xInitList([1,end]) = [];

    for iInit = 1:nInit
        % Run the root solve:
        xInit = xInitList(iInit);
        TEST_ROOT_SOLVE_EVAL_COUNT = 0;
        [xZero, ~, nEval, exitCode] = ...
            rootSolveFun(func, xInit, tol, nEvalMax);
        % Log the results:
        results.nEval(iTest, iInit) = nEval;
        results.nEvalTest(iTest, iInit) = TEST_ROOT_SOLVE_EVAL_COUNT;
        results.validRoot(iTest, iInit) = abs(testFun(xZero)) <= tol;
        results.success(iTest, iInit) = exitCode == 1;
    end
end
results.validEvalCount = results.nEval == results.nEvalTest;
results.validExit = results.validRoot == results.success;
results.nEvalScore = (nEvalMax - results.nEval) / nEvalMax;
results.score = 0.7 * double(results.validRoot) + ...
    0.2 * results.nEvalScore + ...
    0.05 * double(results.validExit) + ...
    0.05 * double(results.validEvalCount);
results.testNotes = '';
if sum(sum(~results.validEvalCount)) > 0
    results.testNotes = [results.testNotes, '-- Invalid nEval count!  '];
end
if sum(sum(~results.validExit)) > 0
    results.testNotes = [results.testNotes, '-- Invalid exit code!  '];
end
if strcmp(results.testNotes, '')
    results.testNotes = 'Passed validation checks!';
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = testFunWrapper(x, testFun)
% This wrapper functions is a direct pass through for testFun, except that
% it increments the gloabl counter on every call. This allows the test to
% verify that the reported evaluation count is correct.
global TEST_ROOT_SOLVE_EVAL_COUNT
if nargout == 1
    y = testFun(x);
else
    [y, dy] = testFun(x);
end
TEST_ROOT_SOLVE_EVAL_COUNT = TEST_ROOT_SOLVE_EVAL_COUNT + 1;
end

function EVALUATE_bracketedRootSolve()
% EVALUATE_bracketedRootSolve()
%
% This function runs a simple unit test to make sure that the bracketed
% root solver is working correctly. In particular, it was used to check
% that ridder's method is working reasonably well when compared to fzero.
%

% Keep track of results across each test run:
global TEST_INFO
TEST_INFO.nPass = 0;
TEST_INFO.nFail = 0;

% Initial seed for the test:
fid = 1;
selfTest = false;  % if true, call fzero() instead of riddersMethod()
seed = 61655;

% Check polynomial roots:
polySeed = seed + 295370;
for iPoly = 1:100
    [testFun, testInfo] = getPolynomialTest(polySeed + iPoly);
    runTest(testFun, testInfo, fid, selfTest);
end

% Print summary:
    fprintf(fid, 'Test Summary  --  nPass: %d  --  nFail: %d\n',...
        TEST_INFO.nPass, TEST_INFO.nFail);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [testFun, testInfo] = getPolynomialTest(seed)
% [testFun, testInfo] = getPolynomialTest(seed)
%
% Generate tests for bracketed root solving. Polynomial function set.
%
% INPUTS:
%   seed = used to initialize the RNG (ensure repeatable results)
%
% OUTPUTS:
%   testFun = function handle:  f = testFun(x)
%       IN: x = scalar
%       OUT: f = scalar
%   testInfo = struct = information about the test
%       xLow = scalar = lower bound on bracket
%       xUpp = scalar = upper bound on bracket
%       xZero = scalar = solution to the equation
%       xBnd = [low, upp] = range for plotting
%
% NOTES:
%   testFun is smooth and [xLow, xUpp] brackets the single root xZero
%
testInfo = getPolynomialTestFunction(seed);
testFun = @(x)( polyval(testInfo.coeff, x) );

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function f = testFunWrapper(testFun, x)
% A simple wrapper function that allows us to verify the evaluation count.

global EVAL_COUNT

f = testFun(x);
EVAL_COUNT = EVAL_COUNT + 1;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function runTest(testFun, testInfo, fid, selfTest)

global TEST_INFO EVAL_COUNT
EVAL_COUNT = 0;
testPass = true;

% Solver parameters:
nEvalMax = 100;  % way more than is needed!
xTol = 1e-8;
fTol = 1e-8;

% Wrap the test function to count evaluations:
instrumentedTestFun = @(x)( testFunWrapper(testFun, x) );

% Run the root solve:
if selfTest
    % Run tests on fzero
    [xZero, fZero, nEval] = fzeroWrapper(instrumentedTestFun, ...
        testInfo.xLow, testInfo.xUpp);
    
    % Run tests that will fail on the fzero wrapper
    if nEval > (nEvalMax + 2)
        testPass = false;
        fprintf(fid, 'Exceeded nEvalMax!  nEval: %d  --  nEvalMax: %d\n', nEval, nEvalMax);
    end
    
else
    % Run tests on riddersMethod
    [xZero, fZero, nEval] = riddersMethod(instrumentedTestFun, ...
        testInfo.xLow, testInfo.xUpp, xTol, fTol, nEvalMax);
end

% Check the result:
xErr = abs(xZero - testInfo.xRoot);
xTolCheck = xErr <= xTol;
fErr = abs(testFun(xZero));
fTolCheck = fErr <= fTol;
if ~xTolCheck && ~fTolCheck
    testPass = false;
    fprintf(fid, 'Convergence check failed!  xErr: %6.6e, fErr: %6.6e, xTol: %6.6e, fTol: %6.6e\n',...
        xErr, fErr, xTol, fTol);
end
fZeroTest = testFun(xZero);
if abs(fZeroTest-fZero) > 10*eps
    testPass = false;
    fprintf(fid, 'Consistency check failed!  testFun(xZero): %6.6e, fZero: %6.6e\n',...
        fZeroTest, fZero);
end

% Check the function eval count:
if EVAL_COUNT ~= nEval
    testPass = false;
    fprintf(fid, 'Bad nEval count!  nEvalCheck: %d, nEval: %d\n',...
        EVAL_COUNT, nEval);    
end

% Store the result:
if testPass
    TEST_INFO.nPass = TEST_INFO.nPass + 1;
else
    TEST_INFO.nFail = TEST_INFO.nFail + 1;
end
end


function EVALUATE_riddersMethod()
% EVALUATE_riddersMethod()
%
% This function runs a simple unit test that compares the output of the
% function riddersMethod with riddersMethodSoln
%

% Keep track of results across each test run:
global TEST_INFO
TEST_INFO.nPass = 0;
TEST_INFO.nFail = 0;

% Initial seed for the test:
fid = 1;
seed = 61655;

% Check polynomial roots:
polySeed = seed + 295370;
for iPoly = 1:100
    [testFun, testInfo] = getPolynomialTest(polySeed + iPoly);
    runTest(testFun, testInfo, fid, polySeed + 10*iPoly);
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

function runTest(testFun, testInfo, fid, seed)

global TEST_INFO EVAL_COUNT
EVAL_COUNT = 0;
testPass = true;

% Solver parameters:
rng(seed);
nEvalMax = 5 + randi(50); 
xTol = 1e-8;
fTol = 1e-8;

% Wrap the test function to count evaluations:
instrumentedTestFun = @(x)( testFunWrapper(testFun, x) );

% Test the student code:
[xZero, fZero, nEval, exitCode] = riddersMethod(instrumentedTestFun, ...
    testInfo.xLow, testInfo.xUpp, xTol, fTol, nEvalMax);

% Run the solution:
[soln.xZero, soln.fZero, soln.nEval, soln.exitCode] = riddersMethodSoln(testFun, ...
    testInfo.xLow, testInfo.xUpp, xTol, fTol, nEvalMax);

%%%% Internal consistency checks against the solution:

if soln.exitCode == 1  % there is a valid input: run standard tests
    
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
    
end

%%%% Comparison against Solution method:
if exitCode ~= soln.exitCode
    testPass = false;
    fprintf(fid, 'Bad exit flag!  soln.exitCode: %d, exitCode: %d\n',...
        soln.exitCode, exitCode);
end

if nEval > soln.nEval
    testPass = false;
    fprintf(fid, 'Solver ran too many iterations!  nEvalSoln: %d, nEval: %d\n',...
        soln.nEval, nEval);
end
% Store the result:
if testPass
    TEST_INFO.nPass = TEST_INFO.nPass + 1;
else
    TEST_INFO.nFail = TEST_INFO.nFail + 1;
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [xZero, fZero, nEval, exitCode] = ...
    riddersMethodSoln(func, xLow, xUpp, xTol, fTol, nEvalMax)
% [xZero, fZero, nEval, exitCode] = ...
%                     riddersMethodSoln(func, xLow, xUpp, xTol, fTol, nEvalMax)
%
% This function solves uses Ridder's method to compute the root of a
% function. The root must be bracketed:
%
%       sign(func(xLow)) ~= sign(func(xUpp))
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xLow = the lower search bound
%   xUpp = the upper search bound
%   xTol = if |xLow - xUpp| < xTol then return success
%   fTol = if |fVal| < fTol then return success
%   nEvalMax = maximum number of function evaluations
%
% OUTPUTS:
%   xZero = the root of the function on the domain [xLow, xUpp]
%   fZero = func(xZero) = function value at xZero
%   nEval = number of function evaluations
%   exitCode = integer indicating the status of the solution:
%      1 --> successful convergence (either xTol or fTol)
%      0 --> maximum iteration count reached
%     -2 --> [xLow, xUpp] does not bracket a root (bad input)
%     -9 --> internal error
%
% NOTES:
%   1) The function must be smooth and continuous on [xLow, xUpp]
%   2) sign(f(xLow)) ~= sign(f(xUpp))
%
% REFERENCE:
%       Numerical Recipes in C, 1992 edition, by
%           William H. Press;‎ Saul A. Teukolsky;‎
%           William T. Vetterling; Brian P. Flannery
%       --> Chapter 9
%

% Initialize all outputs:
nEval = 0;
xZero = 0.5*(xLow + xUpp);
fZero = []; % this should always be set later

% Evaluate function at the boundaries:
fLow = func(xLow); nEval = nEval + 1;
fUpp = func(xUpp); nEval = nEval + 1;

% Check for a root on the bounary:
if abs(fLow) < fTol
    xZero = xLow;
    fZero = fLow;
    exitCode = 1;
    return;
end
if abs(fUpp) < fTol
    xZero = xUpp;
    fZero = fUpp;
    exitCode = 1;
    return;
end

% Ensure that the roots are bracketed
if sign(fLow) == sign(fUpp)
    exitCode = -2;
    return;
end

% Main iteration loop
while (true)
    
    % Compute the value at the midpoint:
    xMid = 0.5*(xLow + xUpp);
    fMid = func(xMid); nEval = nEval + 1;
    
    % Compute the position for the second update:
    s = sqrt(fMid*fMid - fLow*fUpp);
    if s==0.0  % check for convergence at midpoint
        xZero = xMid;
        fZero = fMid;
        exitCode = 1;
        return;
    end
    xTmp = (xMid - xLow) * fMid / s;
    if fLow >= fUpp
        xZero = xMid + xTmp;
    else
        xZero = xMid - xTmp;
    end
    fZero = func(xZero); nEval = nEval + 1;
    
    % Check convergence:
    if nEval > nEvalMax
        exitCode = 0; return;
    elseif abs(xUpp - xLow) < xTol
        exitCode = 1; return;
    elseif abs(fZero) < fTol
        exitCode = 1; return;
    end
    
    %Update
    if sign(fMid) ~= sign(fZero)
        xLow = xMid;
        fLow = fMid;
        xUpp = xZero;
        fUpp = fZero;
    elseif sign(fLow) ~= sign(fZero)
        xUpp = xZero;
        fUpp = fZero;
    elseif sign(fUpp) ~= sign(fZero)
        xLow = xZero;
        fLow = fZero;
    else
        exitCode = -9;
        warning('Internal error in Ridder''s method: lost bracket!');
        return;
    end
    
end


end



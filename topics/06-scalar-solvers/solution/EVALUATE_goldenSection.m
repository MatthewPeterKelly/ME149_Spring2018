function EVALUATE_goldenSection()
% EVALUATE_goldenSection
%
% This function runs a simple unit test to make sure that the golden
% section search is working properly. It is included here only as a 
% simple example. A proper unit test would include a wider variety of test
% functions and check that the input validation and output stats are done
% correctly.
%

% Check polynomial roots:
polySeed = 449788;
nPass = 0; nFail = 0;
for iPoly = 1:50
    [testFun, testInfo] = getPolynomialTest(polySeed + iPoly);
    if runTest(testFun, testInfo)
       nPass = nPass + 1;
    else
        nFail = nFail + 1;
    end
end

fprintf('Evaluate GoldenSection:  nPass = %d,  nFail = %d\n', nPass, nFail);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [testFun, testInfo] = getPolynomialTest(seed)
% [testFun, testInfo] = getPolynomialTest(seed)
%
% Generate tests for bracketed scalar optimization. Polynomial function set.
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
%   testFun is smooth and [xLow, xUpp] brackets the single minimum value
%
testInfo = getPolynomialTestFunction(seed);

% Create the function handle:
slopeCoeff = testInfo.coeff;   % f(x)
valCoeff = polyint(slopeCoeff);  % f'(x)
curveCoeff = polyder(slopeCoeff);  % f''(x)

% Check for min vs max value:
if polyval(curveCoeff, testInfo.xRoot) > 0  % we got a min
    testFun = @(x)( polyval(valCoeff, x) );   
else  % we got a max: flip it
    testFun = @(x)( -polyval(valCoeff, x) );
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function success = runTest(testFun, testInfo, nEvalMax)
%

if nargin < 3
    nEvalMax = 100;  % way more than is needed
end
success = false;  % assume that we fail

% Run the root solve:
xTol = 10*sqrt(eps);
[xMin, fMin, nEval] = goldenSection(testFun, testInfo.xLow, testInfo.xUpp, xTol, nEvalMax);

if nEval > nEvalMax
   disp('Exceeded iteration count!');
   return
end

% Check against fminbnd:
options = optimset(...
    'Display','off',...
    'TolX',xTol,...
    'MaxFunEval',100,...
    'MaxIter',100);
[~,~,exitFlag] = fminbnd(testFun, testInfo.xLow, testInfo.xUpp, options);

if exitFlag ~= 1
    warning('bad exit flag in fminbnd!');
end

% Check the result:
rootCheck = abs(testFun(xMin) - fMin) < 100*eps;
if ~rootCheck    
   disp('Failed to pass consistency check on output'); 
%    plotTestFun(testFun, testInfo);
   return
end

% % Check:
% if abs(xMinSoln-xMin) > 200 * xTol
%    fprintf('xMin error is too large!   (%6.6e)\n', abs(xMinSoln-xMin)); 
% %    plotTestFun(testFun, testInfo);
%    return
% end

% We made it through the simple checks
success = true;

end


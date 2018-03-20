function [xLow, xUpp, fLow, fUpp, nEval, exitCode] = ...
    expansionBracketSearch(func, xInit, options)
% [xLow, xUpp, fLow, fUpp, nEval, exitCode] = 
%    expansionBracketSearch(func, xInit, options)
%
% This function computes a bracketing interval [xLow, xUpp] where the
% user-defined func changes sign.
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xInit = the initial search point
%   options = struct with solver options:
%       .bracketScale = geometric scaling factor (default = 1.6)
%       .dxInit = initial test bracket width (default = 1e-3)
%       .nEvalMax = maximum number of function evaluations (default = 100)
%
% OUTPUTS:
%   xLow = lower edge of bracket
%   xUpp = upper edge of bracket
%   fLow = function value at lower edge of bracket
%   fUpp = function value at upper edge of bracket
%   nEval = number of function evaluations
%   exitCode = integer indicating the status of the solution:
%     1 = success
%     0 = too many function evaluations or iterations
%     -1 = internal error
%     -2 = infeasible problem
%
% REFERENCE:
%       Numerical Recipes in C, 1992 edition, by
%           William H. Press;‎ Saul A. Teukolsky;‎
%           William T. Vetterling; Brian P. Flannery
%       --> Section 9.1 Bracketing and Bisection, Page 352
%

if nargin == 0
    expansionBracketSearch_test();
    return;
end

% Input validation:
if options.bracketScale <= 1.0
    exitCode = -2;
    warning('alpha > 1.0 is required!');
    return;
end
if abs(options.dxInit) < 1e-14
    exitCode = -2;
    warning('|dxInit| >= 1e-14 is required!');
    return;
end

% Initialize the search bracket:
xLow = xInit;
xUpp = xInit + options.dxInit;

% Initialize the function values:
nEval = 0;
fLow = func(xLow); nEval = nEval + 1;
fUpp = func(xUpp); nEval = nEval + 1;

% Main iteration loop:
while (nEval < options.nEvalMax)
    
    % Check to see if the root is bracketed:
    if sign(fLow) ~= sign(fUpp)
        exitCode = 1;
        return;  % success!
    end
    
    % Update whichever boundary has the smaller function value:
    dx = xUpp - xLow;
    if abs(fLow) > abs(fUpp)  % update xUpp
        xUpp = xUpp + dx * options.bracketScale;
        fUpp = func(xUpp); nEval = nEval + 1;
    else  % update xLow
        xLow = xLow - dx * options.bracketScale;
        fLow = func(xLow); nEval = nEval + 1;
    end
    
end
exitCode = 0;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function expansionBracketSearch_test()

% Set up the test problem:
iTest = randi(11);
[testFun, testInfo] = testProblem(iTest);

% Set the options:
options.bracketScale = 1.6;
options.dxInit = 0.001;
options.nEvalMax = 500;

% Evaluate the test function
x = linspace(testInfo.xLow, testInfo.xUpp, 100);
y = testFun(x);

% Find a bracket:
xInit = testInfo.xInit;
[xLow, xUpp, fLow, fUpp, nEval, exitCode] = ...
    expansionBracketSearch(testFun, xInit, options);

% Plot the results:
figure(100034); clf; hold on;
plot(x, y, 'k-', 'LineWidth', 2);
plot(x([1,end]), [0,0], 'k--','LineWidth',1);
if exitCode == 1
    plot(xLow, fLow, 'ro', 'MarkerSize', 10, 'LineWidth', 3);
    plot(xUpp, fUpp, 'bo', 'MarkerSize', 10, 'LineWidth', 3);
end
xlabel('x')
ylabel('y')
title(['Expansion bracket search: ', num2str(nEval), ' iterations']);

fprintf('xLow: %6.6f,  fLow: %6.6g,  xUpp: %6.6f,  fUpp: %6.6g,  nEval: %d\n', ...
    xLow, fLow, xUpp, fUpp, nEval);

end

function [xZero, fZero, nEval, exitCode] = ...
    rootSolveBracket(func, xLow, xUpp, fLow, fUpp, options)
% [xZero, fZero, nEval, exitCode] = ...
%     rootSolveBracket(func, xLow, xUpp, tol, nEvalMax, fLow, fUpp)
%
% This function solves a root-finding problem where the root has already been
% bracketed: sign(func(xLow)) != sign(func(xUpp))
%
% Three different methods are implemented internally:
%   - 'bisection' == simplest method, guarenteed convergence on all problems
%   - 'falsePosition' == intermediate method, good for nice problems
%   - 'ridder' == advanced method, rapid convergence for analytic functions
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xLow = the lower search bound
%   xUpp = the upper search bound
%   fLow = function value at lower bound (set to [] if unknown)
%   fUpp = function value at upper bound (set to [] if unknown)
%   options = solver options, as a struct:
%     .nEvalMax = maximum number of function evaluations
%     .xTol = if |xLow - xUpp| < xTol then return success
%     .fTol = if |fVal| < fTol then return success
%     .method = which method to use?
%         {'bisection', 'falsePosition', 'ridder'}
%
% OUTPUTS:
%   xZero = the root of the function on the domain [xLow, xUpp]
%   fZero = function value at xZero
%   nEval = number of function evaluations
%   exitCode = integer indicating the status of the solution:
%      1 --> successful convergence
%      0 --> maximum iteration count reached
%     -2 --> [xLow, xUpp] does not bracket a root
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

if nargin == 0  % allows the function to be run directly without I/O
    rootSolveBracket_test();
    return;
end

% Initialize all outputs:
nEval = 0;
xZero = 0.5*(xLow + xUpp);
fZero = []; % this should always be set later

% Evaluate function at the boundaries:
if isempty(fLow)
    fLow = func(xLow); nEval = nEval + 1;
end
if isempty(fUpp)
    fUpp = func(xUpp); nEval = nEval + 1;
end

% Check for a root on the bounary:
if abs(fLow) < options.fTol
    xZero = xLow;
    fZero = fLow;
    exitCode = 1;
    return;
end
if abs(fUpp) < options.fTol
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

% Call the iterative solver:
switch options.method
    case 'bisection'
        [xZero, fZero, nEval, exitCode] = ...
            bisectionSearch(func, xLow, xUpp, fLow, fUpp, nEval, options);
    case 'falsePosition'
        [xZero, fZero, nEval, exitCode] = ...
            falsePositionSearch(func, xLow, xUpp, fLow, fUpp, nEval, options);
    case 'ridder'
        [xZero, fZero, nEval, exitCode] = ...
            riddersMethod(func, xLow, xUpp, fLow, fUpp, nEval, options);
    otherwise
        error('invalid method!');
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [xZero, fZero, nEval, exitCode] = ...
            bisectionSearch(func, xLow, xUpp, fLow, fUpp, nEval, options)
% 
% Core implementation for the bisection search method, no input validation,
% since this should be handled by the calling function.
%
% A bisection search works by sampling the central point on the interval, 
% and then setting this as either the new upper or lower bracket edge.
%
% This method is incredibly robust, since it makes no assumptions beyond 
% that the function is continuous and changes sign on the bracket domain.
%

% Main iteration loop:
while (true)
    
    % Compute function value at center of interval
    xZero = 0.5 * (xLow + xUpp);
    fZero = func(xZero); nEval = nEval + 1;
    
    % Check convergence:
    exitCode = convergenceCheck(xLow, xUpp, fZero, nEval, options);
    if ~isempty(exitCode), return; end
    
    % Check which side to select:
    if sign(fZero) == sign(fLow)
        xLow = xZero;
        fLow = fZero;
    elseif sign(fZero) == sign(fUpp)
        xUpp = xZero;
        fUpp = fZero;
    else
        exitCode = -9;
        warning('Internal error in bisection search: lost bracket!');
        return;
    end   
end
        
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [xZero, fZero, nEval, exitCode] = ...
            falsePositionSearch(func, xLow, xUpp, fLow, fUpp, nEval, options)
% 
% Core implementation for the false position search method, there is no 
% input validation because this should be handled by the calling function.
%
% A false-position, or regula falsi, search is similar to a bisection 
% search, but instead of sampling the central point on the domain, it
% instead fits a straight line between the function's two boundary points
% (xLow, fLow) and (xUpp, fUpp) and then computes the zero crossing of that
% straight line. This method will converge much faster than a bisection 
% search on smooth functions, but can have poor convergence for some 
% pathalogical cases.
%

% Main iteration loop:
while (true)
    
     % Compute the update:  (linear model between bracket points)
    xZero = xUpp - fUpp * (xLow - xUpp) / (fLow - fUpp);
    fZero = func(xZero); nEval = nEval + 1;
    
    % Check convergence:
    exitCode = convergenceCheck(xLow, xUpp, fZero, nEval, options);
    if ~isempty(exitCode), return; end
    
    % Check which side to select:
    if sign(fZero) == sign(fLow)
        xLow = xZero;
        fLow = fZero;
    elseif sign(fZero) == sign(fUpp)
        xUpp = xZero;
        fUpp = fZero;
    else
        exitCode = -9;
        warning('Internal error in false position search: lost bracket!');
        return;
    end   
end
        
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [xZero, fZero, nEval, exitCode] = ...
            riddersMethod(func, xLow, xUpp, fLow, fUpp, nEval, options)
% 
% Core implementation for the Ridder's Method root solver. It does not
% perform input checking, as this should be handled by the calling
% function.
%
% Ridder's method is an advanced root-finding method. It is similar to the
% false position method, but it does two evaluations per iteration. The
% first evaluation is at the midpoint, providing three data points. The 
% second evaluation is at the point where an exponential fitted through
% those three points crosses zero. See Numerical Recipes in C for a more
% detailed explanation.
%
% Ridder's method has quadratic convergence for smooth functions, making
% this method an excellent choice for many problems. As with many
% higher-order methods, it is possible to construct a pathalogical example
% where this method will be slower than the standard bisection search.
%

% Main iteration loop:
while (true)
    
    % Compute the value at the midpoint:
    xMid = 0.5*(xLow+xUpp);
    fMid = func(xMid); nEval = nEval + 1;
    
    % Compute the position for the second update:
    s = sqrt(fMid*fMid - fLow*fUpp);
    if s==0.0  % check for convergence at midpoint
        xZero = xMid;
        fZero = fMid;
        exitCode = 1;
        return;
    end
    xTmp = (xMid-xLow)*fMid/s;
    if fLow >= fUpp
        xZero = xMid + xTmp;
    else
        xZero = xMid - xTmp;
    end
    fZero = func(xZero); nEval = nEval + 1;

    % Check convergence:
    exitCode = convergenceCheck(xLow, xUpp, fZero, nEval, options);
    if ~isempty(exitCode), return; end
    
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function exitCode = convergenceCheck(xLow, xUpp, fZero, nEval, options)
if nEval > options.nEvalMax
    exitCode = 0;
elseif abs(xUpp - xLow) < options.xTol
    exitCode = 1;
elseif abs(fZero) < options.fTol
    exitCode = 1;
else
    exitCode = [];
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function rootSolveBracket_test()

% Select the test problem and method:
iTest = randi(11);
iMethod = randi(3);
methodList = {'bisection', 'falsePosition', 'ridder'};
method = methodList{iMethod};

% Set the options:
options.nEvalMax = 500;
options.xTol = 1e-12;
options.fTol = 1e-12;
options.method = method;

% Get the problem:
[testFun, testInfo] = testProblem(iTest);
fprintf('Test problem: %d  --  Method: %s\n', iTest, method);

% Evaluate the test function
x = linspace(testInfo.xLow, testInfo.xUpp, 250);
y = testFun(x);

% Solve:
xLow = testInfo.xLow;
xUpp = testInfo.xUpp;
[xRoot, yRoot, nEval, exitCode] = rootSolveBracket(testFun, xLow, xUpp, [], [], options);

% Plot the test problem:
figure(8440); clf; hold on;
plot(x, y, 'k-', 'LineWidth', 2);
plot(x([1, end]), [0,0], 'k--','LineWidth',1);
plot(xRoot, yRoot, 'bo', 'LineWidth', 3, 'MarkerSize', 10);
xlabel('x')
ylabel('y')
title(['Test problem: ', num2str(iTest), ...
       '  --  Method: ', method, ...
       '  --  Exit: ', num2str(exitCode), ...
       '  --  nEval: ', num2str(nEval)]);

fprintf('xRoot: %6.6f,  fRoot: %6.6g,  nEval: %d,  exit: %d\n', ...
    xRoot, yRoot, nEval, exitCode);

end

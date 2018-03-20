function [xZero, fZero, nEval, exitCode] = rootSolveSimple(func, xInit, options)
% [xZero, fZero, nEval, exitCode] = rootSolveSimple(func, xInit, options)
%
% This function implements two simple methods for root finding:
%   - 'newton' == simplest method, fast convergence for nice problems
%   - 'secant' == similar to newton, but no need for analytic derivatives
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xInit = guess at the location of the root.
%   options = solver options, as a struct:
%     .dxInit = initial step size (secant method only)
%     .nEvalMax = maximum number of function evaluations
%     .fTol = if |fVal| < fTol then return success
%     .method = which method to use?
%         {'newton', 'secant'}
%
% OUTPUTS:
%   xZero = the root of the function on the domain [xLow, xUpp]
%   fZero = function value at xZero
%   nEval = number of function evaluations
%   exitCode = integer indicating the status of the solution:
%      1 --> successful convergence
%      0 --> maximum iteration count reached
%
% NOTES:
%   Newton's method will converge quickly for many functions, but there
%   are some pathalogical functions where it will almost always diverge,
%   such as for sigmoidal functions where the initial guess is poor.
%
% DERIVATION:  (Newton's method)
%   Taylor series approximation:
%       f(x) = f(a) + df(a) * (x - a) + [higher order terms]
%   Truncat at linear terms and then set f(x) == 0  (root finding)
%       -f(a) = df(a) * (x - a)
%       x = a - f(a) / df(a)
%

if nargin == 0
    rootSolveSimple_test();
    return;
end

% Initialize local variables
nEval = 0;
xPrev = xInit;
fPrev = func(xPrev);  nEval = nEval + 1;
xZero = xPrev + options.dxInit;

% Main iteration loop:
while true
    
    switch options.method
        case 'newton'
            
            % Evaluate the function at the new test point
            [fZero, dfZero] = func(xZero);  nEval = nEval + 1;
            
            % Generate the next test point:
            xZero = xZero - fZero / dfZero;
            
        case 'secant'
            
            % Evaluate the function at the new test point
            fZero = func(xZero);  nEval = nEval + 1;
            
            % Generate the next test point:
            dfZero = (fZero - fPrev) / (xZero - fPrev);
            xZero = xZero - fZero / dfZero;
            
        otherwise
            error('Invalid method!');
    end
        
    % Check for convergence
    if nEval > options.nEvalMax
        exitCode = 0;
        return
    elseif abs(fZero) < options.fTol
        exitCode = 1;
        return
    end
    
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function rootSolveSimple_test()

% Select the test problem and method:
iTest = randi(11);
iMethod = randi(2);
methodList = {'newton', 'secant'};
method = methodList{iMethod};

% Set the options:
options.dxInit = 0.001;  % secant method only
options.nEvalMax = 500;
options.fTol = 1e-12;
options.method = method;

% Get the problem:
[testFun, testInfo] = testProblem(iTest);
fprintf('Test problem: %d  --  Method: %s\n', iTest, method);

% Get data for a plot of the test function
x = linspace(testInfo.xLow, testInfo.xUpp, 250);
[y, dy] = testFun(x);

% Set up for root finding
xInit = testInfo.xInit;
[xRoot, yRoot, nEval, exitCode] = rootSolveSimple(testFun, xInit, options);

% Plot the results:
figure(100034); clf

subplot(2, 1, 1); hold on;
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
   
subplot(2, 1, 2); hold on;
plot(x, dy, 'k-', 'LineWidth', 2);
xlabel('x')
ylabel('dy')

fprintf('xRoot: %6.6f,  fRoot: %6.6g,  nEval: %d,  exit: %d\n', ...
    xRoot, yRoot, nEval, exitCode);

end

function [testFun, testInfo] = rootSolverTestProblem(testId)
% [testFun, info] = rootSolverTestProblem(testId)
%
% This function is a wrapper for a set of test problems for scalar root finding.
% Each test function has the following properties:
%   - it is smooth and continuous on the interval [xLow, xUpp]
%   - there is a single root on the interval [xLow, xUpp]
%   - there may be other roots or discontinuities outside of [xLow, xUpp]
%
% INPUTS:
%   testId = index of the desired test problem.
%            if testId > 11
%               then seed = testId and return random test problem
%
% OUTPUTS:
%   testFun = a scalar function handle: [y, dy] = f(x)
%   testInfo = struct with information about the problem:
%     .xInit = point to initialize the search at
%     .xLow = lower bound that brackets the root
%     .xUpp = upper bound that brackets the root
%     .xRoot = solution
%

if nargin == 0
    rootSolverTestProblem_test();
    return;
end

maxTestId = 11;
if testId > maxTestId  % maximum number of tests
    seed = testId;
    testId = mod(testId, maxTestId) + 1;
else
    seed = 0;  % use default initial guess
end

switch testId
    
    case 1
        a = 5;
        b = 3;
        testFun = @(x)(  sinePlusCubic(x, a, b) );
        testInfo.xInit = -1.81;
        testInfo.xLow = -2.54;
        testInfo.xUpp = 1.52;
        testInfo.xRoot = 0;
        
    case 2
        a = 1.5;
        b = 3;
        testFun = @(x)(  sinePlusCubic(x, a, b) );
        [~, testInfo] = rootSolverTestProblem(1);
        
    case 3
        a = 0.5;
        b = 3;
        testFun = @(x)(  sinePlusCubic(x, a, b) );
        [~, testInfo] = rootSolverTestProblem(1);
        
    case 4
        testFun = @specialTanh;
        testInfo.xInit = -1.02;
        testInfo.xLow = -2.1;
        testInfo.xUpp = 2.354;
        testInfo.xRoot = 0;
        
    case 5
        testFun = @specialTanh;
        testInfo.xInit = -4.23;
        testInfo.xLow = -8.42;
        testInfo.xUpp = 7.89;
        testInfo.xRoot = 0;
        
    case 6
        testFun = @singleRational;
        testInfo.xInit = 3.132;
        testInfo.xLow = -0.9;
        testInfo.xUpp = 4.675;
        testInfo.xRoot = 1;
        
    case 7
        roots = [-1.2 + 0.3 * 1i, ...
            -1.2 - 0.3 * 1i, ...
            0, ...
            3.2 + 0.4 * 1i, ...
            3.2 - 0.4 * 1i];
        coeff = poly(roots);
        testFun = @(x)( polynomialTest(x, coeff) );
        testInfo.xInit = 1.53;
        testInfo.xLow = -2.123;
        testInfo.xUpp = 3.685;
        testInfo.xRoot = 0;
        
    case 8
        [testFun, testInfo] = rootSolverTestProblem(7);
        testInfo.xInit = 2.523;
        
    case 9
        roots = [-2.2 + 0.9 * 1i, ...
            -2.2 - 0.9 * 1i, ...
            0, ...
            3.8 + 0.2 * 1i, ...
            3.8 - 0.2 * 1i];
        coeff = poly(roots);
        testFun = @(x)( polynomialTest(x, coeff) );
        testInfo.xInit = 1.784;
        testInfo.xLow = -3.2;
        testInfo.xUpp = 4.62;
        testInfo.xRoot = 0;
        
    case 10
        a = 0.5;
        b = 4;
        c = 1.1;
        testFun = @(x)( sinePlusCubicPlusRational(x, a, b, c) );
        testInfo.xInit = -0.9;
        testInfo.xLow = -1.02;
        testInfo.xUpp = 2.1673;
        testInfo.xRoot = 0;
        
    case 11
        roots = [1, 1, 1];
        coeff = poly(roots);
        testFun = @(x)( polynomialTest(x, coeff) );
        testInfo.xInit = 1.52;
        testInfo.xLow = -2.43;
        testInfo.xUpp = 2.95;
        testInfo.xRoot = 1;
        
    otherwise
        error('Invalid testId!');
end

% Set the initial guess randomly if non-zero seed
if seed > 0
    rng(seed, 'twister');
    val = 0.01 + 0.98*rand(1);
    testInfo.xInit = testInfo.xLow * val + testInfo.xUpp * (1-val);
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = sinePlusCubic(x, a, b)
y = sin(b*x) + a*x.^3;
if nargout > 1
    dy = b*cos(b*x) + 3*a*x.^2;
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = specialTanh(x)
y = tanh(x);
if nargout > 1
    dy = 1 - tanh(x).^2;
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = singleRational(x)
y = (x - 1) ./ (x + 1);
if nargout > 1
    dy = 1 ./ (x + 1) - (x - 1) ./ (x + 1).^2;
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = polynomialTest(x, coeff)
y = polyval(coeff, x);
if nargout > 1
    dy = polyval(polyder(coeff), x);
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = sinePlusCubicPlusRational(x, a, b, c)
y = sin(b*x) + a*x.^3 + x ./ (x + c);
if nargout > 1
    dy = b*cos(b*x) + 3*a*x.^2 + 1 ./ (x + c) - x ./ (x + c).^2;
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function rootSolverTestProblem_test()

iTest = randi(11);
[testFun, testInfo] = rootSolverTestProblem(iTest);

% Evaluate the test function
x = linspace(testInfo.xLow, testInfo.xUpp, 250);
[y, dy] = testFun(x);

% Evaluate the initial guess:
xInit = testInfo.xInit;
[yInit, dyInit] = testFun(xInit);

% Evaluate the solution:
xRoot = testInfo.xRoot;
[yRoot, dyRoot] = testFun(xRoot);

% See how fzero does:
[xZero, yZero, exitFlag, output] = fzero(testFun, testInfo.xInit);
fprintf('xRoot: %6.6f,  fRoot: %6.6g,  nEval: %d\n', ...
    xZero, yZero, output.funcCount);

if exitFlag ~= 1
    warning('fZero failed to find a solution!');
end

% Plot the test problem:
figure(130034); clf;
hSub(1) = subplot(2,1,1); hold on;
plot(x, y, 'k-', 'LineWidth', 2);
plot(x([1,end]), [0,0], 'k--','LineWidth',1);
plot(xInit, yInit, 'rs', 'LineWidth', 3, 'MarkerSize', 10);
plot(xRoot, yRoot, 'bo', 'LineWidth', 3, 'MarkerSize', 10);
if exitFlag == 1
    plot(xZero, yZero, 'gx', 'LineWidth', 3, 'MarkerSize', 10);
end
xlabel('x')
ylabel('y')
title(['Test Problem: ', num2str(iTest)]);

hSub(2) = subplot(2,1,2); hold on;
plot(x, dy, 'k-', 'LineWidth', 2);
plot(x([1,end]), [0,0], 'k--','LineWidth',1);
plot(xInit, dyInit, 'rs', 'LineWidth', 3, 'MarkerSize', 10);
plot(xRoot, dyRoot, 'bo', 'LineWidth', 3, 'MarkerSize', 10);
xlabel('x')
ylabel('dy')

linkaxes(hSub, 'x')
end

function plotTestFun(testFun, testInfo)
% plotTestFun(testFun, testInfo)
%
% Utility to plot a test function for a bracketed iterative solver.
%
% INPUTS:
%   testFun = function handle:  f = testFun(x)
%       IN: x = scalar
%       OUT: f = scalar
%   testInfo = struct = information about the test
%       xLow = scalar = lower bound on bracket
%       xUpp = scalar = upper bound on bracket
%       xZero = scalar = solution to the equation
%       xBnd = [low, upp] = range for plotting
%

% Evaluate the test function
x = linspace(testInfo.xBnd(1), testInfo.xBnd(2), 150);
f = testFun(x);

% Plotting!
cla;  hold on;
plot(testInfo.xBnd, [0,0], 'k--');
plot(x,f, 'k-','LineWidth', 2);
plot(testInfo.xRoot, testFun(testInfo.xRoot), 'rx','LineWidth', 2);
plot(testInfo.xLow, testFun(testInfo.xLow), 'bo','LineWidth', 2);
plot(testInfo.xUpp, testFun(testInfo.xUpp), 'bs','LineWidth', 2);
xlabel('x');
ylabel('f');
title('test problem')

end
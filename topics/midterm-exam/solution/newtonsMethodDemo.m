function newtonsMethodDemo()
run('../../../codeLibrary/addLibraryToPath.m');

testFun = @tanhDiff;
testName = 'tanh(x)';
iterMax = 6;
xA = 1.0;
xB = 1.1;

% testFun = @cubic;
% testName = 't^3 - t^2 - t + 2';
% iterMax = 6;
% xA = -1.0;
% xB = -0.5;

% Make a plot showing convergence
figure(14002); clf;
subplot(2,1,1); hold on;
drawNewtonsMethod(xA, testFun, iterMax);
title(sprintf('Newton''s Method Converges:    f(x) = %s    x(0) = %3.3f', testName, xA));

% Make a plot showing failure
subplot(2,1,2); hold on;
drawNewtonsMethod(xB, testFun, iterMax);
title(sprintf('Newton''s Method Diverges:    f(x) = %s    x(0) = %3.3f', testName, xB));

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function drawNewtonsMethod(xInit, testFun, iterMax)
%
% Draw a few iterations of Newton's method
%

xRoot = zeros(1, iterMax);
xRoot(1) = xInit;  % initial guess

% Run the Newton--Rhapson method
for iter = 2:iterMax
    xPrev = xRoot(iter - 1);
    [y, dy] = testFun(xPrev);
    xRoot(iter) = xPrev - y / dy;
end
yRoot = testFun(xRoot);

% Figure out the search bounds
xRootBnd = xRoot;
if abs(yRoot(end)) > abs(yRoot(1))  % Drop last point if diverging
    [~, iMax] = max(abs(xRootBnd));
    xRootBnd(iMax) = [];
end
xBnd = [min(xRootBnd), max(xRootBnd)];
xBnd = 0.1 * diff(xBnd) * [-1, 1] + xBnd;

yBnd = [min(yRoot), max(yRoot)];
yBnd = 0.1 * diff(yBnd) * [-1, 1] + yBnd;


% Evaluate the function on the search interval
x = linspace(xBnd(1), xBnd(2), 100);
y = testFun(x);

% Make a nice plot!
plot(x, y, 'k', 'LineWidth', 3)
plot(xBnd, [0, 0], 'k-', 'Color', 0.4 * [1,1,1]);
for iter = 2:iterMax
    
    xPrev = xRoot(iter - 1);
    xNext = xRoot(iter);
    yPrev = yRoot(iter - 1);
    
    plot(xPrev, 0, 'ks', 'MarkerSize', 10, 'LineWidth', 2);
    plot(xPrev, yPrev, 'ko', 'MarkerSize', 10, 'LineWidth', 2);
    
    plot(xPrev*[1,1], [0, yPrev], '--', 'Color',0.6 * [1,0.2,1], 'LineWidth', 2);    
    plot([xPrev, xNext], [yPrev, 0], '--', 'Color',0.6 * [0.2,1.0,1], 'LineWidth', 2);
    
    text(xPrev, 0.1 * yBnd(2), sprintf('%d',iter-1), ...
         'HorizontalAlignment', 'center','FontWeight','bold','FontSize', 16);
        
end
set(gca, 'XLim', xBnd);
set(gca, 'YLim', yBnd);

% Annotations
xlabel('x')
ylabel('y')
legend('f(x)','Location','best')

% Print to terminal
for iter = 1:iterMax
    fprintf('iter: %2d  --  x: %+6.4f  --  f(x)=%+5.4f\n', iter, xRoot(iter), yRoot(iter));
end



end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = cubic(t)
%
% Computes cubic function and d/dt
%
y = t.^3 - t.^2 - t + 2;
dy = 3*t.^2 -2*t - 1;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [y, dy] = tanhDiff(t)
%
% Computes tanh() and d/dt of tanh(t)
%
y = tanh(t);
dy = 1 - tanh(t).^2;

end
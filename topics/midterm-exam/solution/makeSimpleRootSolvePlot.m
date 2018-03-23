function makeSimpleRootSolvePlot()
 %#ok<*NOPRT>  % suppress no print warnings
 
t = linspace(-1.2, 1.2, 20);
testFun = @(t)( 0.33 + sin(t) );
y = testFun(t);

% Plot the function
figure(1); clf; hold on;
plot(t,y, 'b-', 'LineWidth', 3);
plot(t([1,end]), [0,0], 'k-', 'LineWidth', 2, 'Color', 0.4*[1,1,1]);

% Plot the brackets
xLow = -1.0;
drawIter(xLow, testFun, 'Low');
xUpp = 1.0;
drawIter(xUpp, testFun, 'Upp');

% Plot the iterations:
x0 = 0.5 * (xLow + xUpp)
drawIter(x0, testFun, '0');

x1 = 0.5 * (xLow + x0)
drawIter(x1, testFun, '1');

x2 = 0.5 * (x1 + x0)
drawIter(x2, testFun, '2');

x3 = 0.5 * (x1 + x2)
drawIter(x3, testFun, '3');

x4 = 0.5 * (x3 + x2)
drawIter(x4, testFun, '4');

% Plot the helper tick marks:
plotTicks(-1, 1, 5, 18);
plotTicks(-1, 1, 17, 8);

% Annotations:
xlabel('x')
ylabel('y')
legend('f(x)','Location','NorthWest')
title('Simple Root Solve Example')
axis tight;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function drawIter(x, fun, name)
y = fun(x);

plot(x, 0, 'ko', 'MarkerSize', 10, 'LineWidth', 3);
plot(x, y, 'ks', 'MarkerSize', 10, 'LineWidth', 3)
plot(x*[1,1], [0, y], 'k--', 'LineWidth',2);
addText(x, -eps*y, ['x', name]);
addText(x, y, ['f', name]);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function addText(t,y,str)
shift = 0.06;
if y < 0
    shift = -shift;
end
text(t, y + shift, str, 'HorizontalAlignment','center', 'FontSize', 14);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotTicks(low, upp, count, tickSize)

xTick = linspace(low,upp,count);
yTick = zeros(size(xTick));
plot(xTick, yTick, 'k+','LineWidth',2, 'MarkerSize', tickSize);

end
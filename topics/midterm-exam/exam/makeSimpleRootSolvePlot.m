function makeSimpleRootSolvePlot()

t = linspace(-1.2, 1.2, 20);
testFun = @(t)( 0.33 + sin(t) );
y = testFun(t);

% Plot the function
figure(1); clf; hold on;
plot(t,y, 'b-', 'LineWidth', 3);
plot(t([1,end]), [0,0], 'k-', 'LineWidth', 2, 'Color', 0.4*[1,1,1]);

% Plot the brackets
drawIter(-1, testFun(-1)); 
text(-1, 0.1, 'xLow', 'HorizontalAlignment','center', 'FontSize', 14);
text(-0.9, -0.55, 'fLow', 'HorizontalAlignment','center', 'FontSize', 14);
drawIter(1, testFun(1));
text(1, -0.1, 'xUpp', 'HorizontalAlignment','center', 'FontSize', 14);
text(0.9, 1.21, 'fUpp', 'HorizontalAlignment','center', 'FontSize', 14);

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

function drawIter(t, y)

plot(t, 0, 'ko', 'MarkerSize', 10, 'LineWidth', 3);
plot(t, y, 'ks', 'MarkerSize', 10, 'LineWidth', 3)
plot(t*[1,1], [0, y], 'k--', 'LineWidth',2); 

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function plotTicks(low, upp, count, tickSize)

xTick = linspace(low,upp,count);
yTick = zeros(size(xTick));
plot(xTick, yTick, 'k+','LineWidth',2, 'MarkerSize', tickSize);

end
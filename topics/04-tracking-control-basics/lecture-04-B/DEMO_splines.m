% DEMO:  splines
%
% This demo shows the difference between the splines constructed by various
% methods. The slope and curvature is explicitly set to zero for method
% that required them to be specified.
%
% Note: it is possible to construct a wide variety of splines by modifying
% the conslstraints and order of the spline. This script shows just a few
% simple examples for comparison purposes.
%

clc; clear;

% Add the code library to the current path
run('../../../codeLibrary/addLibraryToPath.m');

% Set the control points:
xGrid = [0, 5, 4, 1, 1, 8, 6, 6, 2, 4];
tGrid = linspace(0,1,length(xGrid));
vGrid = zeros(size(xGrid));  % used for pwch and pwqh only
aGrid = zeros(size(xGrid));  % used for pwqh only

% Construct the splines:
pp.splineNatural.x = spline(tGrid, xGrid);
pp.splineClamped.x = spline(tGrid,[0, xGrid, 0]);
pp.pchip.x = pchip(tGrid, xGrid);
pp.pwch.x = pwch(tGrid, xGrid, vGrid);
pp.pwqh.x = pwqh(tGrid, xGrid, vGrid, aGrid);  % code library

% Populate derivatives:
methodList = fieldnames(pp);
for iMethod = 1:length(methodList)
    method = methodList{iMethod};
    pp.(method).v = ppDer(pp.(method).x);  % code library
    pp.(method).a = ppDer(pp.(method).v);
end

% Make the plots:
figure(400010); clf;
t = linspace(tGrid(1), tGrid(end), 400);
methodList = fieldnames(pp);
for iMethod = 1:length(methodList)
    method = methodList{iMethod};

    % position:
    subplot(3,1,1); hold on;
    plot(t, ppval(pp.(method).x, t), 'LineWidth', 2);

    % velocity
    subplot(3,1,2); hold on;
    plot(t, ppval(pp.(method).v, t), 'LineWidth', 2);

    % acceleration
    subplot(3,1,3); hold on;
    plot(t, ppval(pp.(method).a, t), 'LineWidth', 2);

end

% Add annotations:
hSub(1) = subplot(3,1,1);
plot(tGrid, xGrid,'ko','LineWidth',2,'MarkerSize',8);
xlabel('t');
ylabel('x');
title({'spline comparison', 'value'});
legend(methodList,'Location','NorthEastOutside');
axis tight;
hSub(2) = subplot(3,1,2);
plot(tGrid, vGrid,'ko','LineWidth',2,'MarkerSize',8);
xlabel('t');
ylabel('v');
title('slope')
legend(methodList,'Location','NorthEastOutside');
axis tight;
hSub(3) = subplot(3,1,3);
plot(tGrid, aGrid,'ko','LineWidth',2,'MarkerSize',8);
xlabel('t');
ylabel('a');
title('curvature');
legend(methodList,'Location','NorthEastOutside')
linkaxes(hSub,'x');
axis tight;

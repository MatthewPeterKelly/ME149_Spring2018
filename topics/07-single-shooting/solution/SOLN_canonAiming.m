function SOLN_canonAiming()
% This function shows how to use single shooting to aim a canon for a
% single set of input parameters.

% Load example parameters:
param = getBallisticParameters();

% Compute the solution:
nGrid = 100;  % how many grid points to use in simulation?
soln = computeBallisticTrajectory(param, nGrid);

% Make a simple plot:
figure(10005); clf;

subplot(2,1,1); hold on;
plot(soln.tGrid, soln.zGrid(1:3,:), 'LineWidth', 2);
plot(soln.tGrid(1)*[1,1,1], param.start, 'ko', 'LineWidth', 2, 'MarkerSize', 8);
plot(soln.tGrid(end)*[1,1,1], param.target, 'ko', 'LineWidth', 2, 'MarkerSize', 8);
legend('x','y','z', 'Location','best');
xlabel('time (s)');
ylabel('position (m)');
title('Ballistic Trajectory');

subplot(2,1,2); hold on;
plot(soln.tGrid, soln.zGrid(4:6,:), 'LineWidth', 2);
plot(soln.tGrid([1,end]), [0,0], 'k--','LineWidth', 1);
legend('x','y','z', 'Location','best');
xlabel('time (s)');
ylabel('velocity (m/s)');

end

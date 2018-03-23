function runSloppySimulation()
tLow = -0.15;  % start time
tUpp = 2.9234;  % stop time
dynFun = @(t, z)( [z(2); -sin(z(1))] );
zInit = [-0.2; 0.6];
[tGrid, zGrid] = runSimBadly(dynFun, tLow, tUpp, zInit);
plot(tGrid, zGrid);
end

function [tGrid, zGrid] = runSimBadly(dynFun, tLow, tUpp, zInit)
tGrid = tLow:0.1:tUpp;
zGrid = zeros(2)
zGrid = zInit;
nDim = length(zInit);
for i = 2:31
    dz = dynFun(tGrid(i), zGrid(:, i-1))
    zGrid(:, i) = zGrid(:, i-1) + 0.1 * dz; 
end
end
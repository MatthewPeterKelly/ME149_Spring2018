function isInstalled = checkForOptimTraj()
% isInstalled = checkForOptimTraj()
%
% This function performs a simple check to see if OptimTraj, an
% open-source trajectory optimization library for Matlab.
%
% If OptimTraj is not installed, then print a warning with instructions to
% install it from:
%
%          https://github.com/MatthewPeterKelly/OptimTraj
%
% OUTPUT:
%   isInstalled = boolean = true if optim traj is installed
%               

isInstalled = exist('optimTraj','file') > 0;

if ~isInstalled
    warning('OptimTraj is not installed!');
    disp('Download from:   https://github.com/MatthewPeterKelly/OptimTraj');
end
       
end
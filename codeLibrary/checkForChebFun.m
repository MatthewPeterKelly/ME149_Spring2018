function isInstalled = checkForChebFun()
% isInstalled = checkForChebFun()
%
% This function performs a simple check to see if ChebFun, an
% open-source orthogonal collocation library for Matlab.
%
% If ChebFun is not installed, then print a warning with instructions to
% install it from:
%
%          http://www.chebfun.org/
%
% OUTPUT:
%   isInstalled = boolean = true if optim traj is installed
%               

isInstalled = exist('chebfun','file') > 0;

if ~isInstalled
    warning('ChebFun is not installed!');
    disp('Download from:   http://www.chebfun.org/');
end
       
end
function [ref, param] = importReferenceTrajectory(refTrajFile, paramFile)
% [ref, param] = importReferenceTrajectory(refTrajFile, paramFile)
%
% This function imports a reference trajectory and parameters from a file.
%
% INPUTS:
%   refTrajFile = csv file with the reference trajectory
%       Header Row:   t, x, y, q, dx, dy, dq, u1, u2
%   paramFile = csv file with model parameters (single data row)
%       Header Row:   m, w, g

% Load the reference trajectory for the quadrotor back-flip
refData = readtable(refTrajFile);
param = table2struct(readtable(paramFile));

% unpack the reference trajectory
refTime = refData.t';
refPos = [refData.x, refData.y, refData.q]';
refVel = [refData.dx, refData.dy, refData.dq]';
refCtrl = [refData.u1, refData.u2]';

% Fit a cubic spline through the data
ref.time = refTime;
ref.state = pchip(refTime, [refPos; refVel]);
ref.control = pchip(refTime, refCtrl);

end
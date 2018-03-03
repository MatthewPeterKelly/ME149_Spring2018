function EVALUATE_quadrotorController(fid)
% EVALUATE_hoverController(fileName)
%
% This function is used to evaluate the performance of the hover controller
% over several simulations.
%
% INPUTS:
%   fid = file identifier, used for location of the log file
%
% USAGE:
%   
% - Add this file to your Matlab path (or current directory)
% - It will call whichever getHoverController and getTrackingController
%   function is finds first. You can figure out which one is called by
%   typing >> edit getHoverController.m and looking at which file is opened
%
% run('../../../codeLibrary/addLibraryToPath.m');

if nargin < 1
    fid = 1;  % print results to command
end
if fid < 1
    error('Invalid fid!');
end

% Run hover test on the ideal dynamics:
fprintf(fid,'\n\n');
seed = [55502, 77572, 73317, 12431, 77467, ...
    56817, 32269, 72140, 82092, 27869];
useRealDyn = false;
try
    for iTest = 1:length(seed)
        hoverIdealStats(iTest) = runHoverTest(seed(iTest), fid, useRealDyn);
    end
catch ME
    printError(fid, ME);
    hoverIdealStats = [];
end

% Run hover test on the real dynamics:
fprintf(fid,'\n\n');
seed = [20349, 10597, 60718, 79256, 47973,...
    5289, 9502, 2618, 5035, 3808];
useRealDyn = true;
try
    for iTest = 1:length(seed)
        hoverRealStats(iTest) = runHoverTest(seed(iTest), fid, useRealDyn); %#ok<*AGROW>
    end
catch ME
    printError(fid, ME);
    hoverRealStats = [];
end

% Import the reference trajectory for the quadrotor back-flip
refTrajFile = 'quadrotorOptimalFlipData.csv';
paramFile = 'quadrotorOptimalFlipParam.csv';
[ref, param] = importReferenceTrajectory(refTrajFile, paramFile);
ctrlFun = getTrackingController(ref, param);

% Run tracking test on the ideal dynamics:
fprintf(fid,'\n\n');
seed = [81759, 51674, 97971, 83237, 68104, ...
    35824, 66731, 66968, 75517, 99597];
useRealDyn = false;
try
    for iTest = 1:length(seed)
        trackingIdealStats(iTest) = runTrackingTest(ctrlFun, ref, param, seed(iTest), fid, useRealDyn);
    end
catch ME
    printError(fid, ME);
    trackingIdealStats = [];
end
% Run tracking test on the real dynamics:
fprintf(fid,'\n\n');
seed = [43299, 71097, 79289, 26683, 60009, ...
    46550, 16271, 41705, 93772, 85332];
useRealDyn = true;
try
    for iTest = 1:length(seed)
        trackingRealStats(iTest) = runTrackingTest(ctrlFun, ref, param, seed(iTest), fid, useRealDyn);
    end
catch ME
    printError(fid, ME);
    trackingRealStats = [];
end
% Summarize the results:  (and print to terminal)
fprintf(fid,'\n\n');
fprintf(fid, 'Hover Controller, Ideal Model: \n');
idealScore = getQuadrotorScore(hoverIdealStats, fid) %#ok<NASGU,NOPRT>
fprintf(fid,'\n\n');
fprintf(fid, 'Hover Controller, Realistic Model: \n');
realScore = getQuadrotorScore(hoverRealStats, fid) %#ok<NOPRT,NASGU>
fprintf(fid,'\n\n');
fprintf(fid, 'Tracking Controller, Ideal Model: \n');
idealScore = getQuadrotorScore(trackingIdealStats, fid) %#ok<NOPRT,NASGU>
fprintf(fid,'\n\n');
fprintf(fid, 'Tracking Controller, Real Model: \n');
realScore = getQuadrotorScore(trackingRealStats, fid) %#ok<NOPRT,NASGU>
fprintf(fid,'\n\n');

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function printError(fid, ME)
fprintf(fid, 'Error in user-defined function. Aborting test.\n');
fprintf(fid, '%s\n', string(ME.getReport));
if fid ~= 1
    fprintf('%s\n', string(ME.getReport));
end
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function score = getQuadrotorScore(stats, fid)
%
% Used for unit testing the quadrotor controller
%

if isempty(stats)
    score = [];
    fprintf(fid, '- Error encountered while running test.\n');
    return
end

% Collapse stats to vectors
names = fieldnames(stats(1));
score = struct();
nTrial = length(stats);
for iName = 1:length(names)
    score.(names{iName}) = zeros(1, nTrial);
    for iTrial = 1:nTrial
        score.(names{iName})(iTrial) = stats(iTrial).(names{iName});
    end
end

% Total tracking score:  (mean tracking error in mm)
score.tracking = 1000 * mean(score.distMean);

% Print messages for the user:
fprintf(fid, '- crashes: %d / %d\n', sum(score.crashed), length(score.crashed));
fprintf(fid, '- mean CPU time: %4.4f ms\n', mean(score.cpuTime));
fprintf(fid, '- mean tracking error: %4.4f mm\n', score.tracking);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function stats = runHoverTest(seed, fid, useRealDyn)
%
% Used for unit testing the quadrotor controller
%
rng(seed);  % ensure repeatable results
if useRealDyn
    fprintf(fid, 'Hover Test: Realistic Dynamics\n');
    errModel.xDist = 0.6 * rand(1);
    errModel.yDist = 0.15 * rand(1);
    errModel.qDist = 0.15 * rand(1);
    errModel.nTerm = 6;
    errModel.freqBnd = [0.02, 5];  % Hz
    planarQuadrotorRealDyn(seed, errModel);
else
    fprintf(fid, 'Hover Test: Ideal Dynamics\n');
end
if fid ~= 1
    disp('Running test...');
end

% Initial position:
xRef = 2 * randn(1);
yRef = 0.5 + 1.0*rand(1);
fprintf(fid, '- Hover Goal:  xRef=%6.6f,  yRef=%6.6f\n', xRef, yRef);

% Parameters:
param.m = 0.3 + 0.8 * rand(1);
param.w = 0.3 + 0.5 * rand(1);
param.g = 2 + 5 * rand(1);
fprintf(fid, '- Param:  m=%6.6f,  w=%6.6f,  g=%6.6f\n', ...
    param.m, param.w, param.g);

% Get the controller (this is what we are testing)
ctrlFun = getHoverController(xRef, yRef, param);

% Closed-loop dynamics
if useRealDyn
    dynFun = @(t, z)( planarQuadrotorRealDyn(t, z, ctrlFun(z), param) );
else
    dynFun = @(t, z)( planarQuadrotorDynamics(z, ctrlFun(z), param) );
end

% Set the initial state:
zHover = [xRef; yRef; zeros(4,1)];
zScale = 0.2 + 0.8 * rand(1) * [0.1, 0.1, 0.5, 0.2, 0.2, 0.5]';
zInit = zHover + randn(6,1).*zScale;

% Evaluate the simulation:
tGrid = linspace(0, 10, 1000);
zRef = zHover * ones(1, length(tGrid));
stats = evaluateQuadrotorController(dynFun, tGrid, zInit, zRef, fid);

end


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function stats = runTrackingTest(ctrlFun, ref, param, seed, fid, useRealDyn)
%
% Used for unit testing the quadrotor controller
%
rng(seed);  % ensure repeatable results
if useRealDyn
    fprintf(fid, 'Tracking Test: Realistic Dynamics\n');
    errModel.xDist = 0.9 * rand(1);
    errModel.yDist = 0.2 * rand(1);
    errModel.qDist = 0.2 * rand(1);
    errModel.nTerm = 7;
    errModel.freqBnd = [0.03, 6];  % Hz
    planarQuadrotorRealDyn(seed, errModel);
    dynFun = @(t,z)( planarQuadrotorRealDyn(t, z, ctrlFun(t, z), param) );
else
    fprintf(fid, 'Tracking Test: Ideal Dynamics\n');
    dynFun = @(t,z)( planarQuadrotorDynamics(z, ctrlFun(t, z), param) );
end
if fid ~= 1
    disp('Running test...');
end

% Set the initial state and time grid:
tLow = ref.time(1);
tUpp = ref.time(end);
tGrid = linspace(tLow, tUpp + 1.0, 1000);
zRef = ppval(ref.state, min(tGrid, tUpp));
zScale = 0.4 * rand(1) * [0.1, 0.1, 0.5, 0.2, 0.2, 0.5]';
zInit = zRef(:,1) + randn(6,1).*zScale;

% Evaluate the simulation:
stats = evaluateQuadrotorController(dynFun, tGrid, zInit, zRef, fid);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function stats = evaluateQuadrotorController(dynFun, tGrid, zInit, zRef, fid)
%
% Used for unit testing the quadrotor controller
%

% Run the simulation
simStartTime = tic;
zGrid = runSimulation(dynFun, tGrid, zInit, 'rk4');

% Evaluate tracking error:
zErr = zRef - zGrid;
xErr = abs(zErr(1,:));
yErr = abs(zErr(2,:));
dist = sqrt(zErr(1,:).^2 + zErr(2,:).^2);

% Compute statistics:
stats.distMean = mean(dist);
stats.distMax = max(dist);
stats.xErrMean = mean(xErr);
stats.xErrMax = max(xErr);
stats.yErrMean = mean(yErr);
stats.yErrMax = max(yErr);
stats.minHeight = min(zGrid(2,:));
stats.crashed = stats.minHeight < 0.0;
stats.cpuTime = toc(simStartTime);

% Make report for the user:
fprintf(fid, '- cpuTime:  %3.1f ms\n', 1000 * stats.cpuTime);
fprintf(fid, '- xErr:  mean=%6.6f  max=%6.6f\n', stats.xErrMean, stats.xErrMax);
fprintf(fid, '- yErr:  mean=%6.6f  max=%6.6f\n', stats.yErrMean, stats.yErrMax);
if stats.crashed
    msg = '    (CRASHED)';
else
    msg = '';
end
fprintf(fid, '- yMin:  %3.3f%s\n', stats.minHeight, msg);

end


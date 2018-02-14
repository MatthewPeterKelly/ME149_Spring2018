function dz = planarQuadrotorRealDyn(t, z, u, param)
% dz = planarQuadrotorRealDyn(t, z, u, param)
%
% This function computes the equations of motion for a planar quadrotor.
%
% STANDARD INPUTS:
%   z = [6, n] = [x; y; q; dx; dy; dq] = state
%        x = horizontal position
%        y = vertical position
%        q = absolute angle (zero for hover)
%        dx = time-derivative of horizontal position
%        dy = time-derivative of vertical position
%        dq = time-derivative of absolute angle (zero for hover)
%   u = [2, n] = [u1; u2] = control
%       u1 = left rotor force
%       u2 = right rotor force
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
%
% SPECIAL INPUTS:
%   rngSeed = positive integer = seed for the random number generator
%   errModel = struct = data for setting the error model
%       .xDist = scalar = scale factor on horizontal force disturbance
%       .yDist = scalar = scale factor on vertical force disturbance
%       .qDist = scalar = scale factor on torque disturbance
%       .nTerm = scalar integer = number of terms in noise model
%       .freqBnd = [low, upp] = bounds on noise frequency (Hz)
%       .massScale = scalar = scale factor on the error in mass
%
% OUTPUTS:
%   dz = [6, n] = [dx; dy; dq; ddx; ddy; ddq] = state derivative
%
% NOTES:
%   --> For a stationary hover:  q == 0,  u1 = u2 = m * g / 2
%
%   --> To initialize the error model, call with a single input:
%       planarQuadrotorRealDyn(RNG_seed);
%

% Error modelling setup:
persistent uDistFun
if nargin == 0  % special calling sequence to initialize the error model
    rngSeed = 71504502;  % Set the default seed
    planarQuadrotorRealDyn(rngSeed);
    return;
end
if nargin == 1 % set the default options:
    rngSeed = t;
    errModel.xDist = 0.04;
    errModel.yDist = 0.04;
    errModel.qDist = 0.04;
    errModel.nTerm = 5;
    errModel.freqBnd = [0.1, 10];  % Hz
    planarQuadrotorRealDyn(rngSeed, errModel);  % t == rngSeed
    return;
end
if nargin == 2  % initialize the disturbance
    rngSeed = t;
    errModel = z;
    uDistFun = getDisturbanceFunction(rngSeed, errModel);
    return;
end
if isempty(uDistFun)
    planarQuadrotorRealDyn(); % Set the default disturbance model
end

% Unpack the state:
q = z(3,:);

% Unpack the control:
u1 = u(1, :);
u2 = u(2, :);

% Unpack the parameters:
m = param.m;
w = param.w;
g = param.g;

% Disturbance forces:
uDist = uDistFun(t);
ux = uDist(1,:) * m * g;
uy = uDist(2,:) * m * g;
uq = uDist(3,:) * m * g * w;

% Call the automatically generated dynamics function:
[ddx, ddy, ddq] = autoGen_planarQuadrotorDynamics(q, u1, u2, ux, uy, uq, m, w, g);

% Pack up the derivative of the state:
dz = [z(4:6,:); ddx; ddy; ddq];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function uDistFun = getDisturbanceFunction(rngSeed, errModel)
% uDistFun = getDisturbanceFunction(rngSeed)
%
% Generate a disturbance function for controller testing. For now, use
% a bad model of the wind
%
% INPUTS:
%   rngSeed = positive integer = seed for the random number generator
%   errModel = struct = data for setting the error model
%       .xDist = scalar = scale factor on horizontal force disturbance
%       .yDist = scalar = scale factor on vertical force disturbance
%       .qDist = scalar = scale factor on torque disturbance
%       .nTerm = scalar integer = number of terms in noise model
%       .freqBnd = [low, upp] = bounds on noise frequency (Hz)
%
% OUTPUTS:
%   uDistFun = function handle = disturbance model
%       IN: t = [1, n] = time
%       OUT: uDist = [3, n] = [ux; uy; uq] = disturbances
%
rng(rngSeed, 'twister');  % Set the random seed generator

nDim = 3;
nTerm = errModel.nTerm;

% Compute the scale factor for each dimension of the disturbance
scale = 0.1 + rand(nDim, nTerm);
for i=1:3
    scale(i,:) = scale(i,:) / sum(scale(i,:));  % normalize each ro
end
scale(1,:) = scale(1,:) * errModel.xDist;
scale(2,:) = scale(2,:) * errModel.yDist;
scale(3,:) = scale(3,:) * errModel.qDist;

% Compute the set of disturbance frequencies:
fBnd = 2*pi*errModel.freqBnd;  % convert to radians
freq = fBnd(1) + diff(fBnd) * rand(nDim, nTerm);

% Compute the set of phases:
phase = 2*pi*rand(nDim, nTerm);

% Generate the function handle
uDistFun = @(t)( smoothDisturbance(t, scale, freq, phase) );

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function u = smoothDisturbance(t, scale, freq, phase)
% u = smoothDisturbance(t, scale, freq, phase)
%
% This function generates a smooth disturbance model from a sum of sines
%
% INPUTS:
%   t = [1, nTime] = input time
%   scale = [nDim, nTerm] = scale factor on each sine function
%   freq = [nDim, nTerm] = frequency on each sine function
%   phase = [nDim, nTerm] = phase on each sine function
%
% OUTPUTS:
%   u = [nDim, nTime] = disturbance at each time step
%

% Initialization:
nTime = length(t);
[nDim, nTerm] = size(scale);
u = zeros(nDim, nTime);

% Loop over each dimension and each term
for iDim = 1:nDim
    for iTerm = 1:nTerm
        a = scale(iDim, iTerm);
        b = freq(iDim, iTerm);
        c = phase(iDim, iTerm);
        u(iDim, :) = u(iDim, :) + a * sin(b * t + c);
    end
end

end





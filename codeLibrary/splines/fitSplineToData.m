function soln = fitSplineToData(problem)
% soln = fitSplineToData(problem)
%
% Fit a cubic spline to a data set. The user can specify boundary
% constraints on the value, slope, and curvature along each dimension.
% The spline is computed using a quadratic program, minimizing the fitting
% error between the spline and the data set, as well as minimizing the
% integral of the jerk-squared along the spline.
%
% This function can be used to compute smooth first and second derivatives
% of a noisy data set, since it returns splines for the slope and curvature
% as well as the value of the data.
%
% INPUTS:
%    problem.tData = [1, nData] = time-stamps for data
%    problem.xData = [nState, nData] = time-stamps for data
%    problem.xLow = [nState, 1] or [] = initial position
%    problem.xUpp = [nState, 1] or []  = final position
%    problem.vLow = [nState, 1] or []  = initial velocity
%    problem.vUpp = [nState, 1] or []  = final velocity
%    problem.aLow = [nState, 1] or []  = initial acceleration
%    problem.aUpp = [nState, 1] or []  = final acceleration
%    problem.smoothing = weight on jerk-squared objective function
%    problem.tKnot = [nKnot, 1] = knot times for spline
%
% OUTPUTS:
%    soln.pp.x = Matlab pp-spline for the position
%    soln.pp.v = Matlab pp-spline for the velocity
%    soln.pp.a = Matlab pp-spline for the acceleration
%    soln.grid.t = problem.tData = time-grid from original data set
%    soln.grid.x = [nState, nData] = position at times grid.t
%    soln.grid.v = [nState, nData] = velocity at times grid.t
%    soln.grid.a = [nState, nData] = acceleration at times grid.t
%
% NOTES:
%   x == position == value of the spline or data
%   v == velocity == slope of the spline or data
%   a == acceleration == curvature of the spline or data
%

if nargin == 0
    test_fitSplineToData();
    return
end

[H, f] = computeQuadraticCostMatrix(problem.tData', problem.xData', ...
                                    problem.tKnot', problem.smoothing);
nState = size(problem.xData,1);
nSeg = length(problem.tKnot) - 1;
[A1, b1] = computeEqCstContinuity(problem.tKnot, nState);
lowBnd.pos = problem.xLow';
lowBnd.vel = problem.vLow';
lowBnd.acc = problem.aLow';
uppBnd.pos = problem.xUpp';
uppBnd.vel = problem.vUpp';
uppBnd.acc = problem.aUpp';
[A2, b2] = computeEqCstBoundary(lowBnd, uppBnd, problem.tKnot);
coeff = solveQpEq(H,f,[A1;A2],[b1;b2]);

nPoly = 4;
pp.form = 'pp';
pp.breaks = problem.tKnot;
pp.coefs = zeros(nSeg*nState, nPoly);  % 4 = cubic coeff count
pp.pieces = nSeg;
pp.order = nPoly;
pp.dim = nState;

for iSeg = 1:nSeg
    for iDim = 1:nState
      idx_pp_row = nState*(iSeg-1) + iDim;
      idx_coef_cols = nPoly*(iSeg-1) + (1:nPoly);
      pp.coefs(idx_pp_row,:) = fliplr(coeff(idx_coef_cols,iDim)');
    end
end

soln.pp.x = pp;
soln.pp.v = ppDer(soln.pp.x);
soln.pp.a = ppDer(soln.pp.v);

soln.grid.t = problem.tData;
soln.grid.x = ppval(soln.pp.x, soln.grid.t);
soln.grid.v = ppval(soln.pp.v, soln.grid.t);
soln.grid.a = ppval(soln.pp.a, soln.grid.t);

soln.problem = problem;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [H, f] = computeQuadraticCostMatrix(tData, xData, tKnot, smooth)
% [H, b] = computeQuadraticCostMatrix(tData, xData, tKnot, smooth)
%
% This function computes the least-squares cost terms for fitting a
% cubic spline to time-series data. Includes a term for minimizing the
% integral of jerk-squared as well.
%
% INPUTS:
%   tData = [nTime, 1] = time-series data
%   xData = [nTime, nState] = state data at each point
%   tKnot = [nKnot, 1] = knot points for cubic spline
%   smooth = weight on jerk-squared
%
% OUTPUTS:
%   H = [4*(nKnot-1), 4*(nKnot-1)] = quadratic cost matrix
%   f = [4*(nKnot-1), nState] = linear cost matrix
%
% NOTES:
%
%   nSeg = nKnot - 1;
%   z = [4*nKnot, nState];
%   z = [C0; C1; ... CN] coefficient vector
%   CI = [aI; bi; ci; di];  x = a + b*t +c*t^2 + d*t^3
%   J = 0.5*z'*H*z + f'*z;  % cost function
%

% Figure out which data points belong to which segments
nKnot = length(tKnot);
nSeg = nKnot - 1;
[~, binIdx] = histc(tData, tKnot);
binIdx(binIdx == nKnot) = nKnot;  % include points at endpoint in last segment
nState = size(xData,2);

% Accumulate cost matrix:
beta = (tData(end) - tData(1))/length(tData);
H = zeros(nSeg*4, nSeg*4);
f = zeros(nSeg*4, nState);
for iBin = 1:nSeg
   tBin = tData(binIdx==iBin);
   xBin = xData(binIdx==iBin, :);
   tZero = tKnot(iBin);
   idx = 4*(iBin-1) + (1:4);
   for iData = 1:length(tBin)
       [hTmp, fTmp] = singleDataPoint(tBin(iData) - tZero, xBin(iData,:));
     H(idx, idx) = H(idx, idx) +  hTmp;
     f(idx,:) = f(idx,:) + fTmp;
   end
   hSeg = tKnot(iBin+1) - tKnot(iBin);
   H(idx, idx) = beta*H(idx, idx) + smooth*minJerk(hSeg);
end
f = beta*f;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [H, f] = singleDataPoint(t, x)
% [H, f] = singleDataPoint(t, x)
%
% Computes the quadratic cost associated with the fitting error between a
% single point and a cubic segment.

t0 = 1;
t1 = t;
t2 = t1*t1;
t3 = t2*t1;
t4 = t2*t2;
t5 = t2*t3;
t6 = t3*t3;

H = [
    t0, t1, t2, t3;
    t1, t2, t3, t4;
    t2, t3, t4, t5;
    t3, t4, t5, t6;
    ];

f = [
    -x*t0;
    -x*t1;
    -x*t2;
    -x*t3;
    ];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function H = minJerk(h)

H = zeros(4,4);
H(4,4) = 36*h;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [A, b] = computeEqCstBoundary(low, upp, tKnot)
% [A, b] = computeEqCstBoundary(low, upp, nKnot)
%
% This function computes the equality constraints that enforce the
% boundary position, velocity, and acceleration.
%
% INPUTS:
%   low.pos = [1, nState] = position at lower boundary
%   low.vel = [1, nState] = velocity at lower boundary
%   low.acc = [1, nState] = acceleration at lower boundary
%   upp.pos = [1, nState] = position at upper boundary
%   upp.vel = [1, nState] = velocity at upper boundary
%   upp.acc = [1, nState] = acceleration at upper boundary
%   nKnot = [scalar] = number of knot points on the spline
%
% OUTPUTS:
%   A = [3*nSeg, 4*nSeg] = linear constraint matrix
%   b = zeros(3*nSeg, nState) = constant terms in constraint
%
% NOTES:
%
%   Set any boundary constraint to [] to ignore it.
%
%   nSeg = nKnot - 1;
%   z = [4*nKnot, nState];
%   z = [C0; C1; ... CN] coefficient vector
%   CI = [aI; bi; ci; di];  x = a + b*t +c*t^2 + d*t^3
%   A*z = b;  % cost function
%

if nargin == 0
    computeEqCstBoundary_test();
    return;
end

b = [
    low.pos;
    low.vel;
    low.acc;
    upp.pos;
    upp.vel;
    upp.acc;
    ];

nGrid = length(tKnot);
nDecVar = 4*(nGrid-1);

if ~isempty(low.pos)
    aLowPos = [1,0,0,0, zeros(1, nDecVar-4)];
else
    aLowPos = [];
end
if ~isempty(low.vel)
    aLowVel = [0,1,0,0, zeros(1, nDecVar-4)];
else
    aLowVel = [];
end
if ~isempty(low.acc)
    aLowAcc = [0,0,2,0, zeros(1, nDecVar-4)];
else
    aLowAcc = [];
end

% Upper edge of the last segment
h1 = tKnot(end) - tKnot(end-1);
h2 = h1*h1;
h3 = h2*h1;

if ~isempty(upp.pos)
    aUppPos = [zeros(1, nDecVar-4), 1,   h1,    h2,      h3];
else
    aUppPos = [];
end
if ~isempty(upp.vel)
    aUppVel = [zeros(1, nDecVar-4), 0,   1,   2*h1,    3*h2];
else
    aUppVel = [];
end
if ~isempty(upp.acc)
    aUppAcc = [zeros(1, nDecVar-4), 0,   0,     2,     6*h1];
else
    aUppAcc = [];
end

A = [
    aLowPos;
    aLowVel;
    aLowAcc;
    aUppPos;
    aUppVel;
    aUppAcc;
    ];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [A, b] = computeEqCstContinuity(tKnot, nState)
% [A, b] = computeEqCstContinuity(tKnot)
%
% This function computes the equality constraints that enforce position,
% velocity, and acceleration continuity.
%
% INPUTS:
%   tKnot = [nKnot, 1] = knot points for cubic spline
%
% OUTPUTS:
%   A = [3*nSeg, 4*nSeg] = linear constraint matrix
%   b = zeros(3*nSeg, nState) = constant terms in constraint
%
% NOTES:
%
%   nSeg = nKnot - 1;
%   z = [4*nKnot, nState];
%   z = [C0; C1; ... CN] coefficient vector
%   CI = [aI; bi; ci; di];  x = a + b*t +c*t^2 + d*t^3
%   A*z = b;  % cost function
%

nKnot = length(tKnot);
nSeg = nKnot - 1;
b = zeros(3*(nSeg-1), nState);

A = zeros(3*(nSeg-1), 4*nSeg);


for iSeg = 1:(nSeg-1)
  rowIdx = 3*(iSeg-1) + (1:3);
  colIdx = 4*(iSeg-1) + (1:4);
  hSeg = tKnot(iSeg+1) - tKnot(iSeg);
  [upp, low] = continuityConstraint(hSeg);
  A(rowIdx, colIdx) = A(rowIdx, colIdx) + upp;
  A(rowIdx, colIdx+4) = A(rowIdx, colIdx+4) - low;
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [upp, low] = continuityConstraint(h)

h2 = h*h;
h3 = h2*h;

% upper edge of the lower segment:
upp = [...
    1,   h,    h2,    h3;
    0,   1,  2*h,   3*h2;
    0,   0,    2,   6*h];
% lower edge of the upper segment:
low = [...
    1,   0,  0,  0;
    0,   1,  0,  0;
    0,   0,  2,  0];

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [zSoln, lambda] = solveQpEq(H,f,A,b)
%
%     min 0.5*x'*H*x + f'*x   subject to:  A*x = b
%

%%% Linear solve formulation:
% [H, Aeq'; Aeq, 0] * [z;w] = [-f;beq]
% MM*xx = cc
%

if nargin == 0
    solveQpEq_test();
    return;
end

s = norm(H);
H = H/s;
f = f/s;

s = norm(A);
A = A/s;
b = b/s;

nCst = size(A,1);
nDecVar = size(H,1);
MM = [H, A'; A, zeros(nCst)];
cc = [-f; b];
xx = MM \ cc;
zSoln = xx(1:nDecVar,:);
lambda = xx((nDecVar+1):end,:);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function test_fitSplineToData()

tBnd = [0, 10];
nData = 200;
nSeg = 9;
smoothing = 1e-5;

t = linspace(tBnd(1), tBnd(2), nData);
problem.tData = t;
problem.xData = [(0.2 + 0.1*t).*sin(t); cos(1.5*t)];

problem.xLow = problem.xData(:,1);
problem.xUpp = problem.xData(:,end);
problem.xData = problem.xData + 0.1*randn(size(problem.xData));

problem.vLow = [];
problem.vUpp = [];
problem.aLow = [];
problem.aUpp = [];

problem.smoothing = smoothing;
problem.tKnot = linspace(tBnd(1), tBnd(2), nSeg);

tic
soln = fitSplineToData(problem);
toc

figure(1542); clf;

subplot(2,1,1); hold on;
plot(problem.tData, problem.xData(1,:), 'r.')
plot(problem.tData, problem.xData(2,:), 'b.')
plot(soln.grid.t, soln.grid.x(1,:),'r-')
plot(soln.grid.t, soln.grid.x(2,:),'b-')
xlabel('time')
ylabel('position')
title('Fit Spline to Data')

subplot(2,1,2); hold on;
plot(soln.grid.t, soln.grid.v(1,:),'r-')
plot(soln.grid.t, soln.grid.v(2,:),'b-')
xlabel('time')
ylabel('velocity')

end

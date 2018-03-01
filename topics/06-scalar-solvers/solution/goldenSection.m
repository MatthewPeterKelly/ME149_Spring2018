function [xMin, fMin, nEval, exitCode] = goldenSection(func, xLow, xUpp, xTol, nEvalMax)
% [xMin, fMin, nEval, exitCode] = goldenSection(func, xLow, xUpp, xTol, nEvalMax)
%
% This function solves uses a golden section search to compute the minimum
% value of a smooth and continuous function on a bracketed search interval
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xLow = the lower search bound (exclusive)
%   xUpp = the upper search bound (exclusive)
%   xTol = tolerance on the search interval
%   nEvalMax = maximum number of function evaluations
%
% OUTPUTS:
%   xZero = the root of the function on the domain [xLow, xUpp]
%   fZero = func(xZero) = function value at xZero
%   nEval = number of function evaluations
%   exitCode = integer indicating the status of the solution:
%      1 --> successful convergence
%      0 --> maximum iteration count reached
%
% NOTES:
%   1) The function must be smooth and continuous on [xLow, xUpp]
%   2) [xLow, xUpp] must bracket a local minima
%
% If the minimum value is at one of the roots, then this algorithm will
% converge to within xTol of the boundary and then return success.
%
% The bracket tolerance xTol should be larger than
% sqrt(eps)*(abs(x1)+abs(x2))
% This limit is derived in Numerical Recipes and has to do with floating
% point precision and Taylor expansions near extremum of functions.
% You can set the limit smaller than this value, but the result will be
% additional function evaluations without improving accuracy.
%
% REFERENCE:
%       Numerical Recipes in C, 1992 edition, by
%           William H. Press;‎ Saul A. Teukolsky;‎
%           William T. Vetterling; Brian P. Flannery
%       --> Chapter 10, Section 1
%

% Constants:
R = 2 / (1 + sqrt(5));  % inverse golden ratio
C = 1 - R;

% Initialize other variables:
nEval = 0;
exitCode = 1;  % assume success
x0 = xLow;  % lower edge of current bracket
x3 = xUpp;  % upper edge of current bracket
x1 = R * x0 + C*x3;  % lower middle test point
x2 = C * x0 + R*x3;  % upper middle test point
f1 = func(x1); nEval = nEval + 1;
f2 = func(x2); nEval = nEval + 1;

% Main iteration loop
while abs(x3-x0) > xTol

   % Decide which side of the bracket to contract towards
   if f2 < f1
       x0 = x1;
       x1 = x2;
       f1 = f2;
       x2 = R * x1 + C * x3;  % new test point, closer to x1
       f2 = func(x2); nEval = nEval + 1;
   else
       x3 = x2;
       x2 = x1;
       x1 = R * x2 + C * x0;
       f2 = f1;
       f1 = func(x1); nEval = nEval + 1;
   end

   % Check evaluation limit
   if nEval > nEvalMax
      exitCode = 0;
      break;
   end

end

% Decide which value to return
if f1 < f2
    xMin = x1;
    fMin = f1;
else
    xMin = x2;
    fMin = f2;
end

end

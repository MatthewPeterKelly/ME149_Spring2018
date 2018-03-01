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
%           William H. Press,‎ Saul A. Teukolsky,‎
%           William T. Vetterling, Brian P. Flannery
%       --> Chapter 10, Section 1
%

%%%% TODO:  implement this function

end

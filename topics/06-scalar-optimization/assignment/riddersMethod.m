function [xZero, fZero, nEval, exitCode] = ...
                      riddersMethod(func, xLow, xUpp, xTol, fTol, nEvalMax)
% [xZero, fZero, nEval, exitCode] = ...
%                     riddersMethod(func, xLow, xUpp, xTol, fTol, nEvalMax)
%
% This function solves uses Ridder's method to compute the root of a
% function. The root must be bracketed:
%
%       sign(func(xLow)) ~= sign(func(xUpp))
%
% INPUTS:
%   func = a function for a SISO function: y = f(x)
%   xLow = the lower search bound
%   xUpp = the upper search bound
%   xTol = if |xLow - xUpp| < xTol then return success
%   fTol = if |fVal| < fTol then return success
%   nEvalMax = maximum number of function evaluations
%
% OUTPUTS:
%   xZero = the root of the function on the domain [xLow, xUpp]
%   fZero = func(xZero) = function value at xZero
%   nEval = number of function evaluations
%   exitCode = integer indicating the status of the solution:
%      1 --> successful convergence (either xTol or fTol)
%      0 --> maximum iteration count reached
%     -2 --> [xLow, xUpp] does not bracket a root (bad input)
%
% NOTES:
%   1) The function must be smooth and continuous on [xLow, xUpp]
%   2) sign(f(xLow)) ~= sign(f(xUpp))
%
% REFERENCE:
%       Numerical Recipes in C, 1992 edition, by
%           William H. Press,‎ Saul A. Teukolsky,‎
%           William T. Vetterling, Brian P. Flannery
%       --> Chapter 9, Section 2
%

%%%% TODO:  implement this function

end

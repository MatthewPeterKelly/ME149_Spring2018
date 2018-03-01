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
%     -9 --> internal error
%
% NOTES:
%   1) The function must be smooth and continuous on [xLow, xUpp]
%   2) sign(f(xLow)) ~= sign(f(xUpp))
%
% REFERENCE:
%       Numerical Recipes in C, 1992 edition, by
%           William H. Press;‎ Saul A. Teukolsky;‎
%           William T. Vetterling; Brian P. Flannery
%       --> Chapter 9, Section 2
%

% Initialize all outputs:
nEval = 0;
xZero = 0.5*(xLow + xUpp);
fZero = []; % this should always be set later

% Evaluate function at the boundaries:
fLow = func(xLow); nEval = nEval + 1;
fUpp = func(xUpp); nEval = nEval + 1;

% Check for a root on the bounary:
if abs(fLow) < fTol
    xZero = xLow;
    fZero = fLow;
    exitCode = 1;
    return;
end
if abs(fUpp) < fTol
    xZero = xUpp;
    fZero = fUpp;
    exitCode = 1;
    return;
end

% Ensure that the roots are bracketed
if sign(fLow) == sign(fUpp)
    exitCode = -2;
    return;
end

% Main iteration loop
while (true)

    % Compute the value at the midpoint:
    xMid = 0.5*(xLow + xUpp);
    fMid = func(xMid); nEval = nEval + 1;

    % Compute the position for the second update:
    s = sqrt(fMid*fMid - fLow*fUpp);
    if s==0.0  % check for convergence at midpoint
        xZero = xMid;
        fZero = fMid;
        exitCode = 1;
        return;
    end
    xTmp = (xMid - xLow) * fMid / s;
    if fLow >= fUpp
        xZero = xMid + xTmp;
    else
        xZero = xMid - xTmp;
    end
    fZero = func(xZero); nEval = nEval + 1;

    % Check convergence:
    if nEval > nEvalMax
        exitCode = 0; return;
    elseif abs(xUpp - xLow) < xTol
        exitCode = 1; return;
    elseif abs(fZero) < fTol
        exitCode = 1; return;
    end

    %Update
    if sign(fMid) ~= sign(fZero)
        xLow = xMid;
        fLow = fMid;
        xUpp = xZero;
        fUpp = fZero;
    elseif sign(fLow) ~= sign(fZero)
        xUpp = xZero;
        fUpp = fZero;
    elseif sign(fUpp) ~= sign(fZero)
        xLow = xZero;
        fLow = fZero;
    else
        exitCode = -9;
        warning('Internal error in Ridder''s method: lost bracket!');
        return;
    end

end


end

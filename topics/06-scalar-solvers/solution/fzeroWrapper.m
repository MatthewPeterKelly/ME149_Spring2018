function [xZero, fZero, nEval, exitFlag] = ...
    fzeroWrapper(func, xLow, xUpp, ~, ~, ~)
% This function implements the same interface as ridder's method, but
% calls fzero in the background instead. It is used to ensure that the
% test is working properly.

[xZero, fZero, exitFlag, output] = fzero(func, [xLow, xUpp]);
nEval = output.funcCount;

end

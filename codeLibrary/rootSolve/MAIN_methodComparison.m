% MAIN  --  Method Comparison
%
% This script compares six different root solving methods on a large set of
% test problems. The results are stored in detail, in addition to a single
% score that is assigned to each algorithm.
%
%

options.dxInit = 0.001;
options.bracketScale = 1.6;

methodList = {'fzero','newton','secant','bisection','falsePosition','ridder'};
nMethod = length(methodList);

score = struct();
results = struct();
notes = struct();
for iMethod = 1:nMethod
    method = methodList{iMethod};
    options.method = method;
    
    rootSolveFun = @(func, xInit, tol, nEvalMax)( rootSolve(func, xInit, tol, nEvalMax, options) );
    
    results.(method) = solverBenchmarkTest(rootSolveFun);
    score.(methodList{iMethod}) = mean(mean(results.(method).score));
    notes.(methodList{iMethod}) = results.(method).testNotes;
end
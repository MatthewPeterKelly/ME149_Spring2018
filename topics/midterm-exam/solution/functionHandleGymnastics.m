%% Set up the workspace
a = 1; b = 2; c = 3; d = 5; e = 7;
trigFun = @(t)( b + sin(a + t) );
funTimes = @(x, y)( d * x + b );
addFun = @(x, z)( [x + c; z - b] );
chainFun = @(y)( sum(addFun(y, e)) );
printFun = @(a, b)( fprintf('%s: %d\n', a, b) );
%% PART A:
A = trigFun(-a);    printFun('A', A);
%% PART B:
B = funTimes(b, d);    printFun('B', B);
%% PART C:
C = chainFun(c);    printFun('C', C);

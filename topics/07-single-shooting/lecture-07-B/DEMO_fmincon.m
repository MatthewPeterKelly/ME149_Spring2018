function DEMO_fmincon()
%
% This function shows how to use FMINCON to solve a two simple test
% problems from the wikipedia page on optimization test functions
%
% https://en.wikipedia.org/wiki/Test_functions_for_optimization
%
% TODO: try solving a few of the others

% Set the options for fmincon
nlpOpt = optimoptions('fmincon');
nlpOpt.Display = 'iter';
nlpOpt.TolFun = 1e-12;

% Rosenbrock function constrained to a cubic and line
P1.objective = @(z)( rosenbrock(z(1,:), z(2,:)) );
P1.x0 = [0.8; 0.9];  % TODO:  try different initializations
P1.Aineq = [];  % no inequality constraints
P1.bineq = [];  % no inequality constraints
P1.Aeq = [];  % no equality constraints
P1.beq = [];  % no equality constraints
P1.lb = [-1.5; -0.5];  % lower bound on decision variables
P1.ub = [1.5; 2.5];  % upper bound on decision variables
P1.nonlcon = @(z)( rosenbrock_cubicAndLiner(z(1,:), z(2,:)) );
P1.options = nlpOpt;
P1.solver = 'fmincon';
[S1.z, S1.f, S1.exit, S1.output] = fmincon(P1);
if norm(S1.z - [1;1]) > 1e-4 || S1.f > 1e-6
   warning('FMINCON failed to return the correct solution to P1'); 
end

% Rosenbrock function constrained to a disk
P2 = P1;
P2.x0 = [1.1; 0.9];  % TODO:  try different initializations
P2.lb = [-1.5; -1.5];  % lower bound on decision variables
P2.ub = [1.5; 1.5];  % upper bound on decision variables
P2.nonlcon = @(z)( rosenbrock_disk(z(1,:), z(2,:)) );
[S2.z, S2.f, S2.exit, S2.output] = fmincon(P2);
if norm(S2.z - [1;1]) > 1e-4 || S2.f > 1e-6
   warning('FMINCON failed to return the correct solution to P2'); 
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function f = rosenbrock(x, y)

f = (1 - x).^2 + 100 * (y - x.^2).^2;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [c, ceq] = rosenbrock_cubicAndLiner(x, y)

c = [...  % inequality constraints
    (x - 1)^3 - y + 1;
    x + y - 2];
ceq = [];  % no equality constraints

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [c, ceq] = rosenbrock_disk(x, y)

c = [x.^2 - y.^2 - 2];  % inequality constraint
ceq = [];  % no equality constraints

end
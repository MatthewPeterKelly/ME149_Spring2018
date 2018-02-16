function hw_04_solution_splineMath()
% hw_04_solution_splineMath()
%
% Solution to the first problem (cubic spline math) on assignment four.
% Print-out is included at the bottom of the file.
%

% Cubic coefficients:
% C = sym('C',[4,1],'real');  % Matlab makes this one-indexed...
% Hard code the coefficients for now, to get the names correct
C0 = sym('C0','real');
C1 = sym('C1','real');
C2 = sym('C2','real');
C3 = sym('C3','real');
C = [C0; C1; C2; C3];

disp('==================================================================');
fprintf('\n'); 

% Create the cubic function:
t = sym('t','real');
x = sym(0);
for i = 1:4
    x = x + C(i) * t.^ (i-1);
end
fprintf('x(t) = %s\n', x);

% Compute the derivatives:
dx = diff(x,t);
fprintf('dx(t) = %s\n', dx);
ddx = diff(dx,t);
fprintf('ddx(t) = %s\n', ddx);
dddx = diff(ddx,t);
fprintf('dddx(t) = %s\n', dddx);

fprintf('\n'); 
disp('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -');
fprintf('\n'); 

%%%% PROBLEM 1-A %%%%

% Boundary conditions, as symbolic variables:
syms h x0 xh v0 vh 'real';  % alternate way to define variables

% Set up the cubic boundary conditions
eqns(1) = x0 - subs(x, t, 0);
eqns(2) = xh - subs(x, t, h);
eqns(3) = v0 - subs(dx, t, 0);
eqns(4) = vh - subs(dx, t, h);

% Print the system of equations:
disp('Part 1A:  solve for coefficients in terms of boundary constraints');
disp('--> System of equations:');
for i = 1:length(eqns)
    fprintf('    [ %s = 0 ]\n', eqns(i));
end

% Solve the linear system:
soln = solve(eqns, C);
disp('--> Solution:');
coeffNames = fieldnames(soln);
for i=1:length(coeffNames)
    name = coeffNames{i};
    fprintf('    %s = %s\n',name, soln.(name));
end

fprintf('\n'); 
disp('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -');
fprintf('\n'); 

%%%% PROBLEM 1-B %%%%

% Print out the easy part:
disp('Part 1B:  compute the acceleration at the boundaries');
disp('--> In terms of coefficients:');
fprintf('    ddx(0) = %s\n', subs(ddx,t,0));
fprintf('    ddx(h) = %s\n', subs(ddx,t,h));

% Write acceleration in terms of boundary values:
ddxSoln = simplify(subs(ddx, soln));
disp('--> In terms of boundary values:');
fprintf('    ddx(0) = %s\n', expand(subs(ddxSoln,t,0)));
fprintf('    ddx(h) = %s\n', expand(subs(ddxSoln,t,h)));

fprintf('\n'); 
disp('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -');
fprintf('\n'); 

%%%% PROBLEM 1-C %%%%

disp('Part 1C:  compute the integral of jerk-squared along the segment');
objFunIntegrand = dddx^2;
fprintf('J = integral( %s )\n', objFunIntegrand);
J = int(objFunIntegrand,t,0,h);

disp('--> In terms of coefficients:');
fprintf('    J = %s\n', J);

disp('--> In terms of boundary values:');
fprintf('    J = %s\n', simplify(subs(J,soln)));
fprintf('\n'); 

disp('==================================================================');


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Note: this function will print the following:
%
% ==================================================================
% 
% x(t) = C0 + C1*t + C2*t^2 + C3*t^3
% dx(t) = C1 + 2*C2*t + 3*C3*t^2
% ddx(t) = 2*C2 + 6*C3*t
% dddx(t) = 6*C3
% 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% 
% Part 1A:  solve for coefficients in terms of boundary constraints
% --> System of equations:
%     [ x0 - C0 = 0 ]
%     [ xh - C0 - C1*h - C2*h^2 - C3*h^3 = 0 ]
%     [ v0 - C1 = 0 ]
%     [ vh - C1 - 2*C2*h - 3*C3*h^2 = 0 ]
% --> Solution:
%     C0 = x0
%     C1 = v0
%     C2 = -(3*x0 - 3*xh + 2*h*v0 + h*vh)/h^2
%     C3 = (2*x0 - 2*xh + h*v0 + h*vh)/h^3
% 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% 
% Part 1B:  compute the acceleration at the boundaries
% --> In terms of coefficients:
%     ddx(0) = 2*C2
%     ddx(h) = 2*C2 + 6*C3*h
% --> In terms of boundary values:
%     ddx(0) = (6*xh)/h^2 - (2*vh)/h - (6*x0)/h^2 - (4*v0)/h
%     ddx(h) = (2*v0)/h + (4*vh)/h + (6*x0)/h^2 - (6*xh)/h^2
% 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% 
% Part 1C:  compute the integral of jerk-squared along the segment
% J = integral( 36*C3^2 )
% --> In terms of coefficients:
%     J = 36*C3^2*h
% --> In terms of boundary values:
%     J = (36*(2*x0 - 2*xh + h*v0 + h*vh)^2)/h^5
% 
% ==================================================================
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







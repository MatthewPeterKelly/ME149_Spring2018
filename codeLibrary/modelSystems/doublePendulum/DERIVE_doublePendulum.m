% Derive -- double pendulum
%
% This script derives the equations of motion, forward kinematics, and
% the mechanical energy of a simple double pendulum model.
%
%

clc; clear;
cd(fileparts(mfilename('fullpath')));
run('../../addLibraryToPath.m');

% constant parameters
m1 = sym('m1','real');
m2 = sym('m2','real');
d1 = sym('d1','real');
d2 = sym('d2','real');
g = sym('g','real');

% states:
q1 = sym('q1','real');  % absolute angle of link one
q2 = sym('q2','real');  % absolute angle of linke two
dq1 = sym('dq1','real');
dq2 = sym('dq2','real');
ddq1 = sym('ddq1','real');
ddq2 = sym('ddq2','real');

% controls:
u1 = sym('u1','real');
u2 = sym('u2','real');

% inertial coordinate frame:
i = [1; 0];
j = [0; 1];

% body frame, link one
e1 = j * cos(q1) - i * sin(q1);

% body frame, link two
e2 = j * cos(q2) - i * sin(q2);

% state and derivative:
z = [q1; q2; dq1; dq2];
dz = [dq1; dq2; ddq1; ddq2];

% take the symbolic derivative of any expresssion (chain rule)
derivative = @(expr)( jacobian(expr, z) * dz );

% position of the first and seconds masses:
p1 = d1 * e1;
p2 = p1 + d2 * e2;

% velocity and acceleration of the masses:
dp1 = derivative(p1);
dp2 = derivative(p2);
ddp1 = derivative(dp1);
ddp2 = derivative(dp2);

% cross product for two dimensions: dot(k, A X B)
cross2d = @(a, b)( a(1) * b(2) - a(2) * b(1) );

% angular momentum balance for entire system about the origin:
eqn1_torques = u1 + cross2d(p1, -m1 * g * j) + cross2d(p2, -m2 * g * j);
eqn1_inertia = cross2d(p1, m1 * ddp1) + cross2d(p2, m2 * ddp2);

% angular momentum balance for mass two about p1:
eqn2_torques = u2 + cross2d(p2 - p1, -m2 * g * j);
eqn2_inertia = cross2d(p2 - p1, m2 * ddp2);

% solve equations of motion:
vars = [ddq1; ddq2];
eqns = simplify([eqn1_torques - eqn1_inertia;  eqn2_torques - eqn2_inertia]);
[MM, ff] = equationsToMatrix(eqns, vars);
soln = simplify(MM \ ff);
ddq1_soln = soln(1);
ddq2_soln = soln(2);

% Compute the total energy in the system:
U = simplify(m1 * g * dot(p1, j) + m2 * g * dot(p2, j));  % potential
T = simplify(m1 * (dp1' * dp1) / 2 + m2 * (dp2' * dp2) / 2);  % kinetic
E = U + T;

% Write the dynamics function (equations of motion)
matlabFunction(ddq1_soln, ddq2_soln, ...
               'File', 'autoGen_doublePendulumDynamics.m', ...
               'Outputs', {'ddq1','ddq2'}, ...
               'Optimize', true, ...
               'Vars',{'q1', 'q2', 'dq1', 'dq2', 'u1', 'u2', ...
                       'm1', 'm2', 'd1', 'd2', 'g'});

% Write the kinematics function:
matlabFunction(p1(1), p1(2), p2(1), p2(2), ...
               dp1(1), dp1(2), dp2(1), dp2(2), ...
               'File', 'autoGen_doublePendulumKinematics.m', ...
               'Outputs', {'p1x', 'p1y', 'p2x', 'p2y', ...
                           'dp1x', 'dp1y', 'dp2x', 'dp2y'}, ...
               'Optimize', true, ...
               'Vars',{'q1', 'q2', 'dq1', 'dq2', 'd1', 'd2'});
           
% Write the mechanical energy function:
matlabFunction(E, T, U, ...
               'File', 'autoGen_doublePendulumEnergy.m', ...
               'Outputs', {'totalEnergy', 'kineticEnergy', 'potentialEnergy'}, ...
               'Optimize', true, ...
               'Vars',{'q1', 'q2', 'dq1', 'dq2',...
                       'm1', 'm2', 'd1', 'd2', 'g'});
                   
                   
                   
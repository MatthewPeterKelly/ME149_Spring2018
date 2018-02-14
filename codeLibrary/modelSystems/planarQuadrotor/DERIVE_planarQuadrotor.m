% Derive -- planar quadrotor
%
% This script derives the equations of motion, forward kinematics, and 
% linearized dynamics for the planar quadrotor model.
%
% Assumptions:
%   - planar model
%   - quadrotor is a thin rod
% 
%%

clc; clear;
cd(fileparts(mfilename('fullpath')));
run('../../addLibraryToPath.m');

% constant parameters
m = sym('m','real');  % mass (distributed as a thin rod)
w = sym('w','real');  % width (distance between rotors)
g = sym('g','real');  % gravity acceleration (-j direction)

% assumptions on parameters
assume(m > 0);
assume(w > 0);
assume(g > 0);

% states:
x = sym('x','real');  % horizontal position of the center of the quadrotor
y = sym('y','real');  % vertical position of the center of the quadrotor
q = sym('q','real');  % absolute angle of the quadrotor (zero in hover)
dx = sym('dx','real');  % time_derivative(x)
dy = sym('dy','real');  % time_derivative(y)
dq = sym('dq','real');  % time_derivative(q)
ddx = sym('ddx','real');  % time_derivative(dx)
ddy = sym('ddy','real');  % time_derivative(dy)
ddq = sym('ddq','real');  % time_derivative(dq)

% controls:
u1 = sym('u1','real');  % force produced by right rotor
u2 = sym('u2','real');  % force produced by left rotor

% disturbance inputs
ux = sym('ux','real');  % disturbance force in x direction (wind)
uy = sym('uy','real');  % disturbance force in y direction (wind)
uq = sym('uq','real');  % disturbance torque in q direction (wind)

% inertial coordinate frame:
i = [1; 0];
j = [0; 1];

% body frame: direction from center of quadrotor to rotor one
a = cos(q) * i + sin(q) * j;

% body frame: direction of positive thrust
b = -sin(q) * i + cos(q) * j;

% state and derivative:
z = [x; y; q; dx; dy; dq];
dz = [dx; dy; dq; ddx; ddy; ddq];

% take the symbolic derivative of any expresssion (chain rule)
derivative = @(expr)( jacobian(expr, z) * dz );

% position vectors
p0 = x*i + y*j;  % position of the center of the quadrotor
p1 = p0 + w * a / 2;  % position of rotor one
p2 = p0 - w * a / 2;  % position of rotor two

% velocity and acceleration of the masses:
dp0 = derivative(p0);
dp1 = derivative(p1);
dp2 = derivative(p2);
ddp0 = derivative(dp0);
ddp1 = derivative(dp1);
ddp2 = derivative(dp2);

% cross product for two dimensions: dot(k, A X B)
cross2d = @(a, b)( a(1) * b(2) - a(2) * b(1) );

% angular momentum balance for entire system about p0
eqn1_torques = ... % no terms for disturbance and weight acting at p0
    uq + ...   % disturbance torque  
    cross2d(p1-p0, u1*b) +  ...  % rotor one thrust
    cross2d(p2-p0, u2*b);  % rotor two thrust
eqn1_inertia = m*w*w*ddq/12;  % moment of inertia of a thin rod = I*alpha

% linear momentum balance for entire system
eqn2_forces = ...
    ux * i + uy * j + ... % disturbance forces
    u1 * b + u2 * b + ... % thrust force
    -m * g * j;  % weight of the quadrotor
eqn2_inertia = m * ddp0; % mass * acceleration

% solve equations of motion:
vars = [ddx; ddy; ddq];
eqns = simplify([eqn1_torques - eqn1_inertia;  eqn2_forces - eqn2_inertia]);
soln = solve(eqns, vars);

% Solve the linearized dynamics:  (assumes zero disturbance)
% --> note: gravity drops out (not coupled to state or control)
soln.dz = subs(dz, soln);
soln.A = jacobian(soln.dz, z);
soln.B = jacobian(soln.dz, [u1; u2]);  

% For visualization: thrust vectors
thrustScale = 8 * m * g * w;  % nominal arrow length
p1v = p1 - (u1 / thrustScale) * b;
p2v = p2 - (u2 / thrustScale) * b;

% % Pseudo-inverse dynamics:
% ctrlVars = [u1; u2; q];
% ctrlEqns = subs(eqns,[ux, uy, uq],[0,0,0]);
% invDynSoln = solve(ctrlEqns, ctrlVars, 'ReturnConditions', true);
% %--> Doesn't quite work: solve does not know about atan2() ...

% Special case: thrust for hovering:
hoverEqns = subs([soln.ddy; soln.ddq],[q,uy,uq],[0,0,0]);
hoverVars = [u1;u2];
hoverSoln = solve(hoverEqns, hoverVars);

% Write the dynamics function (equations of motion)
matlabFunction(soln.ddx, soln.ddy, soln.ddq, ...
               'File', 'autoGen_planarQuadrotorDynamics.m', ...
               'Outputs', {'ddx','ddy','ddq'}, ...
               'Optimize', true, ...
               'Vars',{'q', ...
                       'u1', 'u2', 'ux', 'uy', 'uq', ...
                       'm', 'w','g'});
                         
% Write the linearized dynamics function (equations of motion)
matlabFunction(soln.A, soln.B, ...
               'File', 'autoGen_planarQuadrotorLinDyn.m', ...
               'Outputs', {'A','B'}, ...
               'Optimize', true, ...
               'Vars',{'q', ...
                       'u1', 'u2', ...
                       'm', 'w'});
                   
% Write the kinematics function (for visualization)
matlabFunction(p0, p1, p2, p1v, p2v, ...
               'File', 'autoGen_planarQuadrotorKinematics.m', ...
               'Outputs', {'p0', 'p1', 'p2', 'p1v', 'p2v'}, ...
               'Optimize', true, ...
               'Vars',{'x', 'y', 'q', ...
                       'u1', 'u2', ...
                       'm', 'w', 'g'});
                                    
% Write the function to get the hover control
matlabFunction(hoverSoln.u1, hoverSoln.u2, ...
               'File', 'autoGen_planarQuadrotorHoverThrust.m', ...
               'Outputs', {'u1','u2'}, ...
               'Vars',{'m','g'});
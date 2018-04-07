% Derive -- planar quadrotor
%
% This script derives the equations of motion, forward kinematics, and 
% linearized dynamics for the planar quadrotor model with a pendulum
% connected to its center.
%
% Assumptions:
%   - planar model
%   - quadrotor is a thin rod
%   - pendulum is a thin rod
% 
%%

clc; clear;
cd(fileparts(mfilename('fullpath')));
run('../../addLibraryToPath.m');

% constant parameters
m1 = sym('m1','real');  % mass of quadrotor (distributed as a thin rod)
w = sym('w','real');  % width (distance between rotors)
g = sym('g','real');  % gravity acceleration (-j direction)
l = sym('l','real');  % length of the pendulum
m2 = sym('m2','real');  % pendulum mass (distributed as a thin rod)

% assumptions on parameters
assume(m1 > 0);
assume(w > 0);
assume(g > 0);
assume(l > 0);
assume(m2 > 0);

% configuration:
x = sym('x','real');  % horizontal position of the center of the quadrotor
y = sym('y','real');  % vertical position of the center of the quadrotor
q1 = sym('q1','real');  % absolute angle of the quadrotor (zero in hover)
q2 = sym('q2','real');  % absolute angle of the pole (zero in min. energy)

% rates
dx = sym('dx','real');  % time_derivative(x)
dy = sym('dy','real');  % time_derivative(y)
dq1 = sym('dq1','real');  % time_derivative(q1)
dq2 = sym('dq2','real');  % time_derivative(q2)

% accelerations
ddx = sym('ddx','real');  % time_derivative(dx)
ddy = sym('ddy','real');  % time_derivative(dy)
ddq1 = sym('ddq1','real');  % time_derivative(dq1)
ddq2 = sym('ddq2','real');  % time_derivative(dq2)

% thust controls:
u1 = sym('u1','real');  % force produced by right rotor
u2 = sym('u2','real');  % force produced by left rotor
uq = sym('uq','real');  % torque acting on the pendulum (from the quadrotor)

% disturbance inputs
ux = sym('ux','real');  % disturbance force in x direction (wind)
uy = sym('uy','real');  % disturbance force in y direction (wind)

% inertial coordinate frame:
i = [1; 0];
j = [0; 1];

% body frame: direction from center of quadrotor to rotor one
a = cos(q1) * i + sin(q1) * j;

% body frame: direction of positive thrust
b = -sin(q1) * i + cos(q1) * j;

% pendulum frame: direction along pendulum, starting at joint
c = -cos(q2) * j + sin(q2) * i;

% state and derivative:
z = [x; y; q1; q2; 
     dx; dy; dq1; dq2];
dz = [dx; dy; dq1; dq2;  
      ddx; ddy; ddq1; ddq2];

% take the symbolic derivative of any expresssion (chain rule)
derivative = @(expr)( jacobian(expr, z) * dz );

% position vectors
p0 = x*i + y*j;  % position of the center of the quadrotor
p1 = p0 + w * a / 2;  % position of rotor one
p2 = p0 - w * a / 2;  % position of rotor two
p3 = p0 + l * c / 2;  % position of center of mass of the pendulum
p4 = p0 + l * c;  % position of tip of the pendulum

% velocity and acceleration of the interesting points:
dp0 = derivative(p0);
dp1 = derivative(p1);
dp2 = derivative(p2);
dp3 = derivative(p3);
dp4 = derivative(p4);
ddp0 = derivative(dp0);
ddp1 = derivative(dp1);
ddp2 = derivative(dp2);
ddp3 = derivative(dp3);
ddp4 = derivative(dp4);

% cross product for two dimensions: dot(k, A X B)
cross2d = @(a, b)( a(1) * b(2) - a(2) * b(1) );

% angular momentum balance for entire system about p0
eqn1_torques = ... % no terms for disturbance and weight acting at p0
    cross2d(p1-p0, u1*b) +  ...  % rotor one thrust
    cross2d(p2-p0, u2*b);  % rotor two thrust
    cross2d(p3-p0, -m2 * g * j);  % mass of pendulum
eqn1_inertia = ...
    m1*w*w*ddq1/12  + ...  % moment of inertia of a thin rod about cener
    m2*l*l*ddq2/3;  % moment of inertia of a thin rod about end

% linear momentum balance for entire system
eqn2_forces = ...
    ux * i + uy * j + ... % disturbance forces
    u1 * b + u2 * b + ... % thrust force
    -m1 * g * j + ...  % weight of the quadrotor
    -m2 * g * j;  % weight of the pendulum
eqn2_inertia = ...
    m1 * ddp0 + ... quadrotor CoM acceleration
    m2 * ddp3; % pendulum CoM acceleration

% angular momentum balance for pendulum about p0
eqn3_torques = uq;  % control torque on pendulum from quadrotor
eqn3_inertia = ...
    m2*l*l*ddq2/3;  % moment of inertia of a thin rod about end

% solve equations of motion:
vars = [ddx; ddy; ddq1; ddq2];
eqns = simplify([eqn1_torques - eqn1_inertia;  
                 eqn2_forces - eqn2_inertia; 
                 eqn3_torques - eqn3_inertia]);
soln = solve(eqns, vars);

% Solve the linearized dynamics:  (assumes zero disturbance)
% --> note: gravity drops out (not coupled to state or control)
soln.dz = subs(dz, soln);
soln.A = jacobian(soln.dz, z);
soln.B = jacobian(soln.dz, [u1; u2; uq; ux; uy;]);  

% For visualization: thrust vectors
thrustScale = 8 * m1 * g * w;  % nominal arrow length
p1v = p1 - (u1 / thrustScale) * b;
p2v = p2 - (u2 / thrustScale) * b;

% Write the dynamics function (equations of motion)
matlabFunction(soln.ddx, soln.ddy, soln.ddq1, soln.ddq2, ...
               'File', 'autoGen_quadrotorPendulumDynamics.m', ...
               'Outputs', {'ddx','ddy','ddq1','ddq2'}, ...
               'Optimize', true, ...
               'Vars',{'q1','q2', 'dq2', ...
                       'u1', 'u2', 'uq', 'ux', 'uy', ...
                       'm1', 'w', 'g', 'm2', 'l'});
                         
% Write the linearized dynamics function (equations of motion)
matlabFunction(soln.A, soln.B, ...
               'File', 'autoGen_quadrotorPendulumLinDyn.m', ...
               'Outputs', {'A','B'}, ...
               'Optimize', true, ...
               'Vars',{'q1','q2', 'dq2', ...
                       'u1', 'u2', 'uq', ...
                       'm1', 'w', 'm2', 'l'});
                   
% Write the kinematics function (for visualization)
matlabFunction(p0, p1, p2, p3, p4, p1v, p2v, ...
               'File', 'autoGen_quadrotorPendulumKinematics.m', ...
               'Outputs', {'p0', 'p1', 'p2', 'p3', 'p4', 'p1v', 'p2v'}, ...
               'Optimize', true, ...
               'Vars',{'x','y', 'q1','q2', ...
                       'u1', 'u2', ...
                       'm1', 'w', 'g', 'l'});
             
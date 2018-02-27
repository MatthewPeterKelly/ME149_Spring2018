function dz = projectileDynamics(z, param)
% dz = projectileDynamics(z, param)
%
% Computes the dynamics of a projectile in 3D, acted on by both gravity
% and quadratic drag. There is a constant wind velocity.
%
% INPUTS:
%   z = [6, n] = [x1;x2;x3;  dx1; dx2; dx3] = state vector
%   param = parameter struct
%       .gravity = scalar = gravity constant
%       .wind = [3,1] = [w1; w2; w3] = wind velocitypwd
%       .drag = scalar = quadratic drag constant
%
% OUTPUTS:
%   dz = [6, n] = [dx1; dx2; dx3;  ddx1; ddx2; ddx3] = state derivative vector
%

% Compute the velocity of the projectile with respect to the wind:
% vRel = vel - wind;
nTime = size(z, 2);
onesRow = ones(1, nTime);
vAbs = z(4:6, :);  % velocity of the projectile (inertial reference frame)
vRel = vAbs - param.wind * onesRow;  % proj. velocity (wind ref. frame)

% Compute the speed of the projectile with respect to the wind:
% sRel = ||vRel||
sRel = sqrt(sum(vRel.^2, 1));  % size(sRel) == [1, nTime]

% Compute the drag force acting on the projectile:
% fDrag = -D * ||vRel|| * vRel
onesCol = ones(3, 1);  % 3 = number of dimensions
fDrag = -param.drag * (onesCol * sRel) .* vRel;

% Gravity force acting on the projectile:
% F = -mass * gravity * verticalDirection
fGravity = -param.mass * param.gravity * ([0; 0; 1] * onesRow);

% accel = force / mass
accel = (fDrag + fGravity) / param.mass;

% Pack up and return the derivative:
dz = [z(4:6); accel];

end

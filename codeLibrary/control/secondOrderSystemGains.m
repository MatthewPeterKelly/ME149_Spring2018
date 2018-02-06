function [Kp, Kd] = secondOrderSystemGains(wn, xi, m)
% [Kp, Kd] = secondOrderSystemGains(wn, xi, m)
%
% Given the second-order system:
%     m * ddx = F
%
% Compute the gains Kp and Kd such that the system behaves like:
%     ddx + (2*xi*wn)*dx + (wn^2)*x = 0
%     F = Kp * x + Kd * dx
%
% INPUTS:
%   wn = scalar = undamped natural frequency
%   xi = scalar = damping ratio
%       xi = 0       -->  no damping (Kd = 0)
%       0 < xi < 1   -->  under-damped
%       xi = 1       -->  critical damping
%       1 < xi       -->  overdamped 
%   m = scalar = system inertia = optional (default is one)
%
% OUTPUTS:
%   Kp = scalar = proportional gain
%   Kd = scalar = derivative gain
%
% NOTES:
%   x(t) = measured(t) - reference(t)
%

if nargin < 3
    m = 1.0;
end

Kp = -m * wn * wn;
Kd = -2 * m * wn * xi;

end

function hoverController = getHoverController(xRef, yRef, param)
% hoverController = getHoverController(xRef, yRef, param)
%
% This function designs a controller that will allow the quadrotor to
% hover at a fixed position, despite the presence of various disturbances.
% The linear controller gains are designed using infinite-horizon LQR
%
% INPUTS:
%   xRef = scalar = horizontal position for the hover
%   yRef = scalar = vertical position for the hover
%   param = struct with constant scalar parameters:
%       .m = mass of the quadrotor
%       .w = distance between the rotors (width)
%       .g = gravity acceleration
% OUTPUTS:
%   hoverController = function handle:  u = hoverController(z)
%       IN: z = [6, n] = [x; y; q; dx; dy; dq] = state
%             x = horizontal position
%             y = vertical position
%             q = absolute angle (zero for hover)
%             dx = time-derivative of horizontal position
%             dy = time-derivative of vertical position
%             dq = time-derivative of absolute angle (zero for hover)
%       OUT: u = [2, n] = [u1; u2] = control
%             u1 = left rotor force
%             u2 = right rotor force
%
% NOTES:
%   The nominal system dynamics for the quadrotor are defined in:
%
%        ME149/codeLibrary/modelSystems/planarQuadrotor/
%

%%%% TODO: %%%%
%
% Design a linear controller that stabilizes a hover. Useful functions:
%
% lqr()
% planarQuadrotorHoverThrust()
% planarQuadrotorLinDyn()

% Return a handle to the controller.
TODO = 'replace this placeholder with a useful set of parameters';
hoverController = @(z)( planarQuadrotorHoverController(z, TODO ) );

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function u = planarQuadrotorHoverController(z, TODO )
%
% TODO: documentation for this function
% TODO: additional arguments
% TODO: implement this function
%
end

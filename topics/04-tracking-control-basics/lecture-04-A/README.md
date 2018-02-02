# Lecture - Linear Tracking Control

## Follow-up:
- cover accuracy vs step size plot for different integration schemes

## Block move example: PD control
- move a point-mass from an initial position `x0` to the origin
- live Matlab demo
- start with a proportional controller
  - block overshoots!
- add a derivative term
  - after tuning, hit the target nicely
- how to select gains in a principled way?
  - pole placement!
    - set damping ratio to 1
    - set wn to ... fast?

## Block move example: PD control failure
- what happens when `x0` becomes large?
  - actuation effort becomes large
    - problem if we have actuator limits
- trade-off:
  - if the actuators have limits, then a controller is tied to a length scale!
    - if perturbation is too large, then saturate motors
    - if perturbation is too small the friction terms dominate
- what happens when we saturate the actuators?
  - Matlab demo!
  - behavior changes
    - design (pole-placement) assumed no saturation
  - this is especially bad for non-linear systems

## Block move example:  reference trajectory
-  linear controllers are not designed to move a system between two points
  - they are fundamentally regulators: keep a system near a desired target
- to move a system, simply move the reference and the controller will follow
- cubic reference trajectory
  - how did I compute this?
    - simplest thing that satisfies the boundary conditions
    - it also happens to minimize integral of acceleration squared
- compare the results:
  - start with tracking position reference only
  - now add velocity reference
  - finally, add feed-forward actuator term

## Splines:  piecewise polynomial functions
- common examples: linear, cubic
- can be done for any order polynomial
  - in some cases the order can be different on each segment
- Hermite Polynomial:
  - polynomial that is fully defined in terms of its boundary conditions
    - eg. cubic hermite: defined by position and velocity at boundaries

## Feed-forward actuation terms
- point-mass system:
  - feed-forward actuation is just the acceleration
- what about for non-linear systems?
  - trajectory optimization!
  - feed-froward torques can also be computed from inverse dynamics
    - given kinematics, find forces and torques
    - easy for fully-actuated systems
    - hard for under-actuated systems (next week)

## Pendulum example
- linear controller for inverted balance
  - good for small angles about stabilization point
  - fails for non-stationary points or for large angles
- linear control is improved with feed-forward terms
- adding a reference trajectory helps even more!

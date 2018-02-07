# Lecture - Nonlinear Tracking Control

## HW 3 notes
- if doing the butcher table:
  - there is a good list of methods on wikipedia:
    - https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods
    - https://en.wikipedia.org/wiki/List_of_Runge%E2%80%93Kutta_methods
- any other questions?

## HW 2 graded
- please read through your comments on Trunk

## Spline details
- cubic hermite spline
  - position and velocity at each knot
  - continuous position and velocity
- natural cubic spline through points
  - acceleration is zero at boundaries
  - continuous position, velocity, and acceleration
  - position at each knot
- clamped cubic spline through points
  - velocity is given at boundaries
  - continuous position, velocity, and acceleration
  - position at each knot
- DEMO:
  - comparison of different splines

## Consistent reference trajectory
- usually we want consistent references (for analytic reference trajectories)
  - `vRef = timeDerivative(xRef)`
  - `aRef = timeDerivative(vRef)`
- exception to this rule: numerical derivatives
  - `vRef = finiteDifference(xRef);   % usually ok, but look out for issues`
  - `vRef = finiteDifference(vRef);   % this is getting risky`
    - consider setting `vRef = 0`
  - `aRef = finiteDifference(finiteDifference(xRef));   % bad idea`
    - set `aRef = 0`
- why?
  - Think of each successive derivative as giving a higher-order correction
    term in the feed-forward torques. Position is the most important, then
    velocity, and finally acceleration. The inverse dynamics are often
    sensitive to the acceleration terms, so you only want to include them if
    they are known to be correct (without noise).
- physical meaning of each term:
  - position: typically compensates for gravity and any passive springs
  - velocity: typically compensates for coriolis terms in dynamics
    - sometimes also compensates for back-EMF in motor and damping terms in dynamics
  - acceleration: provide nominal effort required to change momentum (inertia terms)
    - controller usually can do a good job of handling this

## Spline derivatives in matlab:
- use `ME149/codeLibrary/splines/ppDer` to analytically differentiate a spline
  - this is slightly faster than differentiating each segment using `polyder`
- can use Matlab `polyder` function for an individual polynomial (or spline segment)
- code it yourself: use rules from basic calculus

## Fitting spline to data:  supplemental topic
- In class I mentioned that you can fit splines to data.
  This is perhaps one of the simplest types of trajectory optimization.
- I've included a full tutorial paper on the course website:
  `ME149/supplement/fit-spline-to-data/spline_fitting_tutorial.pdf`
- There is also a Matlab implementation in the code library:
  `ME149/codeLibrary/splines/fitSplineToData.m`

## Inverse Dynamics:
- given `xRef`, `vRef`, `aRef` compute `uRef`
  - given position, velocity, and acceleration, compute feed-forward actuation
- easy to compute if the system is fully actuated: has one actuator per degree of freedom
  - assuming that each actuator is sufficiently powerful and not at joint limits
  - example: pendulum, robot arm with a motor at each joint
- hard if the system is has too many or too few actuators
  - too few actuators: under-actuated
    - sometimes there is no solution
      - example: quadrotor helicopter attempting to move sideways
    - other issues
      - cannot accelerate faster if actuator is already at effort limit
      - cannot accelerate joint through a hard stop
  - too many actuators: no unique solution: "four-legged chair problem"
    - solve with optimization or by adding an extra constraint
    - often resolve unique solution by minimize the actuator effort squared
      - sometimes fancier optimizations are used as well
- for this lecture: assume that system is fully actuated

## Computing the inverse dynamics:
- set up the same system of equations as with the forward dynamics
- solve for actuator effort and treat the acceleration as a given
  - forward dynamics treats the effort as given and finds the accelerations
- both the simple pendulum and double pendulum examples in the code library
  implement inverse dynamics functions.

## Controller design: simple PD trajectory-tracking controller
- `u = uRef + Kp * (x - xRef) + Kd * (v - vRef)`
- Notes:
- `xRef` = position reference trajectory
- `vRef` = velocity reference trajectory
- `uRef` = feed-forward torque term: computed from inverse dynamics
- `Kp` = proportional gain
  - can be constant (for simple system)
    - use nominal effective mass to set the gains
  - can be model-based
    - linearize the system about the reference trajectory and then solve the
      pole-place equations at each time step to compute time-varying gains
    - solve the gains using the `lqr` command at each time-step. This works
      for most systems, but is technically not correct. This is because the `lqr`
      command in Matlab solves the time-invariant LQR: it is valid for stead-state solutions only.
    - solve the time-varying LQR equation. This requires a bit of work: you need
      to propagate the solution to the matrix ricatti equation backwards in time.
      Email me or come to office hours for more details, or check out these references:
        - Matlab implementation:
        https://www.mathworks.com/matlabcentral/fileexchange/54432-continuous-time--finite-horizon-lqr
        - Math details by Russ Tedrake: (see section 3.3)
        http://groups.csail.mit.edu/robotics-center/public_papers/Tedrake10.pdf
    - There are many other methods as well.

## Path integral cost functions
- Objective function that is of the form:
- `J(z(t), u(t)) = integral(g(tau, z(tau), u(tau))) --- domain: [0, T], WRT tau`
  - Notice that `J()` is a *functional*: it is a function that accepts a *function* as an argument
  - `J()` is a scalar functional: it evaluates to a single real number.
- Many different forms for the integrand `g()`
  - one common example is "effort-squared"
    - `g(t, z, u) = u^2`
- Notice similarity between `g()` and the dynamics function `f()`:
  - `z(k+1) = z(k) + integral(f(tau, z(tau), u(tau))) --- domain: [0, T], WRT tau`
  - You can evaluate `J()` using the same simulation function that you used to compute the solution to the dynamics!
  - In Matlab it is often faster to evaluate the objective function and the dynamics function at the same time
    - this is done by creating a combined function: `[f(); g()]` which is then passed to the simulator
- When used inside of a trajectory optimization, it is important that the differential equations for the cost function and the system dynamics are solved using the exact same method and step size.
  - When not used inside of a trajectory optimization, it is possible to evaluate the integral cost function using any standard quadrature method. This assumes that you are given the reference trajectory.

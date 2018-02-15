# Lecture 05-A:  more tracking control

## Logistics
- GitHub Repo:  make sure to pull the most recent version
- Lecture notes and the assignment have both been updated

## HW 4 - notes
- second-order system gains
  - how to use mass parameter for the pendulum??
  - see feedback linearization below
- Second-order systems: detailed notes (MIT open course)
  - https://ocw.mit.edu/courses/mechanical-engineering/2-003-modeling-dynamics-and-control-i-spring-2005/readings/notesinstalment2.pdf

## Matlab Demo:  tracking control continued
- include inverse dynamics in tracking controller
- evaluate integral cost function

## Spline numerical stability and efficiency
- See Numerical Recipes in C:
  - Section 3.1: polynomial interpolation
  - Section 3.3: cubic spline interpolation
- We use different splines for position, velocity, and acceleration so that
  we can use Matlab's evaluation code and keep things readable.
    - it is much more efficient to evaluate the value and derivatives of the
      spline at the same time.

## Underactuated systems:
  - Wikipedia gives a clear and concise definition:
    - "An underactuated system is a mechanical system that cannot follow arbitrary trajectories in configuration space"
    - https://en.wikipedia.org/wiki/Underactuation
  - For more details, see the MIT open-course notes:
    - https://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-832-underactuated-robotics-spring-2009/readings/MIT6_832s09_read_ch01.pdf


## NONHOLONOMIC vs UNDER ACTUATED   (by Andy Ruina)
```
Both have to do with one space being smaller than another.
One is about velocitites vs configurations the other about
actuators vs velocities.

In general one is interested in systems like this

\dot x  =  f(x,t) + u.   (n equations)

    x = state
    u = controls

In this first-order context, I don’t know what either of the words mean.

As best I know and understand, both of these ideas are generally applied to
second order systems like this:

\dot x = g(x,t) * v         (n  equations)
\dot v = f(x,v,t)  + u    (m  equations)

    x + v = state ( n +m )
    x = configuration (n)
    v = generalized velocity  (m)
    u = controls  (j independent ones of them)

In a non-holonomic system, after constraints have been applied, n>m.
In an underactuated system,   j < m.  More strictly: velocity space not spanned by actuators.

The phrase ‘non-holonomic constraint’ means a constraint on a system
like this that reduces the dimension of the velocity space more than the
configuration space.

Simple examples:

- A robot arm that has more joints than motors is underactuated.
- A chaplygen sleigh (American grocery cart), no matter how it is actuated, is non-holonomic.
```

## Hierarchical control:
- nested controllers
  - typically operating on different time scales
  - example: motor control
    - outer (slow) loop:
      - state: position
      - control: torque
    - inner (fast) loop:
      - state: current (--> torque via motor model)
      - control: voltage (or PWM signal)

## How to control a quadrotor helicoper?
- hierarchical control
  - fast inner loop regulates orientation
    - state: roll and pitch (and rates)
    - control: net torque about roll and pitch axis
  - slow outer loop regulates position (and yaw)
    - state: cartesian position and yaw (and rates)
    - control: net force, net torque (about yaw axis), roll, and pitch
  - references: look up papers by Vijay Kuman at U-Penn
    - http://www-personal.acfr.usyd.edu.au/spns/cdm/papers/Mellinger.pdf
  - also lots of good papers out of the Autonomous Systems Lab at ETH Zurich
    - http://flyingmachinearena.org/wp-content/publications/2013/breIEEE13.pdf

## Hybrid-Zero Dynamics: fancy way to control underactuated bipedal walking:
- Jesse Grizzle @ U. Michigan:
  - https://repository.upenn.edu/cgi/viewcontent.cgi?referer=&httpsredir=1&article=1124&amp;context=ese_papers

## Types of error:
- Modeling error
- Sensing and estimation error
- Actuation and control error

## ODE45 Event-Detection
- see "Bouncing Ball Tutorial"
  - https://github.com/MatthewPeterKelly/Bouncing_Ball_Matlab
- ode45 checks for events, and then uses root-finding to place a grid point
  exactly at the time when the event occurs.

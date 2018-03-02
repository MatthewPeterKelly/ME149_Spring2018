# Lecture 07-A

This lecture is an introduction to single shooting.

## Announcements:
- Piazza!
  - the course now has a piazza page
  - used for questions, answers, and announcements
- HW 05 due tonight at 11:55pm
- HW 06 due tomorrow at 11:55pm
- HW 07 posted

## Background reading:
Trajectory Optimization, A Brief Introduction:  (slides 1-21)
https://movement.osu.edu/software/DW2010/TrajOptim_ManojSrinivasan2010.pdf
- this presentation is a brief overview of trajectory optimization
- the author (Manoj Srinivasan) was the person that introduced me to these concepts 6 years ago
- good high-level overview

Chapter three in Bett's Book (Practical Methods for Optimal Control)
- http://epubs.siam.org/doi/book/10.1137/1.9780898718577
- Sections 3.1 - 3.3
- good introduction, somewhat more technical

## Outline for today:
- Boundary value problems
- Trajectory optimization
- Function approximation
- Transcription
- Constrained parameter optimization
- Single shooting
- canon example

## Boundary Value Problem
- initial value problem
  - simulation!  This was what we did in the entire first unit
- final value problem
  - simulation backwards!  This is easy, if a bit confusing.
- boundary value problem
  - this is a bit harder:  differential-algebraic equation (DAE)
    - similar to simulation, but there is a big non-linear constraint

## in Matlab
- bvp4c:  solve boundary value problem
- fsolve:  multi-dimensional unconstrained root solver
- fminsearch:  multi-dimensional unconstrained optimization

## How to solve boundary value problem?
- many methods, we'll start with single shooting
- draw canon example

## Trajectory Optimization
- trajectory, informal definition:
  - path that a system takes through state space
- can represent a trajectory with:
  - initial state
  - control as a function of time
  - system dynamics
  - construct state by solving initial value problem
- more common (numerically) to solve both state and control as functions of time
  - typically need the state as a function of time to compute the control functions
- optimal trajectory, informal trajectory
  - the best path that they system can take through the state space
- big picture: we want to compute the optimal trajectory:
  - states as functions of time
  - controls as functions of time
- problem: how can we do optimization over functions?

## Trajectory Optimization: general formulation
- objective function
  - integral term
  - boundary terms
- system dynamics
- path constraints
- boundary constraints

## Function approximation
- functions are infinite dimensional
  - need the value at every point in time
  - infinitely many times on every time domain
- function approximation
  - approximate a function using some finite set of parameters
  - many different methods
  - requires assumptions about the form of the function
    - eg. cannot make good approximation of white noise using a sine curve
- trajectory optimization:
  - usually assume that trajectories are smooth
    - or at least piece-wise smooth.
    - this can cause major problem later on
      - minimize energy: bang-bang controller: not smooth
    - more on edge cases later
  - assuming that trajectories are smooth... use splines
    - details of about the spline are method dependent

## Transcription:
- convert:
  - from: optimization over a set of functions
  - to: optimization over a finite set of real numbers
- motivation:
  - we know how to optimize a vector of real numbers
  - we do not now how to optimize over arbitrary functions
- key idea:
  - use function approximation to replace functions with a set of parameters
  - usually implemented with polynomial splines
- what about calculus?
  - most trajectory optimization includes calculus-based constraint:
    - system dynamics
    - integral objective function (or constraint)
  - calculus operates on functions, not finite sets of parameters
  - integrals and derivatives become algebraic expressions
- big picture:
  - convert a trajectory optimization problem
    - decision variables are functions
    - includes integrals and derivatives
  - into a constrained parameter optimization
    - decision variables are a finite set of real numbers
    - contains only algebraic expressions

## Constrained optimization
- Linear Program
  - linear objective, linear constraints
  - `linprog` in Matlab
- Quadratic Program
  - quadratic objective, linear constraints
  - `quadprog` in Matlab
- Nonlinear Program
  - nonlinear objective, nonlinear constraints
  - `FMINCON` in Matlab

## Back to earth:  single shooting
- transcription method:
  - single explicit simulation
    - decision variables:
      - initial state
      - control along trajectory
    - constraints:
      - use the output of the simulation
    - transcription:
      - simulation satisfies the dynamics by definition
      - use simulation to compute integral objective function
      - constraints apply at grid points in the simulation
- pros
- cons
- choice of grid and integration method
- do not use ode45 for transcription!

## Misc:
- never use an iterative solver or variable step method (eg. ode45) in an optimization!

## Nonlinear Programming Solver:  FMINCON
- Options for FMINCON
  - https://www.mathworks.com/help/optim/ug/choosing-the-algorithm.html#bsbwxm7
-documentation for FMINCON:
- https://www.mathworks.com/help/optim/ug/fmincon.html

## Alternative solvers:
- IPOPT  (free and good)
- SNOPT  ($$$$ and very good)

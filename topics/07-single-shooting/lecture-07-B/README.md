# Lecture 07-B:  Single Shooting & BVP solvers

This lecture reviews and expands on our study of single shooting methods.

## Background reading:  (same as last time)
Trajectory Optimization, A Brief Introduction:  (slides 1-21)
https://movement.osu.edu/software/DW2010/TrajOptim_ManojSrinivasan2010.pdf
- this presentation is a brief overview of trajectory optimization
- the author (Manoj Srinivasan) was the person that introduced me to these concepts 6 years ago
- good high-level overview

Chapter three in Bett's Book (Practical Methods for Optimal Control)
- http://epubs.siam.org/doi/book/10.1137/1.9780898718577
- Sections 3.1 - 3.3
- good introduction, somewhat more technical

## Homework update:
  - initial guess - doesn't matter here
  - matters a lot on future problems

## Simple Boundary value problem
- review from last week
- problem statement:
  - given first-order non-linear system dynamics
  - constraint on the partial state at two different times
    - in contrast with an initial value problem, which has constraint on the full state at a single time.
- all methods will eventually...
  - solve a system of nonlinear equations (ie. root solve)

## Boundary Value problem with optimization
- boundary value problem, but constraints to not define a unique solution
- use optimization to define a unique solution
- canon example
  - given initial and final position
  - family of solutions (parameterized by energy)
  - minimize energy to obtain a unique solution
- all methods will eventually...
  - solve a nonlinear constrained parameter optimization
- similar to trajectory optimization... but there is no "control"

## Boundary value problem with control and optimization
- special case of trajectory optimization
- problem statement:
  - system dynamics
  - boundary constraints (some combination of the following)
    - boundary constraint can include state or time
      - not control
    - applied at the initial and/or final time
    - equality or inequality
      - limits:    x1 < 2   ;   x2 = 3
      - linear:  x1 + x2  < 3  ;  x3 + x1 = 2
      - nonlinear:   g(x1, x2) < 0  ; h(x4, x5) = 2
    - typically need at least one boundary constraint
        - probably could construct an example without one
  - objective function:
    - path objective: integral applied along entire trajectory
      - can include both state and control
    - boundary objective: applied at boundaries only
      - in terms of state and boundary times
      - no control
- many solution methods. Let's start with single shooting.

## What is "control" in the context of trajectory optimization?
- See Betts, chapter 3-4
- dx = f(t, x, u)
  - state: x  -->  derivatives of x show up in the equations
    - x is a differential equation variable
  - control: u  -->  no derivatives of u show up in the equations
    - u is an algebraic variable

## Single shooting for BVP with objective function, Euler's method
- start with Euler's method, we'll work up to other methods
- Decision variables:
  - full state at the initial time
  - control at the start of each segment
    - no control at final point: it wouldn't show up in the optimization!
    - control is piece-wise constant
      - derive this from the integration method itself...
      - control is approximated the same as the dynamics
  - initial and final times (optional)
- functions to implement:
  - integrand of the path objective
    - J = integral(w)
    - function that returns w
    - integrand is computed using euler's method
      - typically at the same time as the dynamics

## Example problem:
- pendulum swing-up with minimum torque in fixed time
- given initial and final time and state
- find control as a function of time

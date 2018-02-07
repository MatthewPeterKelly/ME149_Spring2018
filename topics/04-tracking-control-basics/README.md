# Topic 04: Tracking Control Basics

This topic will introduce the basics of tracking controllers:
using a PD controller with time-varying references for position, velocity, and feed-forward actuation.
We will only consider systems for which the inverse dynamics are well behaved.

## Lecture 04A:
- review of PD controllers
- one-dimension block moving problem
  - PD control with fixed reference
  - PD control with time-varying reference trajectory
  - Matlab demo in class
- introduction to polynomial splines

## Lecture 04B:
- review of splines
  - Matlab demo for spline construction
- derivatives of splines, consistent derivatives
- review of inverse dynamics
- introduction to path objective functions

## Homework:
- construct a swing-up reference trajectory for a single and double pendulum
- design a simple trajectory tracking controller
- compute the integral of torque-squared along your reference trajectory
- simulate the resulting closed-loop system

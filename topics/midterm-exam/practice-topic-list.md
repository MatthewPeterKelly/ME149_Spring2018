# Midterm Exam Practice:

This document contains a collection of practice problems that will be useful in
studying for the midterm. Questions from the exam will largely be taken from
this set, with minor modifications.

## Pure Matlab:

Code style:
- https://github.com/MatthewPeterKelly/ME149_Spring2018/blob/master/supplement/common_matlab_issues.md
- I'll give you some poorly written Matlab code
  - You'll need to find at least N issues with the code and suggest improvements
  - a few examples:
    - hard-coded variables
    - duplicated code
    - confusingly named things
    - reusing variables for different types
    - things in a for loop that should be vectorized

Human debugger:
- I will give you some Matlab code that has several errors in it
  - You'll need to find at least N errors and implement a fix

Function handles:
- I'll give some snippets of Matlab code with function handles
  - you'll have to predict the output of the code snippet

## Pure Calculus:

Taylor Series:
 - be able to compute Taylor series up to second order
 - for scalar and vector functions
 - for single and multi-variate functions

Partial derivatives:
- be able to compute the partial derivatives of a dynamics function
  - this is the "A" and "B" matrix in the dynamics
- I will likely give you an example problem like the one that I did out on the board
  - eg. compute the A and B matrix for a simple dynamical system

## Dynamical Systems:

You don't need to know dynamics, but it would be good to be familiar with the
simple systems that we have used so far in class. I will likely introduce at
least one new system on the exam. I will stick to systems that have a reasonable
number of states and controls, and which have relatively simple dynamics equations.

## Controls:

PD-controllers:
- play with the damping ratio and natural frequency of the controller on this website
  - http://www.matthewpeterkelly.com/tutorials/pdControl/index.html
  - (aside: if you look in the javascript you can find 4th-order runge-kutta!)
- know the difference between under-, critically-, and over-damped systems
  - be able to draw a plot of all three
  - be able to classify a controller based on the plot
  - given gains and a resulting plot, be able to suggest a change to produce a desired behavior
    - eg. plot shows an under-damped system: how to reduce overshoot? increase derivative gain or increase damping term.

LQR:
- basic concepts
- know what the ricatti equation is, but you do not need to memorize it
- know what Q and R cost matricies are, and conceptually what they do
- difference between infinite horizon and finite horizon


## Scalar Root Solvers

General concepts:
- what are the trade-offs between the various methods?
- in what situations will method * be likely to fail?

Bracketed methods:
- bisection search
- false position
- Ridder's method (concept only, will not need update equation)
- Brent's method (concept only, will not need update equation)

Unbounded methods:
- newton's method
- secant method

For any of the methods above:
- given a plot of a function, graphically depict a few iterations
- given an analytic function, perform a few iterations on a calculator
  - scalar function, not ridder's or brent's method
- given partial matlab code, be able to fill in the missing lines
- discuss concepts and trade-offs

## Scalar Optimization:

General concepts:
- what are the trade-offs between the various methods?
- in what situations will method * be likely to fail?

Bracketed methods:
- golden section
- brent's method (concept only, will not need update equation)

For any of the methods above:
- given a plot of a function, graphically depict a few iterations
- given an analytic function, perform a few iterations on a calculator
  - scalar function, not brent's method
- given partial matlab code, be able to fill in the missing lines
- discuss concepts and trade-offs

## Runge-Kutta Simulation (Initial value problem)

General concepts:
- trade-offs between methods
- order vs accuracy plots (and general trends)
- basic idea behind derivation

Methods:
- Euler
- Midpoint
- Heun's
- second-order general Runge Kutta (concept only, will not need update equation)
- The forth-order Runge Kutta method   (concept only, will not need update equation)

For any of the above methods:
- perform a single step using a calculator
- fill-in-the-blank Matlab code
- discuss concepts and trade-offs

## Trajectory Optimization

General concepts:
- what is a decision variable?
- what is a constraint?
- what is an objective function?
- what is the difference between a state and a control variable?

Boundary value problem
- how is it different from an initial value problem
- basic concepts: how to solve

fmincon
- given a nonlinear program
  - eg. minimize x*y + z*2 subject to x + z = y^2
- implement the objective and constraint functions
- fill-in-the-blank matlab code

shooting methods:
- single vs multiple shooting
- understand ideas behind gradient calculations
  - will not need to the an entire derivation
  - might need to do one or two of the intermediate steps
    - eg. make sure that you know the chain rule!
    - but don't go nuts trying to memorize the entire derivation

transcription:
- given a continuous-time trajectory optimizaiton problem,
- transcribe it to a non-linear program using Euler's method,
- either single or multiple shooting.
  - eg. go from an intergral cost function to a summation
  - eg. continuous control function to a set of decision variables
  

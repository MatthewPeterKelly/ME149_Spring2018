# Lecture 06-A: scalar optimization and root finding

## Reading:
- Practical Methods for Optimal Control... John T. Betts, 2010
  - Sections 1.1 - 1.4
- Numerical Recipes in C, Press et. al.
  - Chapter 9, sections 9.0-9.4

## Newton's method for scalar root finding    (Newton--Raphson)
- solve: `c(x) = 0`   (constraint function)
- method:
    - linearize the function at current point
    - compute root for linear model
    - update current point and iterate  
- update:
  - `xNext = xPrev - c(xPrev) / dc(xPrev)`
- features:
  - quadratic convergence (!)
  - not guaranteed to converge
  - complete failure when slope is zero
    - poorly behaved when slope is very small
  - requires the slope of the function

## Secant method for scalar root finding
- same idea as Newton's method, but no need for analytic slope
- estimate linear model using current and previous point
- features:
  - superlinear convergence
    - better than linear, typically worse than quadratic
  - requires initial guess and initial step size
  - similar convergence issues when compared to Newton's method

## Newton's method for scalar optimization
- minimize: `f(x)`  (objective function)
- derivation:
  - second-order taylor expansion at current point
  - take derivative of the second-order model
    - result: linear model for slope
  - compute where the slope is zero
  - check that the curvature is positive
- update:
  - `xNext = xPrev - dc(xPrev) / ddc(xPrev)`
- features:
  - all the same as newton's method for root finding
  - need to compute both the slope and the curvature!

## Robust root finding: bracketing methods
- a root is bracketed when we have two points where the function changes sign
- if the root is bracketed, and the function is continuous, then we can guarentee convergence.
- how to bracket a root?
  - many different heuristic approaches
  - best to use problem-specific knowledge if available
  - see Numerical Recipes in C, chapter 9
- several common methods:  (in order of complexity)
  - bisection search
  - false-position (regula-falsi) search
  - Ridder's method
  - Van Winjngaarden-Dekker-Brent
- interesting concepts:
  - combined methods:
    - use Newton--Raphson when converging, then switch to bisection if iteration jumps out of the bracket
    - use Newton--Raphson to refine a root that was located using another method

## Aside: Motivation for bracketing: Fracals and Newton--Raphson
- Newton's method does not necessarily converge to the closest root
  - for some functions the result is chaotic
  - eg. solve:  `z^3 - 1 = 0`  in the complex plane

## Bisection Search:
- start with bracketed root
- evaluate middle of the bracket
- update whichever root matches the sign of the middle point
- features:
  - constant convergence rate: does not depend on the function
  - good for poorly-behaved functions
  - convergence is slower than gradient-based methods

## False-Position Search:
- combination of the secant method and bisection search
- method
  - start with bracketed root
  - fit a linear model between the edges of the bracket
  - next guess is at the root of the linear model
  - update whichever bracket edge matches the new point

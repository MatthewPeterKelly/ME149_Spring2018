# Lecture 06-A:  Introduction to Scalar Optimization

## HW 05 Corrections and updates:
- typo in documentation for function:
  - `xRef, vRef` should be `xRef, yRef` in getHoverController
- function and variable naming alias
  - cannot have both a variable and function with same name
- correct version is now on GitHub
- due date and time: Tuesday 11:55 pm
  - next assignment is due at the regular time

## Homework Logistics:
- homework is a big part of the grade
  - better to submit an incomplete assignment than to submit late
  - I will give partial credit for incomplete assignments
- lots of people have been asking for extensions and submitting late
  - new policy:
    - up to 12 hours late is -5 points
      - no extensions granted without two weeks notice or extenuating circumstances
    - homework (starting with HW 06) due at Midnight (11:55pm) on Wednesday
      - rather than 6PM on Tuesday

## Lecture Outline:
- Scalar methods continued:
  - Ridder's method for root finding
  - golden section search (optimization)
  - Overview of HW 06
- Fancy scalar methods:
  - Brent's method for root finding
  - Brent's method for optimization
- Introduction to constrained optimization
  - linear program
  - quadratic program
  - nonlinear program

## Ridder's method:
- Numerical Recipes in C, Section 9.2
- Fancy method for smooth bracketed root solving
- Iteration Outline:
  - known bracket: xLow, fLow, xUpp, fUpp
  - evaluate midpoint:
    - `xMid = 0.5 * (xLow + xUpp)`
    - `fMid = f(xMid)`
  - fancy update based on fitting an exponential
    - compute:  `s = sqrt(fMid*fMid - fLow*fUpp);`
    - if s is zero (smaller than fTol) return
    - compute: `xDel = (xMid - xLow) * fMid / s;`
    - `xNew = xMid + sign(fLow) * xDel`
    - `fNew = f(xNew)`
    - check convergence
    - update bracket
      - need to update one or both edges of the bracket
      - compares signs of `fLow, fMid, fNew, fUpp`
      - three cases (see numerical recipes)
  - These notes are just an outline:  see text for details!

## Golden Section Search:
- Numerical Recipes in C, Section 10.1
- Robust method for minimization on a bounded interval
- Key ideas:
  - need three points to bracket a minimum
  - similar to bisection search in concept
  - efficiency: match scale factor for every iteration
    - this is where the golden section comes from
- Features:
  - guaranteed to converge
  - slow convergence (no model)
    - bracket contraction ratio: (0.618...)^N
- Initialization:
  - `R = 2 / (1 + sqrt(5));  % inverse golden ratio`
  - `C = 1 - R;`
  - select two intermediate points, one at fraction R, the other at C
- Iteration:
  - select the smaller of the two interior points
  - contract the bracket towards that point
  - sample a new point from the larger of the two remaining intervals
    - use R and C to write new point in terms of sub-interval boundaries
- These notes are just an outline:  see text for details!

## HW 6:
- Easy assignment compared to previous two
- Implement Ridder's method and golden section search in Matlab

## Fancy Root finding:  Brent's method
- Background:
  - Bisection is robust but slow
  - model-based methods (eg. Regula Falsi and Ridders method) are:
    - usually very fast
    - occasionally converge very slow for pathological problems
  - goal: model-based method normally, but revert to bisection if not working well
- Method:
  - Inverse quadratic interpolation by default
  - Bisection when interpolation fails
- Inverse Quadratic Interpolation:
  - Fit a quadratic function through three points: `f(x) = a*x^2 + b*x + c`
  - Compute the input `x` such that `y` is the desired value (zero in this case)
    - inverse: find x given y, rather than y given x
- Ideas:
  - fit a quadratic function to the current bracket
    - second-order model: fast convergence
  - situations where failure occurs:
    - divide by zero: interpolation failure
    - root is projected out of the bracket
    - fancy method converging slower than bisection
  - if inverse quadratic interpolation fails, then revert to bisection
- Matlab `fzero` command is in two parts:
  - find the bracket (if not given)
    - expansion and contraction search, Numerical Recipes in C section 9.1
  - find root within the bracket: Brent's method

## Fancy Optimization:  Brent's method
- Background:
  - golden section search is robust but slow
  - higher-order models are easily fooled or hit pathological cases
  - goal: combine robust and fancy method, switching between when appropriate
- Method:
  - fit a quadratic through the a few previous points
  - compute next guess point to be the minimum of the parabola
  - if quadratic model fails (numerical issues or jumps the bracket)
    - then use golden section search
- this lives inside of the Matlab command `fminbnd`
- book-keeping is tricky: keep track of six points!
  - this is needed for efficiency: only one function evaluation per iteration.


## Constrained Optimization: Introduction
- three common types:
  - linear program
  - quadratic program
  - nonlinear program
- sparse considerations
- general discussion (more formal next week)

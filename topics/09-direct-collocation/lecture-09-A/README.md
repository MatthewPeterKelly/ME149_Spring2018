# Lecture 09-A

## Exams:
- graded
- return at end of class
- solutions posted

# Implementation details!

## HW 08:
- due tomorrow!
- multiple shooting
- stay for office hours today if you need help
- I'll answer questions on Piazza

## Reference:
- Most of the content from this lecture is from existing tutorials that I wrote:
  - paper: https://epubs.siam.org/doi/pdf/10.1137/16M1062569
  - video: https://www.youtube.com/watch?v=wlkRYMVUZTs&t=605s
  - slides: http://www.matthewpeterkelly.com/tutorials/trajectoryOptimization/cartPoleCollocation.svg
  - tutorial page:http://www.matthewpeterkelly.com/tutorials/trajectoryOptimization/
- Most of that knowledge in turn comes either from:
  - Practical Methods for Optimal Control... by John T. Betts
  - the papers that I reference in the above tutorial paper
  - practical experience writing trajectory optimization code

## Initialization Routines:
- multiple shooting and otherwise
- motivation
- how good do they need to be?
- based on problem specific data where possible

## Is my solution correct?
- Sources of error:
  - nlp constraint feasibility
  - integration accuracy
  - nlp optimality
  - quadrature accuracy
  - global vs local minimum
- How to check if your method gets the "correct" answer?
  - difficult (impossible) to do in general
    - cannot check global optimality
  - we CAN check two things:
    - feasibility
    - local optimality
- Feasibility:
  - use error estimates associated with integration method
    - both local and global error estimates
  - use high-accuracy forward simulation of open-loop control
    - verify that state trajectory is similar
  - limited by NLP solver constraint tolerance...
  - also strongly affected by constraint scaling
- Optimality:
  - heuristics:
    - is the solution smooth? should it be smooth?
    - does it look reasonable?
    - can you think of an obvious trajectory that is better?
    - can another objective function find a solution that has a lower cost for your objective? (this is bad if so)
  - MATH:  check the necessary and sufficient conditions...
    - brief intro: indirect methods...

## Intro to direct collocation!
- big picture:
  - multiple shooting:  approximate dynamics using simulation
  - collocation: approximate dynamics using splines

## Classification of Methods
- Rules of Thumb (guidelines, not strict in a mathematical sense)
- explicit integration: shooting method
- implicit integration: collocation method
- see slide 8 of the tutorial above for more details

## Trapezoid Rule:
- simple case: compute the area under a curve
- transcription:
  - how to discretize a dynamics function?
  - implicit integration?!

## Function approximation
- how to interpolate between knot points?
  - use method consistent interpolation!
  - linear interpolation is not acceptable, particularily for high-order methods
- each transcription method defines it's own interpolating spline
  - this is true for most methods
  - sometimes there is not a unique interpolating spline... The 4th-order Runge--Kutta method is an example: it evaluates the dynamics twice at the same time grid point. Need to be more clever here.
  - all of the collocation methods that we will study have a unique interpolating spline.

## How to get this all coded up?
- write helper methods to "pack" and "unpack" the decision variables
  - this will save you lots of debugging time and make your code readable

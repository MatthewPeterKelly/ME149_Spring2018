# Lecture 09-B

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

## From Piazza:
- does the order of decision variables matter?
  - no - just do something reasonable and be consistent

## Review: mini-quiz:
- Transcribe the following trajectoy optimization problem into a non-linear program using trapezoid direct collocation
  - minimize path integral of g(t, x, u)
  - subject to boundary constraint function h(x(0), x(T))
  - subject to system dynamics dx = f(t, x, u)
- Then go over the solution on the board

## Questions:
- What parts did you miss on the quiz?
- what is unclear on the homework?

## New topic: boundary times are unknown
- start with initial mesh

## New topic: is my solution correct?
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

## Error analysis:
- how accurate is my solution?
- many methods - we will use the one from Bett's book
  - check for the consistency of the interpolating spline
- consistency estimate:
  - compute the integral of the absolute difference between the derivative of the spline and the dynamics along the spline.
  - this integral gives you an estimate of how far off each state could be
- how to compute that integral?
  - adaptive quadrature
    - matlab integral() command
  - rhomberg quadrature
  - quadrature error must be significantly smaller than the error that you are estimating.
  - need to be careful with adaptive methods, because the absolute value term in the error integral causes a discontinuous function.
    - very high-order smooth methods (like Gauss quadrature) will not be as accurate as they predict due to this discontinuity

## Coding suggestions:
- write helper methods to "pack" and "unpack" the decision variables
  - this will save you lots of debugging time and make your code readable
- identify objective terms and constraint terms
- create sub-functions as necessary
- vectorize your code

## Final project:
- last few minutes of class
- go to outline in final project folder
    -

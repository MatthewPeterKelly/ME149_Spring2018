# Lecture 11-D:  Error Analysis

## References:
- Betts' book
- my tutorial paper

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

# Lecture 05 - A:  Advanced Tracking Controllers

This lecture will focus on providing a working overview of Linear Quadratic Regulators, more generally known as LQR. We will apply these controllers to two situations:
1) Stabilizing a fixed-point in the state-space
2) Stabilizing a trajectory

## LQR - Technical References:
- **Applied Optimal Control**
    - Bryson & Ho, 1975
    - Chapter 5
    - Detailed overview of derivation and application to trajectory optimization:
- **LQR-Trees: Feedback Motion Planning via Sums-of-Squared Verification**
  - Good overview of LQR for both regulators and trajectory tracking
  - Russ Tedrake, Ian Manchester, Mark Tobenkin, John W. Roberts
  - 2010  (there is also a 2009 version in RSS, but the 2010 version has more information about LQR and is better organized)
  - Section 3.1 and 3.3 (don't worry about verification sub-sections)
  - http://groups.csail.mit.edu/robotics-center/public_papers/Tedrake10.pdf

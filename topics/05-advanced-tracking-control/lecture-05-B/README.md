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
  - **Section 3.1 and 3.3** (don't worry about verification sub-sections)
  - http://groups.csail.mit.edu/robotics-center/public_papers/Tedrake10.pdf
- **Underactuated Robotics:**
  - http://underactuated.csail.mit.edu/underactuated.html?chapter=lqr

## A trick for setting the LQR terminal cost:
The finite-horizon (trajectory) LQR method requires a terminal cost.
In some cases selecting an arbitrary terminal cost will cause the gains to
diverge at the end of the trajectory. A simple fix is to set the terminal cost
to zero, but that effectively turns off the controller at the end of the trajectory.

If the final point on the trajectory is a fixed point, such as a hovering pose
for a quadrotor, then you can use infinite-horizon LQR to set the terminal cost.
To do this, just solve the infinite-horizon LQR problem starting with the final
point on the reference trajectory. Once this is done, then you set the terminal
cost of the finite-horizon LQR to be the cost-to-go matrix
for the infinite horizon LQR. This works well and has a physical interpretation:
it is solving the finite-horizon tracking problem assuming that the control will
be turned over to an infinite-horizon LQR controller at the end of the trajectory.

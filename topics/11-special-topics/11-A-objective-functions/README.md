# Special Topics:  Objective Functions (and some other things)

## Logistics:
- Proposals are due tonight!
  - basically what we discussed on Thursday + any comments that I made

## References
- my tutorial paper
- Bett's book, chapter 1 (what can go wrong), chapter 6 (examples)

## Minimum-time
- hard! but very useful.
  - solutions are usually discontinuous because control switches on an off of a limit
  - mesh analysis and remeshing is typically important

## Minimum-control-rate
- really useful!
- reformulate the system:
  - old control becomes a state:  state = [x;u]
  - old control rate becomes the new control:  control = [du]

## Minimum-jerk
- easy for kinematic systems.
- if using real (second-order) dynamics, often better to minimize control rate instead

## Working with tabulated data:
- never extrapolate
- linear interpolation is often a bad idea
  - causes a discontinuous gradient in functions
- select interpolation that has as many continuous derivatives as are required
  by your transcription and optimization.
  - typically second-order continuity is required, so cubic interpolation works
- cubic spline interpolation has its own issues:
  - can introduce "wiggles" in the data
- how to really do it right?
  - use trajectory optimization to fit a smooth interpolant to the data that
    minimizes the curvature while providing a good fit to the data and
    using a second-order continuous fuction approximation. Then use this trajectory
    (or surface...) rather than evaluating the tabulated data directly.

## Minimax:
- minimize the maximum value of a component of the trajectory
- implementation:
  - treat the upper bound on a path constraint to be a decision variable,
    then minimize the upper bound

## Minimum-work  (working with absolute value functions)
- this is usually hard: there is usually an absolute value term in the objective
  - abs() is discontinuous, which makes optimization hard
- there are two ways to deal with the abs() function
  - using fancy constraint transformation (Betts, chapter 1)
  - using smoothing (see tutorial paper)

## Minimum-time exact solution for constant limits
- tricky: all points on active path constraints
- question: which constraint is active?
- start with velocity limited only..
- then add acceleration...
- then add jerk limits

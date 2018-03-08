# HW 07 Solution:  write-up

## Question 1
*How does varying
the number of grid points and simulation method affect
the number of iterations, solve time and final accuracy of the NLP?*
- Grid points:
  - more grid points = more accurate, longer solve, more accuracy
- Simulation method:
  - higher-order = more accurate, longer solve, more accuracy
- Which is better? More grid points or higher order?
  - if the solution is smooth, then it is much better to increase the order of the method
  - if the solution is discontinuous, then better to increase the number of grid points
  - reference: Anil Rao et al:  HP adaptive meshing
    - http://www.anilvrao.com/Publications/JournalPublications/LiuHagerRao-JFI-October-2015.pdf
    - GPOPS-II optimization code for Matlab
    - many other papers
  - Also discussed in John Betts book:
    - Practical Methods for Optimal Control...

## Question 2
*How does the solution change if you vary the drag parameter?*
- As the drag becomes large the dynamics become very stiff along the optimal solution
  - this is because of the extremely large initial speed requirement to reach the goal
  - this cases the fixed-step integration method to have large numerical errors
  - the optimal solution looks like a triangle in the limit of very large drag
- how to solve anyway?
  - use non-uniform grid, with more grid points early in the trajectory
  - there are likely analytic tricks to transform the still problem into a less stiff one
  - iterative solve using progressively larger drag and remeshing between each solve

## Question 3
*How many function calls does FMINCON make on each iteration?*
- It depends on how many decision variables you have and how gradients are computed
- The exact number per iteration may change depending on how the solver updates the gradient and if there are any convergence issues.
- The number of function evaluations is more than one per iteration because FMINCON is using numerical finite differences.
- If you used analytic gradients then it would usually call the function once per iteration.

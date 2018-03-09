# Lecture 08-A

## Homework Comments:  Quadrotor control
- HW 05 is graded
  - please read comments!!
  - lots of coding issues
    - see document
- code style:
  - DO NOT USE THE FIND FUNCTION ON DOUBLE VECTORS
  - do not submit homework code that has any warnings in it
    - if there is a warning... FIX IT
  - if your code is slow... then there is probably a bug
    - assignment in this class are set up to be "nice"
- lots of people had very stiff controllers
  - torques are huge!
- unit tests: 4 points total: only checked crashes

## References:
- **Underactuated Robotics Lectures:**
  - http://underactuated.csail.mit.edu/underactuated.html?chapter=trajopt
  - https://people.eecs.berkeley.edu/~pabbeel/cs287-fa09/readings/Tedrake-Aug09.pdf

## Looking ahead...
- this week: multiple shooting
  - homework delayed until after the midterm
  - will be multiple-shooting optimal pendulum swing-up
- review assignment: posted thursday
- next Tuesday: review for the midterm
  - come to class with questions!!!
- next Thursday: in-class midterm

## How do I practice multiple shooting before the exam?
- try to do the HW 07 using multiple shooting instead of single shooting
- HW 08 will be computing a minimal-torque swing-up for the simple pendulum

## Single Shooting: What can go wrong?
- difficult to find initial guess
- numerically sensitive to the initial guess
  - especially problematic because finding the guess is harder
- not very robust

## What makes single shooting difficult?
- Gradients.
  - "tail wagging the dog"
  - example:
    - final boundary constraint:
      - depends on every single decision variable
      - gradient is highly sensitive to
  - a small change early in the simulation propagates through everything

## How to compute gradients?
- hand-written notes

## how to do multiple steps?
- Each step is compute in terms of the previous...
  - back-propagation

## Multiple shooting
- is how to fix single shooting.
- break simulation into make pieces
- initial condition of each simulation is a decision variable
- add a constraint that the final point on each simulation is the initial point of the next
- taking things to the limit:
  - each simulation is a single integration step

## Why does multiple shooting help?
- two key reasons:
  - the gradient becomes sparse
  - the gradient is "more linear"
- gradient is effectively a coupling matrix between the constraints and the decision variables
  - a sparse matrix has few non-zero entries:
    - each constraint is only related to a few decision variables
- more linear?
  - shorter segments of simulation: less can happen over shorter time for a given system

## How many substeps?
- one or more sub-steps between defects
- usually just use one integration step per defect

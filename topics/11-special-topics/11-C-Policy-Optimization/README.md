# Lecture 11-C:  Policy optimization

## Logistics:
- Please fill out course evaluations!
- Survey for content in a future version of this course.
- Projects
  - write out the mathematical formulation for your problems!
    - needed for report, needed for debugging, needed for understanding
    - what are the constraints?
    - what is the objective?

## Error analysis review
- Look at tutorial paper, section 5.3
https://epubs.siam.org/doi/pdf/10.1137/16M1062569
- Also Bett's Book
- Implementation example: OptimTraj Library
https://github.com/MatthewPeterKelly/OptimTraj
  - look at `trapezoid` and `hermiteSimpson` function files.
    - soln.interp.collCst ==  continuoue collocation error function
    - soln.info.error == error in each segment

## Multi-phase review

## References:

Matlab Demo:
https://github.com/MatthewPeterKelly/MDP_Pendulum

Andrew Ng (Stanford) course notes on MDP:
http://cs229.stanford.edu/notes/cs229-notes12.pdf

Russ Tedrake (MIT) course notes on value iteration and function approximation:  (ch 9, 10)
https://homes.cs.washington.edu/~todorov/courses/amath579/Tedrake_notes.pdf

Wikipedia:  (for the mathematically inclined...)
https://en.wikipedia.org/wiki/Bellman_equation

## Outline:

- POLICY:  a mapping from an arbitrary state to a control
  - optimal policy: the policy that produces the "optimal" control starting from all possible states over an infinite horizon. Approximate definition - not mathematical.

- Hard to compute the optimal policy:
  - how to represent a mapping from EVERY state?
  - how to pick the best control? There are many controls?

- big picture ideas:
  - construct a "value" function that describes how good every state is, assuming that the optimal control is taken from every state.
  - the policy is then the "control" that achieves the most improvement in the value function from the current state.
  - now we have just moved the problem down a level:  how to construct a value function?

- Value function vs reward function vs objective function:
  - A value function is how "good" a state is, provided that the behavior of the system is perfectly optimal.
  - A reward function is local, similar to an objective function. It describes how good a current state is, independent of the control. It is typically used to initialize the value function. A typical reward function might include a large reward at the goal state, zero reward in most states, and a penalty (negative reward) for failure states (eg. robot fell down).
  - Actions (controls) can also have rewards associated with them.

- How is this done in practice?  Function approximation. Examples:
  - directed graphs (eg. google maps)
  - neural networks (eg. deep learning)
  - discretize on grid, then interpolate (eg. Matlab demo, simple examples)
  - K-Nearest-Neighbors (non-grid interpolation scheme)
  - any other function approximation for mapping N to M dimensions

- What is approximated?   
  - the value function  (state --> value)
  - the policy  (state --> action)
    - action == control

- Bellman Equation:
  - the equation that the value function needs to satisfy
  - a way to define the value function

- Value iteration:
  - one of the key algorithms for computing the value function
  - start with value == reward
  - compute the optimal policy given the value function
  - execute the optimal policy and measure the value
  - update the value function
  - iterate.

- Policy optimization:
  - a slightly less popular algorithm for finding the optimal policy (and value function)
  - similar to value iteration, but flips the order

- Markov Decision process:
  - a popular way to model systems to allow for discretization
  - Markov property: the state encodes all relevant information about the system
    - history is irrelevant
  - framework for constructing and solving policy optimization problems

- Simple example of Markov Decision process:

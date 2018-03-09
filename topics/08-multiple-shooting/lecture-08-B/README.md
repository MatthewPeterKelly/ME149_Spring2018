# Lecture 08-B:  multiple shooting

## Homework 06 notes:
- golden sections search: most students were close
- Ridder's method: some students code sort of looked right
- big picture things:
  - if counting evaluations, put the counter right next to the function calls
    - do not modify the count otherwise
  - do not evaluate the same point on multiple iterations
- remember to look at the solutions!
  - run the unit test to see if you can make your code pass
- had to grade much faster than previous assignments

## HW 07 notes:
- generally good: most students passed the unit test
- do not print out inside of a function
  - this is for the test code to do

## Late homework:
- if submitting late homework, then ok to look at solutions
  - motivation for grade structure
    - grade structure assumes that you've read the solutions
  - how I grade late homework
- if there is a posted unit test
  - make sure that your code runs
    - include output of the test

## Midterm exam updates:
- will be calculator only
- will post example questions ASAP
  - some tonight
  - the rest by tomorrow night

## Today:
- finish derivation from last time
  - explain chain rule carefully
- gradients discussion
- multiple shooting - concepts
- multiple shooting - transcription
- multiple shooting - gradients
- shooting methods overview

## Single Shooting Gradients: continued
- start with general case, carefully do chain rule
- explain exactly what a partial derivative does
- do calculation for cost function
- talk about how they are both recursive

## Gradients discussion
- how to implement these complicated equations?
  - simulate forward propagate cost and gradients backwards
- aside: automatic differentiation
- numerical gradients
  - pro: super easy to code up
  - con: how to pick step size?
  - con: lots of extra evaluations
  - con: more stability issues
  - con: problem scaling
- analytic gradients
  - con: hard to implement
  - pro: often faster, better stability
  - usually compute gradients of dynamics with auto diff

## Multiple Shooting:
- pretty picture on the board
- same trajectory optimization as last week
- transcribe using euler's method dense multiple shooting
- show how much easier it is to compute the gradients
- talk about gradient sparsity

## Classification of shooting methods:
- sliding scale from single to multiple shooting
  - single shooting: on segment, many subs-steps
  - "dense" multiple shooting: many segments, one sub-step
  - general multuple shooting: several segments, several sub-steps
- trade-offs between methods?
  - multiple shooting: accuracy of dynaics is limited by constraint tolerance on the root solve
  - single shooting: accuracy of the dynamics is limits by integration accuracy
  - single shooting: very likely to have convergence trouble
  - multiple shooting: quite robust to convergence issues

## Advanced topic:
- error analysis: cover in depth next week
- non-uniform mesh

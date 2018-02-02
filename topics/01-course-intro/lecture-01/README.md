# Optimal Control for Robotics - Lecture 01:  Introduction and Overview

## Introduction: who am I?
- Matt Kelly ([website](http://www.matthewpeterkelly.com/))
- Undergrad at Tufts - mechanical engineering - dynamical systems and control
- M.S. and Ph.D at Cornell - mechanical engineering  (robotics)
  - concentration in dynamical systems and control
  - minor in computer science
  - worked on the Cornell Ranger bipedal walking robot ([video](https://www.youtube.com/watch?v=BL334UZvKSE))
- Currently work as robotics engineer at Rethink Robotics ([video](https://www.youtube.com/watch?v=DSy-NXSldz0))
  - focus on trajectory generation, motion planning, and high-level control

## Introduction: who are the students?
- Poll: What type of student?   {junior, senior, master, phd... }
  - roughly 2/3 graduate students, 1/3 undergraduate students
- Poll: What major?   {ME, ECE, CS, ...}
  - roughly 2/3 mechanical engineering majors

## Introduction: optimal control for robotics
- question to students: what is a robot?
  - a system that can "sense - think - act"
- question to students: what is control?
  - the "think" part of the system  (in vague terms)
- question to students: what is optimal control?
  - a controller that minimizes some cost function: achieves a desired behavior
- path planning example
  - how do you choose which path to walk between two points?
  - optimal policy vs optimal trajectory
    - policy: which direction to walk from every possible location
    - trajectory: exact instructions to walk between the two points

## Optimal control: policy optimization
- compute the best action from every possible state to achieve goal
  - what is a state?
  - what is an action?
- examples:
  - path planning (eg. robot navigating between rooms)
- related topics:
  - Hamilton-Jacobi-Bellman (HJB) equation
  - markov decision process (value and policy iteration)
  - deep learning
  - reinforcement learning
- pro: works for highly complex systems, globally optimal in many cases
- con: difficult for high-dimensional systems: *curse of dimensionality*

## Optimal control: trajectory optimization
- compute a sequence of actions to achieve a specific sequence of states
- solves the same equations as policy optimization, but only along a single trajectory
- works well for high-dimensional continuous dynamical systems:
  - robot arms
  - legged robots
  - aircraft
  - satellites
- related topics:
  - model-predictive control
  - Linear Quadratic Regulator (LQR) controllers
- examples:
  - how to swing your leg to achieve the correct foot placement on the next step
  - best rocket thrust profile to get into orbit
  - fastest way to move a robot arm between two points
- pro: obtain accurate solutions for high-dimensional continuous systems
- con: locally optimal solution (cannot guarantee global optimality)
- **ME149 will focus on trajectory optimization**

## Course objectives:
- final goal is to implement the following:
  - generate an optimal trajectory for an interesting system
  - design a trajectory tracking controller
  - simulate the closed-loop system as it executes the trajectory
- a few things that you will learn:
  - programming skills
  - simulation
  - control
  - optimization
  - trajectory optimization

## Review the syllabus:
- course website (discuss in detail later)
- office hours
- scheduling conflicts, honor policy, style
- grading
- homework!
  - schedule
  - grading
  - team work
- resources
- lecture outline:
  - part one: simulation, control, optimization
  - part two: trajectory optimization

## In-class Polls: learn about the student technical background
- Who has taken a basic controls class?
  - most of the class
- Who has taken an advanced controls class?
  - a few students
- Who has taken numerical methods?
  - a few students
- Who has taken dynamics?
- Who has taken a CS programming course?
- What operating system do you primarily use?  {windows, mac, linux}
- Who has heard of git and GitHub? Do you know how to use git?
  - about 2/3 of students have heard of GitHub, about 1/3 have used git

## Discuss the course website (on GitHub)
- Content for the course will be hosted on GitHub
- Why?
  - easy to coordinate many files
  - easy to upload and download
  - used for virtually all large robotics projects
- How to get files from GitHub?
  - simple: click "download zip" on ME149 main page
  - suggested: download GitHub Desktop and clone the repo (see tutorial)
  - advanced: download git directly and use command line (see tutorial / come to office hours)
- How will the repo be used?
  - new content will be uploaded throughout the semester:
    - lecture notes
    - demos
    - assignments
    - solutions
    - tutorials

## Notes about website:
- What are the `*.md` files?
  - These are Markdown files, a simple language that standardizes formatting for text files.
  - GitHub will automatically display markdown pages as a formatted webpage.
  - Markdown files are easy to read, whether or not you know the syntax.
- what are the `*.tex` files?
  - These are LaTeX source files, and are used to generate pdf documents.
  - LaTeX is a commonly used launguage for generating scientific reports and papers.

## Learning programming skills
In this course will focus on programming skills in addition to optimal control. Why?
- good programming skills make writing complex programs possible
- any technical career in robotics will require good programming skills

## Discuss HW 1
- motivation
  - Matlab and basic calculus refresher
- download from: [ME149 GitHub Page](https://github.com/MatthewPeterKelly/ME149_Spring2018)
- grading - roughly based on the following:
  - did you follow directions?
  - was your code readable?
  - did you do the math right?

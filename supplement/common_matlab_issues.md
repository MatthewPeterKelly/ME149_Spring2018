# Common Matlab Issues (and how to fix them)

This document contains a running list of common Matlab issues,
along with why they cause problems and how to fix them.

## Matlab has warnings in your code

The Matlab development environment is helpful: it will give you warnings
whenever you try to do something bad. It does this by placing an orange
squiggle under your code and a small orange line on the right side of the
editor window.

If you see a warning in your code then you should fix it.
If you don't know how to fix it, then read the help documentation,
ask someone for help, or read about it on the internet.

If there is a warning, and you completely understand it, and have a good reason
for doing something that Matlab does not like, then suppress the warning.
This tells people reading your code that you did a strange thing on purpose.

## Non-vectorized code

Matlab provides good support for code vectorization.
This allows for Matlab to run batch calculations at a low level, rather than
running the interpreter on every line of code. This results in a dramatic
speed improvement, and sometimes makes your code easier to read.

There are some places where vectorization is easy,
such as multiplying every element in a vector by a number.
In these cases failure to vectorize the code should be considered an error.

There other places where vectorization is hard.
It might be possible, but it would require writing confusing code or
allocation huge matrices. In these situations it is up to the developer:
use the profiler to check that the vectorized code is actually faster.
If it is close, then decide if the confusion added by vectorization is worth it.

There are some situations where vectorization is not possible.
The most common is when each iteration of a loop requires the result of the
calculation on the previous iteration.

## Functions should support vector arguments

This makes them compatible with other vectorized code.
It also makes your code more general purpose.

## Never use floating point equality comparison (unless you mean it)

In general, it is a bad idea to do floating point equality comparison in programming.
This is dangerous because of numerical precision errors. Matlab example:
```
a = pi; b = a;
a == b;  % true
a == (b + eps);  % true
sprintf('%25.25f', a - (b + eps));  % '0.0000000000000000000000000'
a == (b + 2 * eps);  % false
sprintf('%25.25f', a - (b + 2*eps));  % '-0.0000000000000004440892099'
```
The equality comparison is checking that all of the bits are the same.
Typically the numerical precision of any calculation is such that there are
a few bits of error.

Usually the goal is to check that the result of two calculations is within
some specified tolerance.
```
1 == sum(0.1*ones(10,1));  % false
abs(1 - sum(0.1*ones(10,1))) < 1e-14;  % true
```

## The find command is evil (usually)

There are several valid use cases for the Matlab find command,
such as finding non-zero elements, or checking for a matching index.

That being said, I've seen this function used incorrectly a huge number of times
and cannot remember a single instance of it being used correctly in student code.

Below is an example of one (of many) bad ways to use the find command.
Note that it relies on a floating point equality comparison, and that
Matlab issues a warning along with each of the below uses of the find command.
```
% Create a data set
nGrid = 10;
tGrid = linspace(0, 1, nGrid);
zGrid = rand(1, 10);

% How to correctly interpolate data:
t = rand(1);
z = interp1(tGrid, zGrid, t);  % Correctly interpolates data

% Terrible use of the find command:  student gets lucky
t = tGrid(3);
z = zGrid(find(tGrid==t));  % Input happens to match. Works.

% Terrible use of the find command:  student fails unit test
t = rand(1);
z = zGrid(find(tGrid==t));  % Input does not match. z is empty.
```

## Dynamic memory allocation in a loop

Matlab allows you to lazily allocate memory by indexing off the end of an array.
This is fine for small arrays, but a bad idea for larger arrays.
It is best practice to avoid it entirely, unless there is no way to know the
size of the array before entering the loop.
```
% Bad memory allocation and bad vectorization
for i=1:10
   a(i) = rand(1);
end

% Good memory allcoation and bad vectorization
b = zeros(1,10);
for i=1:length(b)
    b(i) = rand(1);
end

% Good memory allocation and good vectorization:
c = rand(1,10);
```

## Unused variables

The most common warning that I see in student code is for unused variables.
This seems harmless, but it can cause problems.
The major issue here is that unused variables can result from a mistake in the
program, where a variable was intended to be used, but then never was.
This also can show up in a correct function: in that case it just uses extra
resources needlessly.
It is good to fix these warnings every time so that you will catch the issue 
when it is an error in your code.

function prob_01_studentName()

disp('Hello World!  Let''s add two numbers together:');

a = 4;
b = 7;
c = addTwoNumbers(a, b);
fprintf('%d + %d = %d\n', a, b, c);

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function c = addTwoNumbers(a, b)
%
% This function adds the two inputs together:  c = a + b
%

c = a + b;

end

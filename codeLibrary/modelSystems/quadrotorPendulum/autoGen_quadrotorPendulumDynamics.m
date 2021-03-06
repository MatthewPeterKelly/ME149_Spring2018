function [ddx,ddy,ddq1,ddq2] = autoGen_quadrotorPendulumDynamics(q1,q2,dq2,u1,u2,uq,ux,uy,m1,w,g,m2,l)
%AUTOGEN_QUADROTORPENDULUMDYNAMICS
%    [DDX,DDY,DDQ1,DDQ2] = AUTOGEN_QUADROTORPENDULUMDYNAMICS(Q1,Q2,DQ2,U1,U2,UQ,UX,UY,M1,W,G,M2,L)

%    This function was generated by the Symbolic Math Toolbox version 7.2.
%    07-Apr-2018 12:42:38

t2 = sin(q1);
t3 = 1.0./l;
t4 = m1+m2;
t5 = 1.0./t4;
t6 = sin(q2);
t7 = cos(q1);
t8 = dq2.^2;
t9 = l.^2;
t10 = cos(q2);
ddx = t3.*t5.*(l.*ux.*-2.0+t10.*uq.*3.0+l.*t2.*u1.*2.0+l.*t2.*u2.*2.0-m2.*t6.*t8.*t9).*(-1.0./2.0);
if nargout > 1
    ddy = t3.*t5.*(l.*uy.*-2.0+t6.*uq.*3.0+g.*l.*m1.*2.0+g.*l.*m2.*2.0-l.*t7.*u1.*2.0-l.*t7.*u2.*2.0+m2.*t8.*t9.*t10).*(-1.0./2.0);
end
if nargout > 2
    ddq1 = (1.0./w.^2.*(uq.*2.0-u1.*w+u2.*w).*-6.0)./m1;
end
if nargout > 3
    ddq2 = (1.0./l.^2.*uq.*3.0)./m2;
end

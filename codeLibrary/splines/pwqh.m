function [ppx,ppv,ppa,ppj,pps] = pwqh(t,x,v,a)
% [ppx,ppv,ppa,ppj,pps] = pwqh(t,x,v,a)
%
% Computes a piecewise quintic spline. Similar syntax to Matlab's function
% pwch() for cubic splines. The user provides the position, velocity, and
% acceleration for a sequence
%
% INPUTS:
%   t = [1, nTime] = time vector
%   x = [nDim, nTime] = position
%   v = [nDim, nTime] = velocity
%   a = [nDim, nTime] = acceleration
%
% OUTPUTS:
%   ppx = quintic spline for x(t)
%   ppv = quartic spline for v(t) (derivative of x(t))
%   ppv = cubic spline for a(t) (derivative of v(t))
%

if nargin == 0  % Then run unit test
    pwqh_test();
    return;
end

[nDim, nTime] = size(x);
iL = 1:(nTime-1);
iU = 2:nTime;
xL = x(:,iL);
xU = x(:,iU);
dxL = v(:,iL);
dxU = v(:,iU);
ddxL = a(:,iL);
ddxU = a(:,iU);
h = ones(nDim,1)*diff(t);

% Computed symbolically using Python SymPy toolbox:
C0 = xL;
C1 = dxL;
C2 = ddxL/2;
C3 = -(3.*ddxL.*h.^2 - ddxU.*h.^2 + 12.*dxL.*h + 8.*dxU.*h + 20.*xL - 20.*xU)./(2.*h.^3);
C4 = (3.*ddxL.*h.^2./2 - ddxU.*h.^2 + 8.*dxL.*h + 7.*dxU.*h + 15.*xL - 15.*xU)./h.^4;
C5 = -(ddxL.*h.^2 - ddxU.*h.^2 + 6.*dxL.*h + 6.*dxU.*h + 12.*xL - 12.*xU)./(2.*h.^5);

% Reshape into Matlab's pp format:
nSeg = nTime - 1;
C = zeros(nSeg*nDim,6);
for iSeg=1:nSeg
    for iDim = 1:nDim
        k = nDim*(iSeg-1) + iDim;
        C(k,:) = [C5(iDim,iSeg), C4(iDim,iSeg), C3(iDim,iSeg), ...
            C2(iDim,iSeg), C1(iDim,iSeg), C0(iDim,iSeg)];
    end
end

% Pack up in standard pp form
ppx.form = 'pp';
ppx.breaks = t;
ppx.coefs = C;
ppx.pieces = nSeg;
ppx.order = 6;
ppx.dim = nDim;

% Compute derivatives if desired.
if nargout > 1
    ppv = ppDer(ppx);
end
if nargout > 2
    ppa = ppDer(ppv);
end
if nargout > 3
    ppj = ppDer(ppa);
end
if nargout > 4
    pps = ppDer(ppj);
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function dpp = ppDer(pp)
% dpp = ppDer(pp)
%
% Computes the derivative of a PP struct
%

n = pp.order;
nRows = size(pp.coefs,1);
dpp.form = pp.form;
dpp.breaks = pp.breaks;
dpp.coefs = zeros(nRows,n-1);
for i=1:n-1
   dpp.coefs(:,i) = (n-i)*pp.coefs(:,i);
end
dpp.pieces = pp.pieces;
dpp.order = pp.order-1;
dpp.dim = pp.dim;

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function pwqh_test()

nSeg = 5;  % number of spline segments

t = linspace(0, 7*pi,100);
xFun = @(t)( t.*sin(t) );
vFun = @(t)( sin(t) + t.*cos(t) );
aFun = @(t)( cos(t) - t.*sin(t) + cos(t));

xData = xFun(t);
vData = vFun(t);
aData = aFun(t);

tKey = linspace(t(1), t(end), nSeg + 1);
xKey = xFun(tKey);
vKey = vFun(tKey);
aKey = aFun(tKey);

[ppx,ppv,ppa] = pwqh(tKey,xKey,vKey,aKey);

x = ppval(ppx,t);
v = ppval(ppv,t);
a = ppval(ppa,t);

figure(253); clf;

h(1) = subplot(3,1,1); hold on;
plot(t,x,'k-','LineWidth',5);
plot(t,xData,'r-','LineWidth',2);
plot(tKey, xKey,'ro');
xlabel('time')
ylabel('position')

h(2) = subplot(3,1,2); hold on;
plot(t,v,'k-','LineWidth',5);
plot(t,vData,'r-','LineWidth',2);
plot(tKey, vKey,'ro');
xlabel('time')
ylabel('velocity')

h(3) = subplot(3,1,3); hold on;
plot(t,a,'k-','LineWidth',5);
plot(t,aData,'r-','LineWidth',2);
plot(tKey, aKey,'ro');
xlabel('time')
ylabel('acceleration')

linkaxes(h,'x');
end

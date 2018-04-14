% DEMO  --  Barycentric Interpolation of Orthogonal Polynomials
%
% 

clc; clear;
run('../../../codeLibrary/addLibraryToPath.m');
if ~checkForChebFun()
   error('This example required the ChebFun toolbox!'); 
end

%%%% Let's start by computing the Gauss-Legendre points:
N = 15;  % number of points 
domain = [0, 5];  % domain of the function
% X = collocation points
% W = quadrature weights
% V = interpolation weights
[X, W, V] = legpts(N, domain);

%%%% Compute the differentiation matrix:
D = orthDiffMat(X, V);

%%%% Pick a test function 
fInt = @(x)( x .* sin(2*x) );   % integral
fVal = @(x)( sin(2*x) + 2*x.*cos(2*x) );   % value
fDer = @(x)( 4*cos(2*x) - 4*x.*sin(2*x) );  % derivative

%%%% Evaluate the function at Gauss-Legendre points
F = fVal(X);
dF = D * F;  % differentiate by matrix multiply

%%%% Barycentric interpolation for fVal and fDer
x = linspace(domain(1), domain(2), 200);
f = bary(x, F, X, V);
df = bary(x, dF, X, V);

%%%% Gauss quadrature:
fIntSoln = fInt(domain(end)) - fInt(domain(1));
fIntGauss = W*F;
fprintf('Analytic integral: %6.6f  --  Gauss quadrature: %6.6f  --  Error:  %6.6e\n',...
        fIntSoln, fIntGauss, fIntSoln - fIntGauss);

%%%% Plot
figure(110010); clf;

subplot(2,1,1); hold on;
plot(x, fVal(x), 'k-', 'LineWidth', 2);
plot(X, F, 'ro', 'LineWidth', 2);
plot(x, f, 'r-', 'LineWidth', 2);
xlabel('x')
ylabel('fVal')
title('function')
legend('function','F','interpolant');

subplot(2,1,2); hold on;
plot(x, fDer(x), 'k-', 'LineWidth', 2);
plot(X, dF, 'ro', 'LineWidth', 2);
plot(x, df, 'r-', 'LineWidth', 2);
ylabel('fDer')
title('derivative')
legend('derivative','D*F','interpolant');
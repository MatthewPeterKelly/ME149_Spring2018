% DEMO  --  Spectral Convergence
%
% Plot the error in the function approximation as a function of grid points
%

% clc; clear;
if ~checkForChebFun()
    error('This example required the ChebFun toolbox!');
end

%%%% Number of points to sweep over
N = 2:50;

%%%% Pick a test function
domain = [-2, 5];  % domain of the function
fun = @(x)( sin(2*x) + 2*x.*cos(2*x) );
xTest = linspace(domain(1), domain(end), 1000);
fTest = fun(xTest);
fitErr = zeros(1,length(N));
for i = 1:length(N)
    % X = collocation points
    % W = quadrature weights
    % V = interpolation weights
    [X, W, V] = legpts(N(i), domain);
    
    %%%% Compute the differentiation matrix:
    D = orthDiffMat(X, V);
    
    %%%% Evaluate the function at Gauss-Legendre points
    F = fun(X);
    fBary = bary(xTest, F, X, V);
    fitErr(i) = max(abs(fTest - fBary));
end

%%%% Plot
figure(110020); clf;

subplot(1,2,1);
plot(N, abs(fitErr), 'ko')
set(gca,'YScale','log')
xlabel('number of points')
ylabel('max(abs(err))')
title('convergence of function approximation')

subplot(1,2,2);
plot(xTest, fTest,'LineWidth',2);
xlabel('x')
ylabel('f');
title('test function')
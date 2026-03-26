function [dP] = calcDP(t, P, Pdel, yPdel)
u = 0.01;
Gamma = 1174.17;
beta = 0.3095;
d = 3.9139*10^(-5);
eps = 0.0063;
gamma = 0.2;
dP = zeros(3,1);
N = P(1)+P(2)+P(3);
dP(1) = Gamma - beta*P(1)*P(2)/N - d*P(1) - u*Pdel(1,1);
dP(2) = beta*P(1)*P(2)/N - (gamma+d+eps)*P(2);
dP(3) = gamma*P(2) - d*P(3) + u*Pdel(1,1);
end
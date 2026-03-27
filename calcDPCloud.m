function [dP] = calcDPCloud(t, P, Pdel)
r = [.9 .7];
a = [10 20];
% Points to address: Larger N, let r vary, let a vary, boundaries at 0?
dP = zeros(2,1);
dP(1) = - r(1)*P(1) - (1-r(1))*P(1)*(P(1)-Pdel(2)) + (1-r(2))*Pdel(2)*(Pdel(2)-P(1))+a(1);
dP(2) = - r(2)*P(2) - (1-r(2))*P(2)*(P(2)-Pdel(1)) + (1-r(1))*Pdel(1)*(Pdel(1)-P(2))+a(2);
end
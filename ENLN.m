lag = 10;
a = 1.2;
%history = [30*10^(6); 30; 28];
history = @(t)1+2*sin(t);
%history = ncread("sst.mon.ltm.1981-2010.nc","sst");
%history = history(1,:);
options = odeset('NormControl','on','MaxStep',1);
%sol = ddensd(@(t,T,Tdel,Tpdel)(-a*Tdel+T-T^3), @(t,y)t, (@(t,y)t-lag), history,  [0,30], options);
sol = dde23(@(t,T,Tdel)(-a*Tdel+T-T^3), [lag], history, [0,30], options);
tn = linspace(0,30,2000);
yn = deval(sol, tn);
plot(tn,yn)
%arr = [1 0 1];
%arr = logical(arr);
%plot(tn,yn(arr,:));
%hold on
%figure
%plot(tn,yn(2,:))
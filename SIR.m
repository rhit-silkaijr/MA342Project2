lag = 10;
history = [30*10^(6); 30; 28];
options = odeset('NormControl','on','MaxStep',1);
sol = ddensd(@calcDP, @(t,y)t, (@(t,y)t-lag), history,  [0,180], options);
%dde23(@calcDP, [lag], history,  [0,180], options)
tn = linspace(0,180,500);
yn = deval(sol, tn);
%plot(tn,yn);
arr = [1 0 1];
arr = logical(arr);
plot(tn,yn(arr,:));
hold on
figure
plot(tn,yn(2,:))
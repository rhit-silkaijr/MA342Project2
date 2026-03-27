lag = 1;
history = [5 3];
options = odeset('NormControl','on','MaxStep',1);
sol = dde23(@calcDPCloud, [lag], history, [0,70], options);
tn = linspace(0,70,2000);
yn = deval(sol, tn);
plot(tn,yn)
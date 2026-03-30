function [t, X] = CloudModelSimple()
    maxTime = 100; % mystical time units
    tau = 2; % delay for information to travel in time units
    lags = [tau, 2*tau]; 
    history = [100; 10]; % starting point

    % define task inputs to the system
    t_data = 0:1:maxTime; 
    r1_data = 5*(sin(t_data)+1);
    r2_data = linspace(2, 10, length(t_data)); 
    
    sol = dde23(@(t,X,Xdel) calcDX(t, X, Xdel, t_data, r1_data, r2_data), lags, history, [0, maxTime]);
    
    % Plot results
    figure;
    subplot(2,1,1);
    hold on
    plot(sol.x, sol.y(1,:), 'b'); 
    plot(sol.x, sol.y(2,:), 'r');
    legend('C1 Load', 'C2 Load'); 
    
    subplot(2,1,2);
    plot(t_data, r1_data, 'b--', t_data, r2_data, 'r--');
    legend('C1 Input (r1)', 'C2 Input (r2)');
end

function dX = calcDX(t, X, Xdel, t_data, r1_data, r2_data)
    % interpolate for tasks into system at any given time
    r1 = interp1(t_data, r1_data, t);
    r2 = interp1(t_data, r2_data, t);
    
    c = [7; 7]; % rate each computer can complete tasks
    a = 0.4; % aggressiveness of sending tasks
    
    dX = zeros(2,1);
    
    % Computer 1
    work1 = min(X(1), c(1)); % tasks done per timestep, min of the amount of tasks it has
    send1to2 = max(0, round(a * 0.5 * (X(1) - Xdel(2,1)))); % try to average tasks on computers
    recv1from2 = max(0, round(a * 0.5 * (Xdel(2,1) - Xdel(1,2))));
    dX(1) = r1 - work1 - send1to2 + recv1from2;
    
    % Computer 2
    work2 = min(X(2), c(2)); % tasks done per timestep, min of the amount of tasks it has
    send2to1 = max(0, round(a * 0.5 * (X(2) - Xdel(1,1)))); % try to average tasks on computers
    recv2from1 = max(0, round(a * 0.5 * (Xdel(1,1) - Xdel(2,2))));
    dX(2) = r2 - work2 - send2to1 + recv2from1;
end
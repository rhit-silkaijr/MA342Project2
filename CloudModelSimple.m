function [t, X] = CloudModelSimple()
    maxTime = 100; % mystical time units
    tau = 2; % delay for information to travel in time units
    lags = [tau, 2*tau]; 
    history = [100; 10; 30]; % starting point

    % define task inputs to the system
    t_data = 0:1:maxTime; 
    numComputers = 3;

    r_data = zeros(4,maxTime+1);

    %Must manually input functions anyway, so don't factor in num_computers here
    r_data(1,:) = 5*(sin(t_data)+1);
    r_data(2,:) = linspace(2, 10, length(t_data)); 
    r_data(3,:) = 5*(cos(t_data)+1);
    
    sol = dde23(@(t,X,Xdel) calcDX(t, X, Xdel, t_data, r_data), lags, history, [0, maxTime]);
    
    % Plot results
    figure;
    subplot(2,1,1);
    hold on
    plot(sol.x, sol.y(1,:), 'b'); 
    plot(sol.x, sol.y(2,:), 'r');
    plot(sol.x, sol.y(3,:), 'g');
    legend('C1 Load', 'C2 Load', 'C3 Load'); 
    
    subplot(2,1,2);
    plot(t_data, r_data(1,:), 'b--', t_data, r_data(2,:), 'r--', t_data, r_data(3,:), 'g--');
    legend('C1 Input (r1)', 'C2 Input (r2)', 'C3 Input (r3)');
end

function dX = calcDX(t, X, Xdel, t_data, r_data)
    % interpolate for tasks into system at any given time
    r1 = interp1(t_data, r_data(1,:), t);
    r2 = interp1(t_data, r_data(2,:), t);
    r3 = interp1(t_data, r_data(3,:), t);
    
    r = [r1 r2 r3];
    c = [7; 7; 7]; % rate each computer can complete tasks
    a = 1; % aggressiveness of sending tasks
    
    dX = zeros(3,1);

    for i=1:length(dX)
        dX(i) = calcWork(c, X, Xdel, i, r, a);
    end
    
    % % Computer 1
    % work1 = min(X(1), c(1)); % tasks done per timestep, min of the amount of tasks it has
    % send1to2 = max(0, round(a * 0.5 * (X(1) - Xdel(2,1)))); % try to average tasks on computers
    % recv1from2 = max(0, round(a * 0.5 * (Xdel(2,1) - Xdel(1,2))));
    % dX(1) = r1 - work1 - send1to2 + recv1from2;
    % 
    % % Computer 2
    % work2 = min(X(2), c(2)); % tasks done per timestep, min of the amount of tasks it has
    % send2to1 = max(0, round(a * 0.5 * (X(2) - Xdel(1,1)))); % try to average tasks on computers
    % recv2from1 = max(0, round(a * 0.5 * (Xdel(1,1) - Xdel(2,2))));
    % dX(2) = r2 - work2 - send2to1 + recv2from1;
end

function calcWorkX = calcWork(c, X, Xdel, index, r, a)
    workX = min(X(index), c(index));
    if index ~= length(r)
        sendUp = max(0, round(a * 0.5 * (X(index) - Xdel(index+1,1)))); % try to average tasks on computers
    else
        sendUp = max(0, round(a * 0.5 * (X(index) - Xdel(1,1)))); % try to average tasks on computers
    end
    if index ~= 1
        recvDown = max(0, round(a * 0.5 * (Xdel(index-1,1) - Xdel(index,2))));
    else
        recvDown = max(0, round(a * 0.5 * (Xdel(length(r),1) - Xdel(index,2))));
    end
    calcWorkX = r(index) - workX - sendUp + recvDown;
end
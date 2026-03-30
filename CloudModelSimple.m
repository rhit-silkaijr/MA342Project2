function [t, X] = CloudModelSimple()
    maxTime = 100; % mystical time units
    tau = 2; % delay for information to travel in time units
    lags = [tau, 2*tau]; 

    % define task inputs to the system
    t_data = 0:1:maxTime; 
    numComputers = 4;

    r_data = zeros(numComputers,maxTime+1);

    %Must manually input functions anyway, so don't factor in num_computers here
    history = [100; 10; 30; 50]; % starting point
    r_data(1,:) = 5*(sin(t_data)+1);
    r_data(2,:) = linspace(2, 10, length(t_data)); 
    r_data(3,:) = 5*(cos(t_data)+1);
    r_data(4,:) = linspace(7, 2, length(t_data));
    
    sol = dde23(@(t,X,Xdel) calcDX(t, X, Xdel, t_data, r_data,numComputers), lags, history, [0, maxTime]);
    
    % Plot results
    figure;
    subplot(2,1,1);
    hold on
    for i=1:numComputers
        plot(sol.x, sol.y(i,:));
    end
    legend('C1 Load', 'C2 Load', 'C3 Load', 'C4 Load'); 
    
    subplot(2,1,2);
    hold on
    for i=1:numComputers
        plot(t_data, r_data(i,:));
    end
    legend('C1 Input (r1)', 'C2 Input (r2)', 'C3 Input (r3)', 'C4 Input (r4)');
end

function dX = calcDX(t, X, Xdel, t_data, r_data, numComputers)
    % interpolate for tasks into system at any given time

    r = zeros(numComputers,1);

    for i=1:numComputers
        r(i,:) = interp1(t_data, r_data(i,:), t);
    end

    %Manually input c for each computer
    c = [7; 7; 7; 7]; % rate each computer can complete tasks
    a = 1; % aggressiveness of sending tasks
    
    dX = zeros(numComputers,1);

    for i=1:numComputers
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
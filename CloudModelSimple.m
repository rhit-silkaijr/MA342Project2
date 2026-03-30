function [t, X] = CloudModelSimple()
    maxTime = 100; % mystical time units
    tau = 2; % delay for information to travel in time units
    lags = [tau, 2*tau]; 

    % define task inputs to the system
    t_data = 0:1:maxTime; 
    numComputers = 4;

    r_data = zeros(numComputers,maxTime+1);

    %Must manually input these anyway, so don't factor in num_computers here
    history = [100; 10; 30; 50]; % starting point
    r_data(1,:) = 5*(sin(t_data)+1); % function data for task input per computer
    r_data(2,:) = linspace(2, 10, length(t_data)); 
    r_data(3,:) = 5*(cos(t_data)+1);
    r_data(4,:) = linspace(7, 2, length(t_data));
    c = [7; 7; 7; 7]; % rate each computer can complete tasks
    
    sol = dde23(@(t,X,Xdel) calcDX(t, X, Xdel, t_data, r_data, numComputers, c), lags, history, [0, maxTime]);
    
    % Plot results
    figure;
    subplot(2,1,1);
    legend_names = [];
    hold on
    for i=1:numComputers
        plot(sol.x, sol.y(i,:));
        legend_names = [legend_names, sprintf("C%.0f Load", i)];
        % add legend based on i 
    end
    legend(legend_names); 
    
    subplot(2,1,2);
    legend_names = [];
    hold on
    for i=1:numComputers
        plot(t_data, r_data(i,:));
        legend_names = [legend_names, sprintf("C%.0f Input (r%.0f Input)", i, i)];
    end
    legend(legend_names);
end

function dX = calcDX(t, X, Xdel, t_data, r_data, numComputers, c)

    r = zeros(numComputers,1);

    % interpolate for tasks into system at any given time
    for i=1:numComputers
        r(i,:) = interp1(t_data, r_data(i,:), t);
    end

    a = 1; % aggressiveness of sending tasks
    
    dX = zeros(numComputers,1);

    for i=1:numComputers
        dX(i) = calcWork(c, X, Xdel, i, r, a);
    end
end

function calcWorkX = calcWork(c, X, Xdel, index, r, a)
    workX = min(X(index), c(index)); % tasks done per timestep, min of the amount of tasks it has
    if index ~= length(r) 
        sendUp = max(0, round(a * 0.5 * (X(index) - Xdel(index+1,1)))); % try to average tasks on computers
    else % Edge case for final computer in cycle
        sendUp = max(0, round(a * 0.5 * (X(index) - Xdel(1,1)))); 
    end
    if index ~= 1 
        recvDown = max(0, round(a * 0.5 * (Xdel(index-1,1) - Xdel(index,2))));
    else % Edge case for first computer in cycle sending down
        recvDown = max(0, round(a * 0.5 * (Xdel(length(r),1) - Xdel(index,2))));
    end
    calcWorkX = r(index) - workX - sendUp + recvDown;
end
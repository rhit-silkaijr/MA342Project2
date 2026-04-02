function [t, X] = CloudModelDynamic()
    maxTime = 1000; % mystical time units
    tau = 3; % delay for information to travel in time units
    lags = [tau, 2*tau]; 
    compute_speed = 10; % tasks per time unit

    number_of_computers = 10;
    history = zeros(number_of_computers, 1);
    t_data = 0:1:maxTime; 
    r = zeros(number_of_computers, length(t_data));

    history(1:5) = [200; 200; 200; 0; 100]; % starting point

    % define task inputs to the system
    r(1,:) = 12*(sin(t_data/8))+12;
    r(2,:) = linspace(5, 15, length(t_data)); 
    r(3,:) = 10 * ones(size(t_data)); r(3,floor(1/4*maxTime):floor(3/4*maxTime)) = 50;
    r(4,:) = linspace(0, 20, length(t_data));
    r(5,:) = 10*ones(size(t_data));
    r(6,:) = 10*ones(size(t_data));
    r(7,:) = 10*ones(size(t_data));
    r(8,:) = 10*ones(size(t_data));
    
    sol = dde23(@(t,X,Xdel) calcDX(t, X, Xdel, t_data, r, tau, compute_speed), lags, history, [0, maxTime]);
    
    % Plot results
    figure;
    subplot(2,1,1);
    legend_names = [];
    hold on
    for i=1:number_of_computers
        plot(sol.x, sol.y(i,:));
        legend_names = [legend_names, sprintf("C%.0f Load", i)];
        % add legend based on i 
    end
    legend(legend_names); 
    
    subplot(2,1,2);
    legend_names = [];
    hold on
    for i=1:number_of_computers
        plot(t_data, r(i,:));
        legend_names = [legend_names, sprintf("C%.0f Input (r%.0f Input)", i, i)];
    end
    legend(legend_names);
end

function dX = calcDX(t, X, Xdel, t_data, r, tau, compute_speed)    
    c = compute_speed * ones(length(r(:,1)), 1); % rate each computer can complete tasks
    
    dX = zeros(length(c),1);
    
    % connect all computers to all other computers
    % send to rows, receive from columns
    output_connections = zeros(length(c), length(c));
    for row = 1:length(c)
        for col = 1:length(c)
            if col ~= row
                output_connections(row, col) = 1;
            end
        end
    end

    % account for limited processing power, computer can send 10 tasks
    % or compute 1 on its own (send is capped in calc_seeds)
    % 10 is an arbitrary input
    tasks_sent_per_one_computed = 10;

    % calculate tasks to send and receive for now, and from tau ago
    distribution_current = calc_sends(output_connections, X, Xdel(:, 1), compute_speed, r, tau, tasks_sent_per_one_computed);
    distribution_previous = calc_sends(output_connections, Xdel(:, 1), Xdel(:, 2), compute_speed, r, tau, tasks_sent_per_one_computed);

    for i = 1:length(c)
        new_tasks_in = interp1(t_data, r(i,:), t);
        work = min(X(i), c(i)); % tasks done per time
        tasks_sent = sum(distribution_current(i, :));
        tasks_received = sum(distribution_previous(:, i));

        % factor in limited processing power
        work = min(work, c(i) - round(tasks_sent/tasks_sent_per_one_computed));

        % total
        dX(i) = new_tasks_in - work - tasks_sent + tasks_received;
    end
end

function distribution = calc_sends(output_connections, time1, time0, compute_speed, r, tau, tasks_sent_per_one_computed)

    number_of_computers = length(output_connections(:,1));

    distribution = zeros(number_of_computers, number_of_computers);

    for i1 = 1:number_of_computers % loop through each computer
        % get total tasks of self and computers able to be sent to with tasks <= self
        total = time1(i1);
        num_avail = 1;
        targets = [];
        for j = 1:length(output_connections)
            if output_connections(i1,j) == 1
                targets = [targets j];
            end
        end
        for i2 = 1:length(targets) % loop through all available send locations
            if time0(targets(i2)) <= time1(i1) % only include in average if <= self
                total = total + time0(targets(i2));
                num_avail = num_avail + 1;
            end
        end

        % vary a to handle spikes of tasks efficienctly
        %a = (tau / (3*length(r(:,1)))) * exp(min(max((time1(i1) - (total - time1(i1))) / 300, 0), 5)); % idk man, change these values to do some stuff
        a = .1; % between 0 and 1

        % compute ideal spread of tasks
        goal = total / num_avail;

        % send appropriate tasks to each available target
        for i2 = 1:length(targets)
            if time0(targets(i2)) <= time1(i1) % only send to if <= self
                distribution(i1,targets(i2)) = round(a * (goal - time0(targets(i2))));
            end
        end

        % check if computer is trying to send <= the tasks it can just
        % compute on its own, if so, replace with 0
        if sum(distribution(i1,:)) <= compute_speed * a
            distribution(i1,:) = 0;
        end

        while sum(distribution(i1,:)) > compute_speed * tasks_sent_per_one_computed
            distribution(i1,:) = distribution(i1,:)-1;
            %fprintf('Warning: computer %2.0f is hitting the bandwidth cap with %f.0 total tasks.\n', i1, time0(i1));
        end

    end

end
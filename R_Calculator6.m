% Define the variables
e = 14.625; % Fixed value of e
R_0 = 76.7075015111693; % Initial value of R
a_0 = 20501.275296; % Initial value of a at R_0
a_ref = 25081.301952; % Reference value of a
tolerance = 0.1; % Tolerance for difference in a values

% Define the functions for x and y values
theta_range = 0:1:1080; % Range of theta values
theta_range = deg2rad(theta_range); % Convert to radians
x_func = @(theta) e*sin(theta) + R_0*sin(theta/3);
y_func = @(theta) e*cos(theta) + R_0*cos(theta/3);

% Define the function for calculating the area
area_func = @(x, y, R) 0;
x_values = x_func(theta_range);
y_values = y_func(theta_range);
area = sum(area_func(x_values, y_values, R_0));

% Loop to find the value of R and plot the difference between a and a_ref
R = R_0;
a = a_0;
diff_array = []; % Empty array to store difference values
figure; % Create a new figure for the live plot
while abs(a - a_ref) > tolerance
    R_last = R; % Store the last value of R
    a_last = a; % Store the last value of a
    R = R + 0.1; % Increment R by 0.1
    x_values = x_func(theta_range);
    y_values = y_func(theta_range);
    area_val = 0; % New variable to store area of each trapezoid
    for i = 1:length(x_values)-1
        area_val = area_val + 0.5*(y_values(i)+y_values(i+1))*(x_values(i+1)-x_values(i));
    end
    area_func_R = @(x, y) area_val; % Define new area function using current R
    area_func = @(x, y, R) area + area_func_R(x, y)*(R/R_0); % Update area_func
    a = area_func(x_values, y_values, R);
    diff_array = [diff_array, abs(a - a_ref)]; % Append difference value to array
    
    % Check if the current value of a is greater than a_ref
    if a > a_ref
        % Interpolate the value of R
        R_interp = R_last + (R - R_last) * (a_ref - a_last) / (a - a_last);
        R = R_interp;
        x_values = x_func(theta_range);
        y_values = y_func(theta_range);
        a = area_func(x_values, y_values, R);
    end
    
    plot(diff_array); % Plot the difference array
    xlabel('Number of iterations');
    ylabel('Absolute difference between a and a_{ref}');
    title('Live plot of difference between a and a_{ref}');
    drawnow; % Update the plot
end

% Output result
fprintf('The approximate value of R is %.4f\n', R);
fprintf('The resulting value of a is %.4f\n', a);

% Plot the trochoid curve for the found R value
x_values = x_func(theta_range);
y_values = y_func(theta_range);
plot(x_values, y_values);
xlabel('x');
ylabel('y');
title(['Trochoid curve for R = ', num2str(R)]);

% Write x and y values to Excel file
resultant_curve = [x_values', y_values'];
writematrix(resultant_curve, 'F:\Work\Rotory Engine\Calculations\resultant_curve.xlsx');
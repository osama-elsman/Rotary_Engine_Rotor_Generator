%Developed by Osama M. Elsaman
% this tool is used to calculate the epitrochoid geometry for rotary engine
% Rotors on the bases of eccenricity and Rotor area required

function R_Calculator_GUI()

% Create the GUI
fig = uifigure('Name', 'R Calculator', 'Position', [100 100 500 500]);

% Add text boxes for e and a_ref values
e_label = uilabel(fig, 'Text', 'Value of e', 'Position', [50 420 80 30]);
e_textbox = uieditfield(fig, 'numeric', 'Position', [150 420 80 30]);
a_ref_label = uilabel(fig, 'Text', 'Value of a_ref', 'Position', [50 370 80 30]);
a_ref_textbox = uieditfield(fig, 'numeric', 'Position', [150 370 80 30]);

% Add a panel for the plot
plot_panel = uipanel(fig, 'Title', 'Resultant Curve', 'Position', [50 200 400 150]);

% Add a button to calculate R
calculate_button = uibutton(fig, 'push', 'Text', 'Calculate R', 'Position', [50 50 100 30], 'ButtonPushedFcn', @(calculate_button,event)calculate_R(e_textbox.Value, a_ref_textbox.Value, plot_panel, fig));

% Add a button to export x and y values
export_button = uibutton(fig, 'push', 'Text', 'Export to Excel', 'Position', [200 50 100 30], 'ButtonPushedFcn', @(export_button,event)export_excel(getappdata(fig, 'x_values'), getappdata(fig, 'y_values'), getappdata(fig, 'R'), fig));

% Add a label to display the value of R
R_label = uilabel(fig, 'Text', 'Value of R:', 'Position', [50 120 70 30]);
R_value_label = uilabel(fig, 'Text', '', 'Position', [130 120 50 30]);

% Add a label to display the name of the Developer
D_OSAMA = uilabel(fig, 'Text', 'Devoloped by: OSAMA M. ELSAMAN', 'Position', [50 10 300 30]);

% Define variables for x and y values and R
x_values = [];
y_values = [];
R = 76.7075015111693;

    function calculate_R(e, a_ref, plot_panel, fig)
        % Define the variables
        R_0 = 76.7075015111693; % Initial value of R
        a_0 = 20501.275296; % Initial value of a at R_0
        C = 0.891759956599593; % Correction factor
        tolerance = 0.1; % Tolerance for difference in a values
        
        % Define the functions for x and y values
        theta_range = 0:1:1080; % Range of theta values
        theta_range = deg2rad(theta_range); % Convert to radians
        x_func = @(theta, R) e*sin(theta) + R*sin(theta/3);
        y_func = @(theta, R) e*cos(theta) + R*cos(theta/3);
        
        % Define the function for calculating the area
        area_func = @(x, y, R) 0;
        x_values = x_func(theta_range, R_0);
        y_values = y_func(theta_range, R_0);
        area = C * sum(area_func(x_values, y_values, R_0));
        
        % Loop to find the value of R and plot the curve
        R = R_0;
        a = a_0;
        while abs(a - a_ref) > tolerance
            R_last = R; % Store the last value of R
            a_last = a; % Store the last value of a
            R = R + 0.1; % Increment R by 0.1
            x_values = x_func(theta_range, R);
            y_values = y_func(theta_range, R);
            area_val = 0; % New variable to store area of each trapezoid
            for i = 1:length(x_values)-1
                area_val = area_val + 0.5*(y_values(i)+y_values(i+1))*(x_values(i+1)-x_values(i));
            end
            a = C * (area + area_val*(R/R_0)); % Calculate a for current R
            if a > a_ref % If a is greater than a_ref, go back to last value of R
              % Interpolate the value of R
                R_interp = R_last + (R - R_last) * (a_ref - a_last) / (a - a_last);
                R = R_interp;
                x_values = x_func(theta_range, R);
                y_values = y_func(theta_range, R);
                area_val = 0; % New variable to store area of each trapezoid
                for i = 1:length(x_values)-1
                    area_val = area_val + 0.5*(y_values(i)+y_values(i+1))*(x_values(i+1)-x_values(i));
                end
                a = C * (area + area_val*(R/R_0)); % Calculate a for current R
            end
        end
        
        % Plot the curve
        plot_axes = uiaxes(plot_panel, 'Position', [10 10 380 130]);
        plot(plot_axes, x_values, y_values);
        xlim(plot_axes, [-10 10]);
        ylim(plot_axes, [-10 10]);
        title(plot_axes, 'Resultant Curve');
        
        % Update the value of R in the GUI
        set(R_value_label, 'Text', num2str(R));
        
        % Store the x and y values and R in the app data
        setappdata(fig, 'x_values', x_values);
        setappdata(fig, 'y_values', y_values);
        setappdata(fig, 'R', R);
    end

    function export_excel(x_values, y_values, R, fig)
        % Create a table of x and y values
        data = [x_values', y_values'];
        column_names = {'x', 'y'};
        table_data = array2table(data, 'VariableNames', column_names);
        
        % Create a file dialog to choose a filename and location to save the file
        [filename, pathname] = uiputfile('.xlsx', 'Save As');
        if isequal(filename,0) || isequal(pathname,0)
            % User cancelled the save operation
            return
        end
        
        % Write the table to an Excel file
        filepath = fullfile(pathname, filename);
        writetable(table_data, filepath);
        
        % Display a message box to confirm the export
        message = sprintf('x and y values exported to %s', filepath);
        uialert(fig, message, 'Export Successful');
    end

end
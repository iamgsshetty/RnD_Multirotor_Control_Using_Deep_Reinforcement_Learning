function plotDronePath(x, y, z, waypoints)
    % plotDronePath Plots the drone's trajectory, starting and current positions, and waypoints
    %
    % Inputs:
    %   x - Array of X positions of the drone over time
    %   y - Array of Y positions of the drone over time
    %   z - Array of Z positions of the drone over time
    %   waypoints - An Nx3 matrix where each row represents [X, Y, Z] coordinates of a waypoint

    % Validate that x, y, and z arrays are of equal length
    if length(x) ~= length(y) || length(y) ~= length(z)
        error('x, y, and z must have the same number of elements.');
    end

    % Validate that waypoints matrix is Nx3
    if size(waypoints, 2) ~= 3
        error('Waypoints matrix must be Nx3, where N is the number of waypoints.');
    end

    % Create a new figure for the plot
    figure;
    
    % Plot the waypoints as blue filled circles
    scatter3(waypoints(:, 1), waypoints(:, 2), waypoints(:, 3), 50, 'b', 'filled');
    hold on; % Retain this plot when adding more elements

    % Plot the drone's trajectory as a red line
    plot3(x, y, z, 'r-', 'LineWidth', 1.5);

    % Mark the starting position of the drone with a green circle
    plot3(x(1), y(1), z(1), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');

    % Mark the current (final) position of the drone with a red circle
    plot3(x(end), y(end), z(end), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

    % Label the axes for clarity
    xlabel('X Position');
    ylabel('Y Position');
    zlabel('Z Position');
    
    % Set a title for the plot
    title('Drone Trajectory and Waypoints');

    % Add a legend to identify different plot elements
    legend('Waypoints', 'Drone Trajectory', 'Starting Position', 'Current Position');

    % Enable grid for better visual reference and set axis scaling to be equal
    grid on;
    axis equal;

    % End plotting additions
    hold off;
end

% Retrieve drone position data from the Simulink output
x_position = out.ScopeData{1}.Values.Data(:, 2);
y_position = out.ScopeData{2}.Values.Data(:, 2);
z_position = out.ScopeData{3}.Values.Data(:, 2);

% Assign position data to x, y, z for plotting
x = x_position;
y = y_position;
z = z_position;

% Uncomment to define waypoints as an Nx3 matrix
% waypoints = [10, -6, 5;
%              0, -10, 5;
%             -10, -6, 5;
%             -12, 0, 5;
%              0, 9, 5];

% Call the function to plot the drone's path and waypoints
plotDronePath(x, y, z, waypoints);

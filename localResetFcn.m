function in = localResetFcn(in)
    % Generate random initial position in XY plane within the range [-2, 2]
    position_xy = (rand(2, 1) * 4) - 2;    
    % Generate random Z position in the range [-1, -6]
    position_z = -1 * ((rand * 5) + 1); 
    % Combine XY and Z into a position vector
    pos = [position_xy; position_z];
    
    % Generate random velocity in the range [-0.5, 0.5] for each axis
    velocity = rand(3, 1) - 0.5;
    
    % Generate random orientation with specific range for roll (x-axis)
    random_number = (-pi/2) + (pi) * rand; % Random roll angle in the range [-pi/2, pi/2]
    orientation = rand(3, 1);              % General orientation in the range [0, 2*pi]
    orientation(1) = random_number;        % Set the roll angle specifically

    % Generate random desired position in XY within the range [-3, 3] and Z in [1, 6]
    des_xy = (rand(2, 1) * 6) - 3;
    des_z = (rand() * 5) + 1;
    des = [des_xy(1); des_xy(2); des_z];

    % Uncomment to set initial condition with generated position, velocity, and orientation
    % in = setBlockParameter(in, ...
    %     "waypoint_follow/Integrator", ...
    %     "InitialCondition", mat2str([pos; velocity; orientation; 0; 0; 0; 0]));
    % Uncomment to set desired position directly in the Simulink model
    % set_param('waypoint_follow/Constant', 'Value', mat2str(des));

    % Set a fixed initial condition for the Integrator block
    in = setBlockParameter(in, ...
        "waypoint_follow/Integrator", ...
        "InitialCondition", mat2str([0; 0; -1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0]));

    % Uncomment to set a fixed desired position at [0; 0; 5] in the Simulink model
    % set_param('waypoint_follow/Constant', 'Value', mat2str([0; 0; 5]));

    % Set a random mass for the "Mass" block in the range [0.4, 0.6]
    set_param('waypoint_follow/Mass', 'Value', mat2str(0.4 + rand() * 0.2));
end

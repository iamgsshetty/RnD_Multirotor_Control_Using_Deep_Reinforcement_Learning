function in = localResetFcn(in)
   
    position_xy = (rand(2, 1) * 4) -2;        % Random position in the range [0, 5]
    position_z = -1 * ((rand * 5) + 1);
    pos = [position_xy; position_z];
    velocity = rand(3, 1) - 0.5;       % Random velocity in the range [-0.5, 0.5]
    random_number = (-pi/2) + (pi) * rand;
    orientation = rand(3, 1);   % Random orientation in the range [0, 2*pi]
    orientation(1) = random_number;
    % angularRates = rand(3, 1) - 0.5;   % Random angular rates in the range [-0.5, 0.5]
    des_xy = (rand(2, 1) * 6) - 3;
    des_z = (rand() * 5) + 1;
    des = [des_xy(1);des_xy(2);des_z];
    % in = setBlockParameter(in, ...
    % "waypoint_follow/Integrator", ...
    % "InitialCondition", mat2str([pos;velocity;orientation;0;0;0;0]));
    % set_param('waypoint_follow/Constant', 'Value', mat2str(des));
    in = setBlockParameter(in, ...
    "waypoint_follow/Integrator", ...
    "InitialCondition", mat2str([0;0;-1;0;0;0;0;0;0;0;0;0;0]));
    % set_param('waypoint_follow/Constant', 'Value', mat2str([0;0;5]));
    set_param('waypoint_follow/Mass', 'Value', mat2str(0.4 + rand() * 0.2));
end
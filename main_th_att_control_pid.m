clc;
clearvars;
close all;

[rp_acc, rp_acc_msg] = rospublisher('/mavros/setpoint_accel/accel');
[rp_att, rp_att_msg] = rospublisher('/mavros/setpoint_raw/attitude');

rs_pos = rossubscriber('/mavros/local_position/pose');
rs_vel = rossubscriber('/mavros/local_position/velocity_local');
% rs_pos_des = rossubscriber('/pos_des');

pause(1);

rp_att_msg.TypeMask = uint8(7);

%%
set_to_offboard_mode();
arm_uav();

ex_int = 0;
ey_int = 0;
ez_int = 0;

i = 0;
% agent = load('TD3agent_4_3act_13obs_trainedondynamic_des_curr_pos').agent_loaded.agent_loaded.saved_agent;
agent = load('TD3agent.mat').agent;
while (true)
    % rs_pos_des_msg = rs_pos_des.LatestMessage();
    rs_vel_msg = rs_vel.LatestMessage();
    rs_pos_msg = rs_pos.LatestMessage();
    
    % x_des = rs_pos_des_msg.Data(1);
    % y_des = rs_pos_des_msg.Data(2);
    % z_des = rs_pos_des_msg.Data(3);

    x_des = 0;
    y_des = 0;
    z_des = 5;
    
    x_uav =  rs_pos_msg.Pose.Position.X;
    y_uav =  rs_pos_msg.Pose.Position.Y;
    z_uav =  rs_pos_msg.Pose.Position.Z;

    % Extract orientation in quaternion
    q_x = rs_pos_msg.Pose.Orientation.X;
    q_y = rs_pos_msg.Pose.Orientation.Y;
    q_z = rs_pos_msg.Pose.Orientation.Z;
    q_w = rs_pos_msg.Pose.Orientation.W;

    % Convert quaternion to Euler angles (yaw, pitch, roll)
    eulerAngles = quat2eul([q_w, q_x, q_y, q_z]);
    eulerAngles = [eulerAngles(1); eulerAngles(2); eulerAngles(3)];

    u_uav = rs_vel_msg.Twist.Linear.X;
    v_uav = rs_vel_msg.Twist.Linear.Y;
    w_uav = rs_vel_msg.Twist.Linear.Z;

    % Extract angular velocities from the Twist message(p q r)
    angular_velocity_x = rs_vel_msg.Twist.Angular.X;
    angular_velocity_y = rs_vel_msg.Twist.Angular.Y;
    angular_velocity_z = rs_vel_msg.Twist.Angular.Z;
    angular_velocity = [angular_velocity_x; angular_velocity_y; angular_velocity_z];

    ex_int = ex_int + 0.01*(x_uav - x_des);
    ey_int = ey_int + 0.01*(y_uav - y_des);
    ez_int = ez_int + 0.01*(z_uav - z_des);


    % Define the observation
    curr_pos = [x_uav; y_uav; z_uav];
    des_pos = [x_des; y_des; z_des];
    observation = [(z_uav)/10;(curr_pos-des_pos)/10;[u_uav;v_uav;w_uav];(4*eulerAngles)/pi;(4*angular_velocity)/pi];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PID Control
    
    Ku = 0.1;
    Tu = 5;
    Kp = 0.6*Ku;
    Ki = 1.20*Ku/Tu;
    Kd = 0.075*Ku*Tu;

    ax = (- 0.8*Ku*(x_uav - x_des) - 0.1*Ku*Tu*u_uav)*5;
    ay = (- 0.8*Ku*(y_uav - y_des) - 0.1*Ku*Tu*v_uav)*5;

    az = - Kp*(z_uav - z_des) - Kd*w_uav - Ki*ez_int;
    az = 0.65 + max(0,min(az,1));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Load the RL agent from the .mat file
    % 
    % % 
    % % 
    % % % Get action from the agent
    action = getAction(agent,observation);
    roll = ((action{1}(1) + 1) * (pi/2) / 2) - pi/4;
    pitch = ((action{1}(2) + 1) * (pi/2) / 2) - pi/4;
    % yawrate = ((action{1}(3) + 1) * (pi/2) / 2) - pi/4;
    % thrust = (((action{1}(3) + 1) * (10) / 2) - 5)/5;
    thrust = ((action{1}(3) + 1)/2)*15;
    % % % Update the yaw angle using the yaw rate and a time step
    % dt = 0.009; % Time step (adjust as necessary)
    % yaw = eulerAngles(2) + yawrate * dt;
    % 
    % % Compute the DCM (Direction Cosine Matrix) from roll, pitch, and yaw
    % R = angle2dcm(yaw, pitch, roll, 'ZYX');
    % 
    % % Gravity compensation
    % g = 0;
    % gravity_compensation = [0; 0; g];
    % 
    % % % Compute the accelerations
    % acc_body_frame = [0; 0; thrust];
    % acc_global_frame = R * acc_body_frame - gravity_compensation;
    % 
    % ax_rl = acc_global_frame(1);
    % ay_rl = acc_global_frame(2);
    % az_rl = acc_global_frame(3);
    % ax= ax_rl;
    % ay=ay_rl;
    % az=az_rl;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f = sqrt(ax^2 + ay^2 + az^2);
    psi_des = 0;
    % psi_des = rs_pos_des_msg.Data(4)*pi/180;
    % phi_des = asin(-ay/f);
    % theta_des = asin(ax/(f*cos(phi_des)));
    ax2 =  ax*cos(psi_des) + ay*sin(psi_des);
    ay2 = -ax*sin(psi_des) + ay*cos(psi_des);
    phi_des = asin(-ay2/f);
    theta_des = asin(ax2/(f*cos(phi_des)));
    
    % phi_des = asin((ax*sin(psi_des) - ay*cos(psi_des))/f);
    % theta_des = atan((-ay*sin(psi_des) + ax*cos(psi_des))/(0.65 + az));
    % theta_des = asin((ax*cos(psi_des) + ay*sin(psi_des))/(f*cos(phi_des)));
    
    % phi_des = max(-0.05,min(phi_des,0.05));
    % theta_des = max(-0.05,min(theta_des,0.05));
    
    az2 = (cos(phi_des)*sin(theta_des)*cos(psi_des) + sin(phi_des)*sin(psi_des))*ax + ...
           (cos(phi_des)*sin(theta_des)*sin(psi_des) - sin(phi_des)*cos(psi_des))*ay + ...
            (cos(phi_des)*cos(theta_des))*az;
      

    q_des = eul2quat([psi_des, theta_des, phi_des],'zyx');
    % pitch = max(-0.05,min(pitch,0.05));
    % roll = max(-0.05,min(roll,0.05));
    % q_des = eul2quat([eulerAngles(3), pitch, roll],'zyx');
    % q_des = eul2quat([0,0,0],'zyx');
    T = az2;
    % T = thrust *0.7212;
    % T = max(0.65,min(T,1));
    % T = 0.708;
    % T = 0.65 + max(0,min(T,1)); %%%code changed here please check to revert to original
    
    rp_att_msg.Orientation.W = q_des(1);
    rp_att_msg.Orientation.X = q_des(2);
    rp_att_msg.Orientation.Y = q_des(3);
    rp_att_msg.Orientation.Z = q_des(4);
    
    rp_att_msg.Thrust = T;

    rp_att.send(rp_att_msg);
    
    % fprintf('ax_diff = %f, ay_diff = %f, az_diff = %f, x = %f,  y = %f, z = %f, T = %f, phi_d = %f, theta_d = %f\n',ax_rl-ax,ay_rl-ay,az_rl-az,x_uav,y_uav,z_uav,T,phi_des,theta_des);
    % fprintf('x = %f,  y = %f, z = %f, T = %f, phi_d = %f, theta_d = %f\n',x_uav,y_uav,z_uav,T,phi_des,theta_des);    
    fprintf('x = %f,  y = %f, z = %f, T = %f, roll = %f, pitch = %f, yaw = %f\n', x_uav,y_uav,z_uav,T,eulerAngles(1),eulerAngles(2),eulerAngles(3));
    % fprintf('ax = %f, ay = %f, az = %f',ax,ay,az);
    pause(0.009)
    i = i + 1;
    X_UAV (i) = x_uav;    
    Y_UAV (i) = y_uav;
    Z_UAV (i) = z_uav;
    Error_X_UAV (i) = x_uav-x_des;
    Error_Y_UAV (i) = y_uav-y_des;
    Error_Z_UAV (i) = z_uav-z_des;
    X_DES (i) = x_des;
    Y_DES (i) = y_des;
    Z_DES (i) = z_des;
end

function rs_response = set_to_offboard_mode()

rs_state = rossubscriber('/mavros/state');
[rp_pos, rp_pos_msg] = rospublisher('/mavros/setpoint_position/local');

pause(1)

mode = '';

while (~strcmp(mode,'OFFBOARD'))
    x_des = 0.0;
    y_des = 0.0;
    z_des = 0.0;
    
    for i = 1:100
        rp_pos_msg.Pose.Position.X = x_des + rand/100;
        rp_pos_msg.Pose.Position.Y = y_des + rand/100;
        rp_pos_msg.Pose.Position.Z = z_des + rand/100;
        
        rp_pos.send(rp_pos_msg);
        pause(0.001);
    end
    fprintf('Initial messages sent\n')
    
    rs_mode = rossvcclient('/mavros/set_mode');
    rs_mode_msg = rs_mode.rosmessage;
    rs_mode_msg.CustomMode = 'OFFBOARD';
    
    rs_response = rs_mode.call(rs_mode_msg);
    
    rs_state_msg = rs_state.LatestMessage();
    mode = rs_state_msg.Mode();
end

end
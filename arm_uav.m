function arm_status = arm_uav()

%Arm throttle
rs_arm = rossvcclient('/mavros/cmd/arming');
rs_arm_call_msg = rs_arm.rosmessage;
rs_arm_call_msg.Value = true;
arm_status = rs_arm.call(rs_arm_call_msg);

end
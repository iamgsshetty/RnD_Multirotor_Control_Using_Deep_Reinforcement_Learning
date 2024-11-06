rng('shuffle')
mdl = "waypoint_follow";
% % open_system(mdl)
% % 
% actionInfo = rlNumericSpec([4 1], ...
%     LowerLimit = -1', ...
%     UpperLimit = 1');
% actionInfo.Name = "control";
% actionInfo.Description = "roll, pitch, yawrate and thrust";
% 
% observationInfo = rlNumericSpec([12 1]);
% observationInfo.Name = "obs";
% observationInfo.Description = "pos, vel, orientation, ang vel, thrust";
% 
% env = rlSimulinkEnv(mdl, mdl + "/RL Agent", observationInfo, actionInfo);
% 
% env.ResetFcn = @(in)localResetFcn(in);
% agent_loaded = load("TD3agent_4_3act_13obs_trainedondynamic_des_curr_pos.mat").agent_loaded.agent_loaded;
% simOptions = rlSimulationOptions(MaxSteps=1500, NumSimulations=1);
% experience = sim(env,agent_loaded.saved_agent,simOptions);
% scopeConfig = get_param('waypoint_follow/Visualization Block/Scope','ScopeConfiguration');
% scopeConfig.DataLogging = true;
% scopeConfig.DataLoggingSaveFormat = 'Dataset';
agent = load("TD3agent.mat").agent;
simOptions = rlSimulationOptions(MaxSteps=2000, NumSimulations=1);
experience = sim(env,agent,simOptions);
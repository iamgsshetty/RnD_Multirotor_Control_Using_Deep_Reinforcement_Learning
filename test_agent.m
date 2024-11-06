% Set random seed based on current time for variability in simulations
rng('shuffle');

% Define the Simulink Model
mdl = "waypoint_follow";
% Uncomment to open the Simulink model
% open_system(mdl)

% Define Action Space Specifications
% Specifies a 3x1 action space with each action constrained between -1 and 1.
actionInfo = rlNumericSpec([3, 1], ...
    'LowerLimit', -1, ...
    'UpperLimit', 1);
actionInfo.Name = "control";
actionInfo.Description = "roll, pitch, yawrate and thrust";

% Define Observation Space Specifications
% Specifies a 13x1 observation space for tracking position, velocity, orientation, angular velocity, and thrust.
observationInfo = rlNumericSpec([13, 1]);
observationInfo.Name = "obs";
observationInfo.Description = "pos, vel, orientation, ang vel, thrust";

% Create the Reinforcement Learning Environment
% The environment links the Simulink model with the RL Agent block and sets observation and action specs.
env = rlSimulinkEnv(mdl, mdl + "/RL Agent", observationInfo, actionInfo);

% Set the environment reset function to localResetFcn
env.ResetFcn = @(in)localResetFcn(in);

% Uncomment to load a pre-trained TD3 agent
% agent_loaded = load("TD3agent_4_3act_13obs_trainedondynamic_des_curr_pos.mat").agent_loaded.agent_loaded;

% Uncomment to define simulation options and simulate the loaded agent
% simOptions = rlSimulationOptions('MaxSteps', 1500, 'NumSimulations', 1);
% experience = sim(env, agent_loaded.saved_agent, simOptions);

% Uncomment to configure scope logging for visualization during simulation
% scopeConfig = get_param('waypoint_follow/Visualization Block/Scope', 'ScopeConfiguration');
% scopeConfig.DataLogging = true;
% scopeConfig.DataLoggingSaveFormat = 'Dataset';

% Load the pre-trained TD3 agent
agent = load("TD3agent.mat").agent;

% Define Simulation Options
% Sets a maximum of 2000 steps for each simulation and runs one simulation.
simOptions = rlSimulationOptions('MaxSteps', 2000, 'NumSimulations', 1);

% Run the simulation with the loaded agent and defined simulation options
experience = sim(env, agent, simOptions);

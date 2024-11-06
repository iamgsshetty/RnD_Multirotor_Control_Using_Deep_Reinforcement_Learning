% Define the Simulink Model
mdl = "waypoint_follow";
open_system(mdl);

% Action Specification
% Defines a 3x1 numeric specification for action space with limits from -1 to 1.
actionInfo = rlNumericSpec([3, 1], ...
    'LowerLimit', -1, ...
    'UpperLimit', 1);
actionInfo.Name = "control";
actionInfo.Description = "roll, pitch, yawrate and thrust";

% Observation Specification
% Defines a 13x1 numeric specification for observation space.
observationInfo = rlNumericSpec([13, 1]);
observationInfo.Name = "obs";
observationInfo.Description = "pos, vel, orientation, ang vel, thrust";

% Create the RL Environment
% Links the Simulink model with RL Agent block, and associates observation and action specs.
env = rlSimulinkEnv(mdl, mdl + "/RL Agent", observationInfo, actionInfo);
env.ResetFcn = @(in)localResetFcn(in); % Set environment reset function

% Retrieve Observation and Action Information
obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

% Define Observation and Action Dimensions
numObs = 13;
numAct = 3;

% Uncomment if creating agents
% agent = rlTD3Agent(observationInfo, actInfo);
% agent = createSACAgent(numObs, obsInfo, numAct, actInfo, 0.01);
% agent = createDDPGAgent(numObs, obsInfo, numAct, actInfo, 0.01);

% Sampling time for agent and simulation
Ts = 0.01;
Ts_agent = Ts;

% Simulation parameters
T = 10.0;                      % Total simulation time (seconds)
maxepisodes = 2500;            % Maximum episodes for training
maxsteps = ceil(T / Ts_agent); % Maximum steps per episode

% Set up Training Options
trainOpts = rlTrainingOptions(...
    'MaxEpisodes', maxepisodes, ...
    'MaxStepsPerEpisode', maxsteps, ...
    'StopTrainingCriteria', "None", ...
    'ScoreAveragingWindowLength', 500, ...
    'Verbose', 1, ...
    'UseParallel', true);

% Define Criteria and Save Options
trainOpts.SaveAgentCriteria = 'EpisodeFrequency';
trainOpts.SaveAgentValue = 250000;

% Uncomment to specify a directory for saved agents
% trainOpts.SaveAgentDirectory = '/savedAgents/td3';

% Set Parallelization Mode to asynchronous
trainOpts.ParallelizationOptions.Mode = 'async';

% Uncomment if using evaluator during training
% evaluator = rlEvaluator(... 
%     'NumEpisodes', 3, ...
%     'EvaluationFrequency', 100);

% Start Parallel Pool with 4 workers
parpool(4);

% Define Training Mode
doTraining = false; % Set to true for training, false for evaluation

if doTraining
    % Uncomment to train TD3 Agent
    % agent = createTD3Agent(numObs, obsInfo, numAct, actInfo, 0.01);
    % trainResult_td3 = train(agent, env, trainOpts);
    % save("TD3agent.mat", "agent");
    % save("trainResult_td3");

    % Train DDPG Agent
    agent = createDDPGAgent(numObs, obsInfo, numAct, actInfo, 0.01);
    % Uncomment to load a pre-trained DDPG agent if available
    % agent_loaded = load("DDPGagent.mat");

    % Train the DDPG agent and save results
    trainResult_ddpg = train(agent, env, trainOpts);
    save("trainResult_ddpg");
    save("DDPGagent.mat", "agent");

    % Uncomment to train SAC Agent
    % agent = createSACAgent(numObs, obsInfo, numAct, actInfo, 0.01);
    % trainResult_sac = train(agent, env, trainOpts);
    % save("SACagent.mat", "agent");
    % save("trainResult_sac");

else
    % Load Pre-trained TD3 Agent and Evaluate
    % Load the pre-trained TD3 agent if doTraining is false
    agent_loaded = load("TD3agent.mat");
    agent = agent_loaded.agent;

    % Uncomment if modifying agent's experience buffer size
    % resize(agent.ExperienceBuffer, 5e6);

    % Continue training or evaluation with SAC if required
    trainResult_sac = train(agent, env, trainOpts);

    % Save the trained TD3 agent and training results
    save("TD3agent.mat", "agent");
    save("trainResult_td3");
end

% Close Parallel Pool after Training or Evaluation
delete(gcp('nocreate'));

function agent = createTD3Agent(numObs, obsInfo, numAct, actInfo, Ts)
    % createTD3Agent Creates a Twin Delayed Deep Deterministic (TD3) agent.
    %
    % This function initializes a TD3 agent for reinforcement learning by
    % creating the actor and critic networks, defining options for the agent,
    % and configuring exploration and policy update parameters.
    %
    % Inputs:
    %   numObs - Number of observations
    %   obsInfo - Observation specifications
    %   numAct - Number of actions
    %   actInfo - Action specifications
    %   Ts - Sampling time for the agent

    %% Create the actor and critic networks using the helper function
    [criticNetwork1, criticNetwork2, actorNetwork, ~] = createNetworks(numObs, numAct);
    % Two critic networks are created for TD3 to address the overestimation bias

    %% Specify options for the critic and actor representations using rlOptimizerOptions
    % Define the optimizer for both actor and critic networks with common settings
    criticOptions = rlOptimizerOptions('Optimizer', 'adam', ...
                                       'LearnRate', 1e-3, ...
                                       'GradientThreshold', 1);
    actorOptions = rlOptimizerOptions('Optimizer', 'adam', ...
                                      'LearnRate', 1e-3, ...
                                      'GradientThreshold', 1);

    %% Create critic and actor representations with specified networks and options
    critic1 = rlQValueFunction(criticNetwork1, obsInfo, actInfo, ...
                               'ObservationInputNames', 'observation', ...
                               'ActionInputNames', 'action');
    critic2 = rlQValueFunction(criticNetwork2, obsInfo, actInfo, ...
                               'ObservationInputNames', 'observation', ...
                               'ActionInputNames', 'action');
    actor = rlContinuousDeterministicActor(actorNetwork, obsInfo, actInfo);

    %% Specify TD3 agent options for training behavior and performance
    agentOptions = rlTD3AgentOptions;
    agentOptions.SampleTime = Ts;
    agentOptions.DiscountFactor = 0.99;
    agentOptions.MiniBatchSize = 256;
    agentOptions.ExperienceBufferLength = 1e6;

    % Configure the target smooth factor and update frequency
    agentOptions.TargetSmoothFactor = 5e-3;  % Larger values result in smoother target updates
    agentOptions.NumEpoch = 3;               % Number of epochs for training updates
    agentOptions.MaxMiniBatchPerEpoch = 100; % Maximum number of mini-batches per epoch

    % Policy and target update frequencies
    agentOptions.LearningFrequency = -1;          % Specifies how often learning occurs
    agentOptions.PolicyUpdateFrequency = 1;       % Frequency for actor updates
    agentOptions.TargetUpdateFrequency = 1;       % Frequency for target network updates

    % Target policy noise configuration to improve exploration
    agentOptions.TargetPolicySmoothModel.StandardDeviationMin = 0.05;
    agentOptions.TargetPolicySmoothModel.StandardDeviation = 0.05;
    agentOptions.TargetPolicySmoothModel.LowerLimit = -0.5;
    agentOptions.TargetPolicySmoothModel.UpperLimit = 0.5;

    % Set up Ornstein-Uhlenbeck (OU) noise for action exploration
    agentOptions.ExplorationModel = rl.option.OrnsteinUhlenbeckActionNoise;
    agentOptions.ExplorationModel.MeanAttractionConstant = 1;
    agentOptions.ExplorationModel.StandardDeviation = 0.1;

    % Link the actor and critic optimizer options to the agent
    agentOptions.ActorOptimizerOptions = actorOptions;
    agentOptions.CriticOptimizerOptions = criticOptions;

    %% Create TD3 agent with specified actor and critics, and agent options
    agent = rlTD3Agent(actor, [critic1, critic2], agentOptions);

    % Uncomment below to enable prioritized experience replay with annealing
    % agent.ExperienceBuffer = rlPrioritizedReplayMemory(obsInfo, actInfo);
    % agent.ExperienceBuffer.NumAnnealingSteps = 1e6;
    % agent.ExperienceBuffer.PriorityExponent = 0.6;
    % agent.ExperienceBuffer.InitialImportanceSamplingExponent = 0.5;
end

function agent = createDDPGAgent(numObs, obsInfo, numAct, actInfo, Ts)
    % createDDPGAgent Creates a DDPG agent with specified observation and action space configurations.
    %
    % Inputs:
    %   numObs - Number of observations
    %   obsInfo - Observation space information
    %   numAct - Number of actions
    %   actInfo - Action space information
    %   Ts - Sample time for the agent
    %
    % Outputs:
    %   agent - Configured DDPG agent

    %% Create the actor and critic networks using the createNetworks helper function
    [criticNetwork, ~, actorNetwork, ~] = createNetworks(numObs, numAct);

    %% Define optimizer options for both the critic and actor networks
    criticOptions = rlOptimizerOptions('Optimizer', 'adam', ...
                                       'LearnRate', 1e-3, ...
                                       'GradientThreshold', 1);
    actorOptions = rlOptimizerOptions('Optimizer', 'adam', ...
                                      'LearnRate', 1e-3, ...
                                      'GradientThreshold', 1);

    %% Create critic and actor representations
    % Define the critic as a Q-value function
    critic = rlQValueFunction(criticNetwork, obsInfo, actInfo, ...
                              'ObservationInputNames', 'observation', ...
                              'ActionInputNames', 'action');

    % Define the actor as a continuous deterministic policy
    actor = rlContinuousDeterministicActor(actorNetwork, obsInfo, actInfo);

    %% Specify options for the DDPG agent
    agentOptions = rlDDPGAgentOptions;
    agentOptions.SampleTime = Ts;
    agentOptions.DiscountFactor = 0.99;
    agentOptions.MiniBatchSize = 256;
    agentOptions.ExperienceBufferLength = 1e6;
    agentOptions.TargetSmoothFactor = 5e-3;

    % Training-related options
    agentOptions.NumEpoch = 3;
    agentOptions.MaxMiniBatchPerEpoch = 100;
    agentOptions.LearningFrequency = -1;
    agentOptions.PolicyUpdateFrequency = 1;
    agentOptions.TargetUpdateFrequency = 1;

    % Exploration noise settings
    agentOptions.NoiseOptions.MeanAttractionConstant = 1;
    agentOptions.NoiseOptions.StandardDeviation = 0.1;

    % Assign optimizer options to the agent
    agentOptions.ActorOptimizerOptions = actorOptions;
    agentOptions.CriticOptimizerOptions = criticOptions;

    %% Create the DDPG agent using the actor and critic representations
    agent = rlDDPGAgent(actor, critic, agentOptions);
end

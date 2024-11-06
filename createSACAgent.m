function agent = createSACAgent(numObs, obsInfo, numAct, actInfo, Ts)
    % createSACAgent Creates a Soft Actor-Critic (SAC) agent.
    %
    % This function initializes an SAC agent for reinforcement learning by
    % creating the actor and critic networks, defining optimizer options, and
    % configuring agent-specific options for smooth learning and stability.
    %
    % Inputs:
    %   numObs - Number of observations
    %   obsInfo - Observation specifications
    %   numAct - Number of actions
    %   actInfo - Action specifications
    %   Ts - Sampling time for the agent

    %% Create the actor and critic networks using the helper function
    [criticNetwork1, criticNetwork2, ~, actorNetwork] = createNetworks(numObs, numAct);
    % Two critic networks are created to help mitigate overestimation bias in SAC

    %% Specify options for the critic and actor networks with rlOptimizerOptions
    % Configure optimizer settings for both critic and actor networks
    criticOptions = rlOptimizerOptions('Optimizer', 'adam', ...
                                       'LearnRate', 1e-3, ...
                                       'GradientThreshold', 1);
    actorOptions = rlOptimizerOptions('Optimizer', 'adam', ...
                                      'LearnRate', 1e-3, ...
                                      'GradientThreshold', 1);

    %% Create critic and actor representations with specified networks and options
    % Define the Q-value functions (critics) and the Gaussian policy (actor)
    critic1 = rlQValueFunction(criticNetwork1, obsInfo, actInfo, ...
                               'ObservationInputNames', 'observation', ...
                               'ActionInputNames', 'action');
    critic2 = rlQValueFunction(criticNetwork2, obsInfo, actInfo, ...
                               'ObservationInputNames', 'observation', ...
                               'ActionInputNames', 'action');

    % Create the Gaussian actor which outputs mean and standard deviation
    actor = rlContinuousGaussianActor(actorNetwork, obsInfo, actInfo, ...
                                      'ObservationInputNames', "observation", ...
                                      'ActionMeanOutputNames', "actionMean", ...
                                      'ActionStandardDeviationOutputNames', "actionStd");

    %% Specify SAC agent options for training behavior and performance
    agentOptions = rlSACAgentOptions;
    agentOptions.SampleTime = Ts;             % Sampling time step for the agent
    agentOptions.DiscountFactor = 0.99;       % Discount factor for future rewards
    agentOptions.MiniBatchSize = 256;         % Batch size for training
    agentOptions.ExperienceBufferLength = 1e6;% Memory size for experience replay
    agentOptions.TargetSmoothFactor = 5e-3;   % Target smoothing factor for stability

    % Set options for the learning process
    agentOptions.NumEpoch = 3;                % Number of training epochs per update
    agentOptions.MaxMiniBatchPerEpoch = 100;  % Max mini-batches per epoch
    agentOptions.LearningFrequency = -1;      % Specifies how often learning occurs
    agentOptions.PolicyUpdateFrequency = 1;   % Frequency of actor policy updates
    agentOptions.TargetUpdateFrequency = 1;   % Frequency of target network updates

    % Attach optimizer options to the agent for actor and critic
    agentOptions.ActorOptimizerOptions = actorOptions;
    agentOptions.CriticOptimizerOptions = criticOptions;

    %% Create the SAC agent using the actor and critics along with agent options
    agent = rlSACAgent(actor, [critic1, critic2], agentOptions);

    % Optional configurations and notes
    % Uncomment below to explore further customizations
    % agentOptions.EntropyWeightOptions.EntropyWeight = 0.2; % Adjust entropy weight
    % agentOptions.EntropyWeightOptions.TargetEntropy = -1.0; % Target entropy for exploration

end

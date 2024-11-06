function [criticNetwork1, criticNetwork2, actorNetwork, actorNet] = createNetworks(numObs, numAct)
    % createNetworks Generates two critic networks and two actor networks for SAC/TD3.
    %
    % Inputs:
    %   numObs - Number of observation inputs
    %   numAct - Number of action outputs
    %
    % Outputs:
    %   criticNetwork1 - First critic network for Q-value estimation
    %   criticNetwork2 - Second critic network (for TD3/SAC to avoid overestimation)
    %   actorNetwork - Actor network for TD3 agent
    %   actorNet - Actor network for SAC agent (with separate mean and std paths)

    %% CRITIC NETWORK SETUP
    % Critic network layer specifications
    criticLayerSizes = [400 300];

    % Define layers for the first critic network
    statePath1 = [
        featureInputLayer(numObs,'Normalization','none','Name', 'observation')
        fullyConnectedLayer(criticLayerSizes(1), 'Name', 'CriticStateFC1', ...
                'Weights', 2/sqrt(numObs)*(rand(criticLayerSizes(1),numObs)-0.5), ...
                'Bias', 2/sqrt(numObs)*(rand(criticLayerSizes(1),1)-0.5))
        reluLayer('Name','CriticStateRelu1')
        fullyConnectedLayer(criticLayerSizes(2), 'Name', 'CriticStateFC2', ...
                'Weights', 2/sqrt(criticLayerSizes(1))*(rand(criticLayerSizes(2),criticLayerSizes(1))-0.5), ...
                'Bias', 2/sqrt(criticLayerSizes(1))*(rand(criticLayerSizes(2),1)-0.5))
        ];
    actionPath1 = [
        featureInputLayer(numAct,'Normalization','none', 'Name', 'action')
        fullyConnectedLayer(criticLayerSizes(2), 'Name', 'CriticActionFC1', ...
                'Weights', 2/sqrt(numAct)*(rand(criticLayerSizes(2),numAct)-0.5), ...
                'Bias', 2/sqrt(numAct)*(rand(criticLayerSizes(2),1)-0.5))
        ];
    commonPath1 = [
        additionLayer(2,'Name','add')
        reluLayer('Name','CriticCommonRelu1')
        fullyConnectedLayer(1, 'Name', 'CriticOutput', ...
                'Weights', 2*5e-3*(rand(1,criticLayerSizes(2))-0.5), ...
                'Bias', 2*5e-3*(rand(1,1)-0.5))
        ];

    % Connect layers into the first critic network
    criticNetwork1 = layerGraph(statePath1);
    criticNetwork1 = addLayers(criticNetwork1, actionPath1);
    criticNetwork1 = addLayers(criticNetwork1, commonPath1);
    criticNetwork1 = connectLayers(criticNetwork1,'CriticStateFC2','add/in1');
    criticNetwork1 = connectLayers(criticNetwork1,'CriticActionFC1','add/in2');

    % Define layers for the second critic network (similar to first)
    statePath2 = [
        featureInputLayer(numObs,'Normalization','none','Name', 'observation')
        fullyConnectedLayer(criticLayerSizes(1), 'Name', 'CriticStateFC1', ...
                'Weights', 2/sqrt(numObs)*(rand(criticLayerSizes(1),numObs)-0.5), ...
                'Bias', 2/sqrt(numObs)*(rand(criticLayerSizes(1),1)-0.5))
        reluLayer('Name','CriticStateRelu1')
        fullyConnectedLayer(criticLayerSizes(2), 'Name', 'CriticStateFC2', ...
                'Weights', 2/sqrt(criticLayerSizes(1))*(rand(criticLayerSizes(2),criticLayerSizes(1))-0.5), ...
                'Bias', 2/sqrt(criticLayerSizes(1))*(rand(criticLayerSizes(2),1)-0.5))
        ];
    actionPath2 = [
        featureInputLayer(numAct,'Normalization','none', 'Name', 'action')
        fullyConnectedLayer(criticLayerSizes(2), 'Name', 'CriticActionFC1', ...
                'Weights', 2/sqrt(numAct)*(rand(criticLayerSizes(2),numAct)-0.5), ...
                'Bias', 2/sqrt(numAct)*(rand(criticLayerSizes(2),1)-0.5))
        ];
    commonPath2 = [
        additionLayer(2,'Name','add')
        reluLayer('Name','CriticCommonRelu1')
        fullyConnectedLayer(1, 'Name', 'CriticOutput', ...
                'Weights', 2*5e-3*(rand(1,criticLayerSizes(2))-0.5), ...
                'Bias', 2*5e-3*(rand(1,1)-0.5))
        ];

    % Connect layers into the second critic network
    criticNetwork2 = layerGraph(statePath2);
    criticNetwork2 = addLayers(criticNetwork2, actionPath2);
    criticNetwork2 = addLayers(criticNetwork2, commonPath2);
    criticNetwork2 = connectLayers(criticNetwork2,'CriticStateFC2','add/in1');
    criticNetwork2 = connectLayers(criticNetwork2,'CriticActionFC1','add/in2');

    %% ACTOR NETWORK FOR TD3
    actorLayerSizes = [400 300];
    actorNetwork = [
        featureInputLayer(numObs, 'Normalization', 'none', 'Name', 'observation')
        fullyConnectedLayer(actorLayerSizes(1), 'Name', 'ActorFC1', ...
                'Weights', 2/sqrt(numObs)*(rand(actorLayerSizes(1), numObs) - 0.5), ...
                'Bias', 2/sqrt(numObs)*(rand(actorLayerSizes(1), 1) - 0.5))
        reluLayer('Name', 'ActorRelu1')
        fullyConnectedLayer(actorLayerSizes(2), 'Name', 'ActorFC2', ...
                'Weights', 2/sqrt(actorLayerSizes(1))*(rand(actorLayerSizes(2), actorLayerSizes(1)) - 0.5), ...
                'Bias', 2/sqrt(actorLayerSizes(1))*(rand(actorLayerSizes(2), 1) - 0.5))
        reluLayer('Name', 'ActorRelu2')
        fullyConnectedLayer(numAct, 'Name', 'ActorFC3', ...
                'Weights', 2*5e-3*(rand(numAct, actorLayerSizes(2)) - 0.5), ...
                'Bias', 2*5e-3*(rand(numAct, 1) - 0.5))
        tanhLayer('Name', 'ActorTanh1')
        ];

    %% ACTOR NETWORK FOR SAC (Separate mean and std paths)
    % Common Path for shared layers
    commonPath = [
        featureInputLayer(numObs, 'Normalization', 'none', 'Name', 'observation')
        fullyConnectedLayer(128, 'Name', 'ActorFC1', ...
                'Weights', 2/sqrt(numObs)*(rand(128, numObs) - 0.5), ...
                'Bias', 2/sqrt(numObs)*(rand(128, 1) - 0.5))
        reluLayer('Name', 'ActorRelu1')
        fullyConnectedLayer(64, 'Name', 'ActorFC2', ...
                'Weights', 2/sqrt(128)*(rand(64, 128) - 0.5), ...
                'Bias', 2/sqrt(128)*(rand(64, 1) - 0.5))
        reluLayer('Name', 'ActorRelu2')
        ];

    % Mean Path for action mean output
    meanPath = [
        fullyConnectedLayer(32, 'Name', "meanFC")
        reluLayer
        fullyConnectedLayer(numAct, 'Name', "actionMean")
        ];

    % Std Path for action standard deviation output
    stdPath = [
        fullyConnectedLayer(numAct, 'Name', "stdFC")
        reluLayer
        softplusLayer('Name', "actionStd")
        ];

    % Assemble the SAC actor network
    actorNet = layerGraph(commonPath);
    actorNet = addLayers(actorNet, meanPath);
    actorNet = addLayers(actorNet, stdPath);
    actorNet = connectLayers(actorNet, "ActorRelu2", "meanFC/in");
    actorNet = connectLayers(actorNet, "ActorRelu2", "stdFC/in");

    % Initialize network parameters
    actorNet = dlnetwork(actorNet);
    actorNet = initialize(actorNet);

end

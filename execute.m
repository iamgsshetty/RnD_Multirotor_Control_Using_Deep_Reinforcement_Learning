mdl = "waypoint_follow";
open_system(mdl)

actionInfo = rlNumericSpec([3 1], ...
    LowerLimit = -1', ...
    UpperLimit = 1');
actionInfo.Name = "control";
actionInfo.Description = "roll, pitch, yawrate and thrust";

observationInfo = rlNumericSpec([13 1]);
observationInfo.Name = "obs";
observationInfo.Description = "pos, vel, orientation, ang vel, thrust";

env = rlSimulinkEnv(mdl, mdl + "/RL Agent", observationInfo, actionInfo);

env.ResetFcn = @(in)localResetFcn(in);

obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

numObs = 13;
numAct = 3;
% agent = rlTD3Agent(observationInfo,actInfo);
% agent = createSACAgent(numObs,obsInfo,numAct,actInfo,0.01);
% agent = createDDPGAgent(numObs,obsInfo,numAct,actInfo,0.01);
Ts = 0.01;
Ts_agent = Ts;

T = 10.0;
maxepisodes = 2500;
maxsteps = ceil(T/Ts_agent); 
trainOpts = rlTrainingOptions(...
    MaxEpisodes=maxepisodes, ...
    MaxStepsPerEpisode=maxsteps, ...
    StopTrainingCriteria="None",...
    ScoreAveragingWindowLength=500, ...
    Verbose=1, ...
    UseParallel=true); 
trainOpts.SaveAgentCriteria = 'EpisodeFrequency';
trainOpts.SaveAgentValue = 250000;
% trainOpts.SaveAgentDirectory = '/savedAgents/td3';
trainOpts.ParallelizationOptions.Mode = 'async';
% evaluator = rlEvaluator(...
%     NumEpisodes=3,...
%     EvaluationFrequency=100);
parpool(4);
doTraining = false;
if doTraining
    % agent = createTD3Agent(numObs,obsInfo,numAct,actInfo,0.01);
    % trainResult_td3 = train(agent, env, trainOpts);
    % save("TD3agent.mat", "agent");
    % save("trainResult_td3");
    agent = createDDPGAgent(numObs,obsInfo,numAct,actInfo,0.01);
    % agent_loaded = load("DDPGagent.mat");
    trainResult_ddpg = train(agent, env, trainOpts);
    save("trainResult_ddpg");
    save("DDPGagent.mat", "agent");
    % agent = createSACAgent(numObs,obsInfo,numAct,actInfo,0.01);
    % trainResult_sac = train(agent, env, trainOpts);
    % save("SACagent.mat", "agent");
    % save("trainResult_sac");
else
    % agent_loaded = load("TD3agent.mat");
    agent = load("TD3agent.mat").agent;
    % resize(agent.ExperienceBuffer,5e6);
    trainResult_sac = train(agent, env, trainOpts);
    save("TD3agent.mat", "agent");
    save("trainResult_td3");
    
end
delete(gcp('nocreate'));

% sac summary(actorNet);
% 
%    Initialized: true
% 
%    Number of learnables: 12k
% 
%    Inputs:
%       1   'observation'   10 features
% 
%       summary(criticNet);
% 
%    Initialized: true
% 
%    Number of learnables: 126.2k
% 
%    Inputs:
%       1   'observation'   10 features
%       2   'action'        3 features
% 
%     TD3 DDPG 
% summary(criticNet);
% 
%    Initialized: true
% 
%    Number of learnables: 126.2k
% 
%    Inputs:
%       1   'observation'   10 features
%       2   'action'        3 features
% 
%  summary(actorNet);
% 
%    Initialized: true
% 
%    Number of learnables: 125.6k
% 
%    Inputs:
%       1   'observation'   10 features     
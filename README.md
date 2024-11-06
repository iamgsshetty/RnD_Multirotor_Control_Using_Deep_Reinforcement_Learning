# Multirotor Agent Training and Testing Repository

This repository contains MATLAB scripts and models for training, testing, and evaluating reinforcement learning agents designed to control a multirotor aerial robot. Below is a description of each file and its role within the project.

---

### Table of Contents
1. [Files Overview](#files-overview)
2. [Usage Instructions](#usage-instructions)
3. [License](#license)

---

## Files Overview

### 1. `execute.m`
This script initiates the training process for the agent. It contains the code necessary to start training any of the agent types (SSE, TD3, or DDPG) defined within this repository.

### 2. `create-sse-agent.m`, `create-td3-agent.m`, `create-ddpg-agent.m`
Each of these scripts is responsible for creating a specific type of reinforcement learning agent:
   - `create-sse-agent.m`: Defines and initializes the SSE (Stochastic State Estimation) agent.
   - `create-td3-agent.m`: Defines and initializes the TD3 (Twin Delayed Deep Deterministic Policy Gradient) agent.
   - `create-ddpg-agent.m`: Defines and initializes the DDPG (Deep Deterministic Policy Gradient) agent.

### 3. `create-networks.m`
This script creates the actor and critic neural networks used by the agents for decision-making. These networks form the backbone of the reinforcement learning model, enabling the agents to evaluate actions and learn effective control policies.

### 4. `local-reset-function.m`
The local reset function is responsible for randomizing the multirotor's initial state and its target waypoints. This is crucial for ensuring the agent learns a robust policy that can handle various initial conditions and destinations.

### 5. `test-agent.m`
This script is used to test the effectiveness of the trained agents in controlling the multirotor. It allows for performance evaluation of the agent's behavior in various scenarios, verifying whether the training has been successful.

### 6. `ddpg-agent.mat`, `sse-agent.mat`, `td3-agent.mat`
These `.mat` files store the fully-trained DDPG, SSE, and TD3 agents, respectively. They contain the saved state of each trained model, allowing for immediate deployment and testing without the need for retraining.

### 7. `test-result-visualizer.m`, `trajectory-plotting.m`, `compare-result.m`
These visualization and evaluation scripts provide insights into the performance of the trained agents:
   - `test-result-visualizer.m`: Visualizes the outcomes of the agent's test runs.
   - `trajectory-plotting.m`: Plots the trajectory of the multirotor to analyze its path.
   - `compare-result.m`: Compares results between different agents or tests to assess their relative effectiveness.

### 8. `waypoint_followed.slx`
This Simulink model is used for training the multirotor aerial robot. It provides a simulated environment and control architecture for testing and training the reinforcement learning agents in MATLAB/Simulink.

---

## Usage Instructions

1. **Training an Agent**: Run `execute.m` to begin the training process for your selected agent type.
2. **Testing an Agent**: Use `test-agent.m` to evaluate the performance of a trained agent.
3. **Visualization**: Utilize `test-result-visualizer.m`, `trajectory-plotting.m`, and `compare-result.m` to visualize and compare the results.

---

## License

This repository is open-source. Please refer to the LICENSE file for more details. 

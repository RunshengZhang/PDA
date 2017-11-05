% Set Algorithm Parameters
% Yunyi
% Oct 29

function algo = set_algorithm_param()

%   1. Population
%       Typical value should be 3-5 times block number
algo.NP = 3;

%   2. Iteration
%       For better convergence, typical value should be around twice NP
algo.itermax = 5;

%   3. Acceptance Probability (AP)
%       Decide the probability of choosing an inferior indivudual which has higher objective value;
%       range = [0,1], typical value should be less than 0.1
algo.AP = 0.05;

%   4. Dead Space (DS)
%       Decide the area constraint in terms of percentage dead space;
%       It is calculated as the dead space area divided by total placement area (in percentage)
%       range = (0,100), typical value should be (5,10)
algo.DS = 10;

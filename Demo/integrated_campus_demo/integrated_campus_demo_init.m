%% Integrated Campus Demo Initialization Script
% This script initializes the demo by creating some required input files.
%
% Run this script prior to running the Simulink simulation.

%% Initialize Weather Data
% Pulls in TMY3-formatted weather file for June 2012 in Golden, CO

% Use convertTMY3() conversion utility -> result in 'ans' variable
convertTMY3('201206ty.csv', 'offset', 0);

% Save resulting structures of time series to file
% Notes:
%   1. The name 'ans' is required by Simulink to import data using a 'From
%      File' block
%   2. A version 7.3 .MAT file is required for Simulink to properly read
%      the time series object. This is NOT the default version which MATLAB
%      saves, so be careful.
save('Weather.mat', 'ans', '-v7.3');
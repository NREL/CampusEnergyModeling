%% Weather Demo Initialization Script
% This script initializes the demo by creating time series .MAT files of
% weather data from TMY3-formatted sources. When used with appropriate bus
% definitions, These .MAT files are compatible with the Simulink 'From
% File' block.
%
% Run this script prior to running the Simulink simulation.

%% Convert TMY3 Weather Files to MATLAB Time Series
% Use convertTMY3() conversion utility
tmy3 = convertTMY3('724666TY.csv', 'offset', 0);	% TMY3 data - full year
month = convertTMY3('201206ty.csv', 'offset', 0);	% Actual data - 1 month

% Save resulting structures of time series to file
% Notes:
%   1. The name 'ans' is required by Simulink to import data using a 'From
%      File' block
%   2. A version 7.3 .MAT file is required for Simulink to properly read
%      the time series object. This is NOT the default version which MATLAB
%      saves, so be careful.
ans = tmy3;     save('TMY3.mat', 'ans', '-v7.3');
ans = month;    save('Month.mat', 'ans', '-v7.3');
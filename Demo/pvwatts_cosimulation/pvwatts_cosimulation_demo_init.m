%% PVWatts Cosimulation Demo Initialization Script
% This script initializes the demo by creating a time series .MAT files of
% weather data from a TMY3-formatted source.
%
% Run this script prior to running the Simulink simulation.

%% Convert TMY3 Weather Files to MATLAB Time Series
% Use convertTMY3() conversion utility
convertTMY3('201206ty.csv', 'offset', 0);
save('Weather.mat', 'ans', '-v7.3'); 
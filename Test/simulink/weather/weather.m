%% weather.m - Test the Weather block in the Simulink library
%
% This script tests the 'Weather' block in the Campus Energy Modeling
% Simulink library using three different data sources. The test verifies
% that (a) a model containing the weather block will execute successfully,
% and (b) that the data read is consistent with the original data.
%
% FUNCTIONS:
%   utilities: convertTMY3
%
% SIMULINK BLOCKS:
%   Weather
%
% COMMENTS:
%   1. The name 'ans' is required by Simulink to import data using a 'From
%      File' block.
%
%   2. A version 7.3 .MAT file is required for Simulink to properly read
%      the time series object. This is NOT the default version which MATLAB
%      saves, so it must be specified.

%% Setup
% Name of Simulink model
mdl = 'read_weather_data';

%% TMY3 Weather Data
% Weather file
weatherFile = ['..' filesep '..' filesep 'data' filesep '724666TY.csv'];

% Get data from convertTMY3() conversion utility
% (Places result in 'ans')
weatherData = convertTMY3(weatherFile, 'offset', -1);

% Save to file in 'ans' variable
ans = weatherData;
save('weatherData.mat', 'ans', '-v7.3');

% Initialize model
open_system(mdl);

% Adjust model settings
set_param( mdl, ...
    'FixedStep',    '3600'          , ...   % 1 hour
    'StartTime',    '0'             , ...
    'StopTime',     '8759*3600'     );      % 1 year (8760 hours)

% Execute model
sim(mdl);

% Compare results
diff = (dryBulb - weatherData.DryBulbTemp);
assert( all(diff.Data == 0), ...
    'weather:dataMismatch', ...
    ['Mismatch between original weather data and data returned from ' ...
    'Simulink ''Weather'' block'] );

%% TMY3-formatted Weather Data
% Weather file
weatherFile = ['..' filesep '..' filesep 'data' filesep '201206ty.csv'];

% Get data from convertTMY3() conversion utility
% (Places result in 'ans')
weatherData = convertTMY3(weatherFile, 'offset', -1);

% Save to file in 'ans' variable
ans = weatherData;
save('weatherData.mat', 'ans', '-v7.3');

% Force reinitialization by closing/opening
% (Required b/c the bus definition may have changed and Simulink needs to
%  pick up on that.)
close_system(mdl, 0);
open_system(mdl);

% Adjust model settings
set_param( mdl, ...
    'FixedStep',    '3600'              , ...   % 1 hour
    'StartTime',    '0'                 , ...
    'StopTime',     '(30*24-1)*3600'    );      % 30 days

% Execute model
sim(mdl);

% Compare results
diff = (dryBulb - weatherData.DryBulbTemp);
assert( all(diff.Data == 0), ...
    'weather:dataMismatch', ...
    ['Mismatch between original weather data and data returned from ' ...
    'Simulink ''Weather'' block'] );


%% Synthesized Weather Data
% Create weather data; output to file
open_system('create_weather_data');
sim('create_weather_data');
close_system('create_weather_data', 0);

% Load result
load('weatherData.mat');
weatherData = ans;

% Force reinitialization by closing/opening
% (Required b/c the bus definition changed and Simulink needs to pick up on
% that.)
close_system(mdl, 0);
open_system(mdl);

% Adjust model settings
set_param( mdl, ...
    'FixedStep',    '600'               , ...   % 10 min
    'StartTime',    '0'                 , ...
    'StopTime',     '(31*24)*3600'      );      % 31 days

% Execute model
sim(mdl);

% Compare results
diff = (dryBulb - weatherData.DryBulbTemp);
assert( all(diff.Data == 0), ...
    'weather:dataMismatch', ...
    ['Mismatch between original weather data and data returned from ' ...
    'Simulink ''Weather'' block'] );

%% Clean Up
% Close model
close_system(mdl, 0);
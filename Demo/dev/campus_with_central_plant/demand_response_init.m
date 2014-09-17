%% Demand Response Demo - Initialization Script
%
% This script initializes the demand response/demand management demo. The
% demo integrates an EnergyPlus model with (a) external weather data and
% (b) manual or automated demand response. The model runs for 24 hours.
%
% The weather data is drawn from NREL Solar Radiation Research Laboratory
% data for August 3, 2012 - a particularly warm day.
% 
% Run this script prior to executing the Simulink simulation. (You only
% need to run it once; the necessary files and settings will persist
% afterwards.)
%
% COMMENTS:
% 1. This initialization script stores weather data in the file
%    'Weather.mat'. If this file already exists, the script will not
%    recreate it. Therefore, you can easily override the weather data by
%    creating your own custom version of the file.
%
%    If you choose to do this, consult the block help for the 'Weather'
%    block (in the Campus Energy Modeling library) and the 'From File'
%    block (in the Simulink core library) for documentation regarding the
%    time series structure required for the weather data.
%
% 2. The simulation start time in Simulink is set to 172800 sec (2 days) so
%    that the simulation starts on Aug. 3. If desired, you may adjust the
%    simulation start and end times to change the date.
%
% 3. If you open the model prior to running this initialization script, you
%    may see a warning that the model is unable to automatically create the
%    bus definition for the weather data block. To correct, run this
%    script, which will automatically the model.
% 
% 4. If you wish to override the MLE+ settings, uncheck 'Use default MLE+
%    settings' in the 'MLE+' tab of the 'Small Office Building' block mask,
%    then enter the settings relevant to your local EnergyPlus
%    configuration.

%% Initialize Weather Data
% Output file
fname = 'Weather.mat';

% Read TMY3-formatted data
if ~exist(fname, 'file')
    % Use convertTMY3() conversion utility -> result in 'ans'
    dataFile = strjoin( ...
        {'..','..','Test','data','201208ty.csv'}, filesep );
    convertTMY3(dataFile);
    save(fname, 'ans', '-v7.3'); 
end

%% Initialize Simulink Model
% Open it if not open
open_system('demand_response');

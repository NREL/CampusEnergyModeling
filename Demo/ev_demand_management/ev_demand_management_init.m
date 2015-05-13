%% Demand Management using Electric Vehicles - Initialization Script
%
% This script initializes the demand management with electric vehicles
% demo.
% 
% The weather data is 1 minute data recorded at NREL's Solar Radiation
% Research Laboratory (SRRL) on May 17, 2012. The simulation time step is
% set to 15 seconds.
%
% Run this script prior to executing the Simulink simulation. (You only
% need to run it once; the necessary files and settings will persist
% afterwards.)
%
% COMMENTS:
% 1. Vary the value of the "Demand Limit" block to view the effect of
%    various demand limits on the system behavior. Try 25 kW, 20 kW, 15 kW,
%    and 10 kW to start.
%
% 2. This initialization script stores weather data in the file
%    'Weather.mat'. If this file already exists, the script will not
%    recreate it. Therefore, you can easily override the weather data by
%    creating your own custom version of the file.
%
%    If you choose to do this, consult the block help for the 'Weather'
%    block (in the Campus Energy Modeling library) and the 'From File'
%    block (in the Simulink core library) for documentation regarding the
%    time series structure required for the weather data.
%
% 3. If you open the model prior to running this initialization script, you
%    may see a warning that the model is unable to automatically create the
%    bus definition for the weather data block. To correct, run this
%    script, then reopen the model.

%% Initialize Weather Data
% Output file
fname = 'Weather.mat';

% Read TMY3-formatted data
if ~exist(fname, 'file')
    % Use convertTMY3() conversion utility -> result in 'ans'
    dataFile = strjoin( ...
        {'..','..','Test','data','20120517_1min.csv'}, filesep );
    convertTMY3(dataFile,'--UseOriginalTimestamps');
    save(fname, 'ans', '-v7.3'); 
end

%% Initialize Simulink Model
% System name
sys = 'ev_demand_management';

% Open it if not open
open_system(sys);

% Weather file from before
weatherFile = fname;

% Set timestep and simulation duration
timestep = 15;
dur = 86400;

% Set settings and block parameters
set_param(sys, ...
    'StartTime', num2str(0), ...
    'StopTime', num2str(dur), ...
    'FixedStep', num2str(timestep) );
set_param([sys '/PV Array/PVWatts'], ...
    'time_step', num2str(timestep) );

% Start time: Midnight MST, May 17
set_param([sys '/PV Array/PVWatts'], ...
    'start_time', '2012-05-17 00:00:00');

% Weather File
set_param([sys '/Weather'], ...
    'fname', weatherFile );

% Set EV charging limit (easy way to modify all 5 at once)
chgPwr = 6.6e3;
for i = 1:5
    % Charger limit in charging station
    blk = [sys '/Electric Vehicles/EV Station ' int2str(i) '/AC Charging Station'];
    set_param( blk, 'prated', num2str(chgPwr) );
end

% Save result
save_system(sys);

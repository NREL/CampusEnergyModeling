%% Demand Management using Electric Vehicles - Initialization Script
%
% This script initializes the demang management with electric vehicles
% demo. Two weather scenaiors are available:
%
% 1. SRRL: This scenario uses 1 minute data recorded at NREL's Solar
%    Radiation Research Laboratory (SRRL) on May 17, 2012. For this
%    scenario, the simulation time step is set to 15 seconds.
%
% 2. DataBus: This scenario uses high frequency solar radiation data for
%    June 1, 2013, downloaded from NREL's DataBus database using the
%    batchDataBus() utility function. For this scenario, the simulation
%    time step is set to 1 second. Caution! This scenario takes
%    approximately 15 times longer to run.
%
% Modify the user settings below to select a scenario, then run this script
% prior to running the Simulink simulation. (You only need to run it once
% per scenario; the necessary files and settings will persist afterwards.)
%
% COMMENTS:
% 1. Vary the value of the "Demand Limit" block to view the effect of
%    various demand limits on the system behavior. Try 25 kW, 20 kW, 15 kW,
%    and 10 kW to start.
%
% 2. This initialization script stores weather data for the SRRL and
%    DataBus scenarios in the files 'Weather-SRRL.mat' and
%    'Weather-DataBus.mat', respectively. If these files already exist, the
%    script will not recreate them. Therefore, you can easily override the
%    weather data for each scenario by creating your own custom version of
%    either file.
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

%% User Settings
% Scenario selection: please specify either 'srrl' or 'databus'
scen = 'srrl';

%% Check Inputs
% Check for proper scenario
scen = lower(scen);
assert( any( strcmpi(scen, {'srrl','databus'}) ), ...
    'CampusModeling:demo:invalidScenario', ...
    ['No scenario named ''' scen ''' exists; ' ...
    'cannot initialize the demo.']);

%% Initialize Weather Data
% Data source depends on scenario
switch scen  
    % SRRL
    case 'srrl'
        fname = 'Weather-SRRL.mat';
        if ~exist(fname, 'file')
            % Use convertTMY3() conversion utility -> result in 'ans'
            dataFile = strjoin( ...
                {'..','..','Test','data','20120517_1min.csv'}, filesep );
            convertTMY3(dataFile,'--UseOriginalTimestamps');
            save(fname, 'ans', '-v7.3'); 
        end
        
    % DataBus
    case 'databus'
        fname = 'Weather-DataBus.mat';
        if ~exist(fname, 'file')
            % Time stamps for data to retrieve (yyyy-mm-dd HH:MM:SS)
            start = '2013-06-01 00:00:00';
            stop  = '2013-06-02 00:00:00';

            % Batch import from databus -> result in 'ans'
            sensorFile = 'DataBus_sensors.csv';
            batchDataBus(sensorFile, start, stop, 'timezone', -6);
            save(fname, 'ans', '-v7.3');
        end        
end

%% Initialize Simulink Model
% System name
sys = 'ev_demand_management';

% Open it if not open
open_system(sys);

% Weather file from before
weatherFile = fname;

% Set timestep and simulation duration
switch scen
    % SRRL - 60 second timestep
    case 'srrl'
        timestep = 15;
        dur = 86400;
    
    % DataBus - ~3 second timestep
    case 'databus'
        timestep = 1;
        dur = 86400;
end

% Set settings and block parameters
set_param(sys, ...
    'StartTime', num2str(0), ...
    'StopTime', num2str(dur), ...
    'FixedStep', num2str(timestep) );
set_param([sys '/PV Array/PVWatts'], ...
    'time_step', num2str(timestep) );
if strcmpi(scen, 'srrl')
    % Start time: Midnight MST, May 17
    set_param([sys '/PV Array/PVWatts'], ...
        'start_time', '2012-05-17 00:00:00');
else
    % Start time: Midnight MDT, June 1 (Equal to 11 PM MST prior day)
    set_param([sys '/PV Array/PVWatts'], ...
        'start_time', '2013-05-31 23:00:00');
end
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

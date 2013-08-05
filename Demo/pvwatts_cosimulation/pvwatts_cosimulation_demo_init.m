%% PVWatts Cosimulation Demo Initialization Script
% This script initializes the PVWatts cosimulation demo. Both short-term
% and long-term scenarios are available. The scenarios differ by weather
% data and simulation settings:
%
% 1. Short-term: This scenario models 24 hours of PV operation at a 10
%    second time step. The weather data for this scenario will be
%    downloaded from DataBus using the interactive utility function
%    importDataBus() when this script executes; please read and follow the
%    prompts in the MATLAB command window.
%
% 2. Long-term: This scenario models 1 month of PV operation at a 10 minute
%    time step. The weather data is drawn from a TMY3-formatted weather
%    file (included with this demo).
%
% Modify the user settings below to select a scenario, then run this script
% prior to running the Simulink simulation. (You only need to run it once; 
% the necessary files and settings will persist afterwards.)
%
% NOTE: The DC and AC powers are output as vectors to the MATLAB workspace.
% You can plot the inverter efficiency characteristic using:
%    eff = ac_power ./ dc_power;
%    eff( ac_power <= 0) = 0;
%    plot(dc_power, eff);
% This plot can also be created directly in Simulink, but it severly slows
% down the simulation time.

%% User Settings
% Scenario selection: please specify either 'short' or 'long'
scen = 'long';

%% Check Inputs
% Check for proper scenario
assert( any( strcmpi(scen, {'short','long'}) ), ...
    'CampusModeling:demo:invalidScenario', ...
    ['No scenario named ''' scen ''' exists; ' ...
    'cannot initialize the demo.']);

%% Initialize Weather Data
% Data source depends on scenario
switch scen
    % Short-term
    case 'short'
        % Time stamps for data to retrieve (dd-mmm-yyyy HH:MM:SS)
        start = '01-Jun-2013 00:00:00';
        stop  = '02-Jun-2013 00:00:00';
        
        % Interactive import from databus -> result in 'ans' variable
        importDataBus('DataBus_sensors.csv', start, stop, 'timezone', -7);
        save('Weather.mat', 'ans', '-v7.3');
    
    % Long-term
    case 'long'
        % Use convertTMY3() conversion utility
        convertTMY3('201206ty.csv', 'offset', 0);
        save('Weather.mat', 'ans', '-v7.3'); 
        
end

%% Initialize Simulink Model
% Open it if not open
pvwatts_cosimulation;

% Set timestep and simulation duration
switch scen
    % Short-term
    case 'short'
        timestep = 1;
        PVtimestep = 10;
        dur = 3600*24;
    
    % Long-term
    case 'long'
        timestep = 15;
        PVtimestep = 600;
        dur = 30 * (3600*24);
        
end

% Set settings and block parameters
set_param('pvwatts_cosimulation', ...
    'StartTime', num2str(0), ...
    'StopTime', num2str(dur), ...
    'FixedStep', num2str(timestep) );
set_param('pvwatts_cosimulation/PVWatts Cosimulation', ...
    'time_step', num2str(PVtimestep) );
save_system;

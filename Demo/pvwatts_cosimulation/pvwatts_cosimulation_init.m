%% PVWatts Cosimulation Demo - Initialization Script
%
% This script initializes the PVWatts cosimulation demo. Both short-term
% and long-term scenarios are available. The scenarios differ by weather
% data and simulation settings:
%
% 1. Short-term: This scenario models 24 hours of PV operation at a 10
%    second time step. By default, the weather data for this scenario is
%    is 1 minute data recorded at NREL's Solar Radiation Research
%    Laboratory (SRRL) on May 17, 2012.
%
% 2. Long-term: This scenario models 1 month of PV operation at a 10 minute
%    time step. By default, the weather data is drawn from a TMY3-formatted
%    file of Solar Radiation Research Laboratory (SRRL) weather data for
%    Golden, CO (included with the Campus Energy Modeling library test
%    data).
%
% Modify the user settings below to select a scenario, then run this script
% prior to running the Simulink simulation. (You only need to run it once
% per scenario; the necessary files and settings will persist afterwards.)
%
% COMMENTS:
% 1. The DC and AC powers are output as vectors to the MATLAB workspace.
%    After running the simulation, you can plot the inverter efficiency
%    characteristic using:
%      eff = ac_power ./ dc_power;
%      eff(ac_power <= 0) = 0;
%      plot(dc_power, eff);
%    This plot can also be created directly in Simulink, but it severly
%    slows down the simulation time.
% 
% 2. This initialization script stores weather data for the short and long
%    scenarios in the files 'Weather-short.mat' and 'Weather-long.mat',
%    respectively. If these files already exist, the script will not
%    recreate them. Therefore, you can easily override the weather data for
%    each scenario by creating your own custom version of either file.
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
%
% 4. After changing scenarios, you may need to use the Autoscale feature
%    in the Simulink oscilloscopes to resize the scope view to fit the
%    data.

%% User Settings
% Scenario selection: please specify either 'short' or 'long'
scen = 'short';

%% Check Inputs
% Check for proper scenario
scen = lower(scen);
assert( any( strcmpi(scen, {'short','long'}) ), ...
    'CampusModeling:demo:invalidScenario', ...
    ['No scenario named ''' scen ''' exists; ' ...
    'cannot initialize the demo.']);

%% Initialize Weather Data
% Data source depends on scenario
switch scen
    % Short-term
    case 'short'
        fname = 'Weather-short.mat';
        if ~exist(fname, 'file')
            % Use convertTMY3() conversion utility -> result in 'ans'
            dataFile = strjoin( ...
                {'..','..','Test','data','20120517_1min.csv'}, filesep );
            convertTMY3(dataFile,'--UseOriginalTimestamps');
            save(fname, 'ans', '-v7.3'); 
        end
    
    % Long-term
    case 'long'
        fname = 'Weather-long.mat';
        if ~exist(fname, 'file')
            % Use convertTMY3() conversion utility -> result in 'ans'
            dataFile = strjoin( ...
                {'..','..','Test','data','201206ty.csv'}, filesep );
            convertTMY3(dataFile);
            save(fname, 'ans', '-v7.3'); 
        end
        
end

%% Initialize Simulink Model
% Open it if not open
open_system('pvwatts_cosimulation');

% Set timestep and simulation duration
switch scen
    % Short-term - 1 day
    case 'short'
        timestep = 1;
        PVtimestep = 10;
        dur = 3600*24;
        weatherFile = 'Weather-short.mat';
    
    % Long-term - 30 days
    case 'long'
        timestep = 15;
        PVtimestep = 600;
        dur = 30 * (3600*24);
        weatherFile = 'Weather-long.mat';
        
end

% Set settings and block parameters
set_param('pvwatts_cosimulation', ...
    'StartTime', num2str(0), ...
    'StopTime', num2str(dur), ...
    'FixedStep', num2str(timestep) );
set_param('pvwatts_cosimulation/PVWatts Cosimulation', ...
    'time_step', num2str(PVtimestep) );
set_param('pvwatts_cosimulation/Weather', ...
    'fname', weatherFile );

% Save result
save_system('pvwatts_cosimulation');

%% Integrated Campus Demo - Initialization Script
%
% This script initializes the demo by creating required input files for the
% weather data and configuring the parameters for the MLE+ blocks. Two
% different weather sources are available:
% 
% 1. SRRL: Weather data is drawn from a TMY3-formatted file of Solar
%    Radiation Research Laboratory (SRRL) weather data for Golden, CO
%    (included with the Campus Energy Modeling library test data).
%
% 2. DataBus: Weather data downloaded from NREL's DataBus database using
%    the batchDataBus() utility function.
%
% Modify the user settings below to select a data source, then run this
% script prior to running the Simulink simulation. (You only need to run it
% once; the necessary files and settings will persist afterwards.) Note
% that users external to NREL do not have access to NREL's DataBus
% database. 
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
%    Also note that switching from one data source to the other requires
%    manual deletion of any existing version of 'Weather.mat'.
%
% 2. If you open the model prior to running this initialization script, you
%    may see a warning that the model is unable to automatically create the
%    bus definition for the weather data block. To correct, run this
%    script, then reopen the model.
%
% 3. This demo requires a custom EnergyPlus build, 8.0.1, supplied by Brent
%    Griffith in July, 2013. It does NOT work with EnergyPlus 8.1.0; MLE+
%    experiences packet errors.
%
%    By default, the blocks expect this custom build in the directory
%    'C:\EnergyPlusV8-0-1\'. If your build is in a different directory,
%    edit the each MLE+ block under the 'Campus Thermal Model' subsystem
%    accordingly:
%       a. Open the block mask
%       b. In the 'MLE+' tab, ensure 'Use default MLE+ settings' is
%          unchecked.
%       c. Specify the full path to the EnergyPlus 8.0.1 batch script in
%          the 'EnergyPlus executable path' field.   
%    See the MLE+ block help for details.
%
% 4. This demo requires the weather file 'USA_CO_Golden-NREL.724666_TMY3',
%    which is included with EnergyPlus by default.

%% User Settings
% Please modify these as needed to match your local configuration...

% Data source: please specify either 'SRRL' or 'DataBus'
dSource = 'DataBus';

%% Initialize Weather Data
% Output
fname = 'Weather.mat';

% Select by data source
switch lower(dSource)
    % SRRL
    case 'srrl'
        if ~exist(fname, 'file')
            % Use convertTMY3() conversion utility -> result in 'ans'
            dataFile = strjoin( ...
                {'..','..','Test','data','201206ty.csv'}, filesep );
            convertTMY3(dataFile);
            save(fname, 'ans', '-v7.3'); 
        end
    
    % DataBus
    case 'databus'
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

%% Initialize Pricing Data
initPricingData;

% TEST: Plot the resulting time series
% hold on
% plot(ans.GHI,'-b')
% plot(ans.DNI,'-r')
% plot(ans.DHI,'-g')
% hold off

%% Set MLE+ Block Parameters
% Model name
sys = 'integrated_campus_demo';

% Open model if not open
open_system(sys);

% Setup
blkList = {'E+ Plant','E+ Building 1','E+ Building 2'};

% Loop through blocks to set common elements
for n = blkList
    % Simulink object name
    objName = [sys '/Campus Thermal Model/' n{:}];
    
    % Set Param - Time step
    param = 'time_step';
    value = '60';
    set_param(objName, param, value);
    
    % Set Param - Baseline weather file
    param = 'weather_profile';
    value = 'USA_CO_Golden-NREL.724666_TMY3';
    set_param(objName, param, value);
    
end

%% Save System
% Save result
save_system(sys);
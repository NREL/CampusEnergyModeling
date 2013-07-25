%% Integrated Campus Demo Initialization Script
% This script initializes the demo by creating required input files for the
% weather data. And configuring the parameters for the MLE+ blocks. Note
% that downloading DataBus data is an interactive process requiring the
% user to save files from a web browser to .CSV and pass the resulting file
% name back to MATLAB.
%
% Run this script prior to running the Simulink simulation. (You only need
% to run it once; the necessary files and settings will persist afterwards.)
%
% To switch to DataBus data instead of the included TMY3 data, modify the
% variables as needed under the 'Retrieve DataBus Weather Data' section and
% re-run the script. Also, remember to change the weather block in Simulink
% to point to 'Weather2.mat'.

%% User Settings
% Please modify these as needed to match your local configuration...

% Change to 'true' to download and use DataBus data
% NOTE: Also remember to switch to 'Weather2.mat' in the Simulink model!
useDataBus = false;

% Set EnergyPlus path
% NOTE: This needs to be Brent's customized 8.0.1 build or greater to work!
ePlusPath = 'C:\EnergyPlusV8-0-1\RunEPlus.bat';

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

%% Retrieve DataBus Weather Data
% Pulling data from DataBus into MATLAB is tricky; direct methods fail for
% cryptic and unsolveable reasons:
%   urlread()       SSL errors and authentication errors (even w/ correct
%                   credentials)
%   web()           Locks up MATLAB when using MATLAB's internal browser
%   
% Instead, this script uses an interactive approach which prompts the user
% to download each data stream to .CSV, then parses the result.
% Run the interactive function to retrieve and use DataBus data

if useDataBus
    % Time stamps for data to retrieve (dd-mmm-yyyy HH:MM:SS)
    start = '01-Jun-2013 00:00:00';
    stop  = '02-Jun-2013 00:00:00';


    % Interactive import from databus -> result in 'ans' variable
    importDataBus('DataBus_sensors.csv', start, stop, 'timezone', -7);

    % Save resulting structures of time series to file
    % Notes:
    %   1. The name 'ans' is required by Simulink to import data using a
    %      'From File' block
    %   2. A version 7.3 .MAT file is required for Simulink to properly 
    %      read the time series object. This is NOT the default version
    %      which MATLAB saves, so be careful.
    save('Weather2.mat', 'ans', '-v7.3');
    
end

% TEST: Plot the resulting time series
% hold on
% plot(ans.GHI,'-b')
% plot(ans.DNI,'-r')
% plot(ans.DHI,'-g')
% hold off

%% Set MLE+ Block Parameters
% Setup
fileName = 'integrated_campus';
blkList = {'E+ Plant','E+ Building 1','E+ Building 2'};

% Loop through blocks to set common elements
for n = blkList
    % Simulink object name
    objName = [fileName '/Campus Thermal Model/' n{:}];
    
    % Set Param - EnergyPlus batch file (modify as needed)
    param = 'progname';
    value = ['''' ePlusPath ''''];
    set_param(objName,param,value);

    % Set Param - Time step
    param = 'deltaT';
    value = '60';
    set_param(objName,param,value);

    % Set Param - Baseline weather file
    param = 'weatherfile';
    value = '''USA_CO_Golden-NREL.724666_TMY3''';
    set_param(objName,param,value);

    % Set Param - Number EnergyPlus outputs
    param = 'noutputd';
    value = '13';
    set_param(objName,param,value);
end

% Set Chiller-specific parameters
objName = [fileName '/Campus Thermal Model/E+ Plant'];
    % Set Param - EnergyPlus model file
    param = 'modelfile';
    value = '[pwd ''\ElectricChiller\ElectricChiller'']';
    set_param(objName,param,value);

    % Set Param - EnergyPlus working directory
    param = 'workdir';
    value = '[pwd ''\ElectricChiller'']';
    set_param(objName,param,value);

% Set Building 1-specific parameters
objName = [fileName '/Campus Thermal Model/E+ Building 1'];
    % Set Param - EnergyPlus model file
    param = 'modelfile';
    value = '[pwd ''\Building1\5ZoneAirCool'']';
    set_param(objName,param,value);

    % Set Param - EnergyPlus working directory
    param = 'workdir';
    value = '[pwd ''\Building1'']';
    set_param(objName,param,value);

% Set Building 2-specific parameters
objName = [fileName '/Campus Thermal Model/E+ Building 2'];
    % Set Param - EnergyPlus model file
    param = 'modelfile';
    value = '[pwd ''\Building2\5ZoneAirCool'']';
    set_param(objName,param,value);

    % Set Param - EnergyPlus working directory
    param = 'workdir';
    value = '[pwd ''\Building2'']';
    set_param(objName,param,value);
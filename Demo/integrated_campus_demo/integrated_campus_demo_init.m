%% Integrated Campus Demo Initialization Script
% This script initializes the demo by creating required input files for the
% weather data. Note that downloading DataBus data is an interactive
% process requiring the user to save files from a web browser to .CSV and
% pass the resulting file name back to MATLAB.
%
% Run this script prior to running the Simulink simulation. (You only need
% to run it once; the necessary files will persist afterwards.)
%
% To switch to DataBus data instead of the included TMY3 data, modify the
% variables as needed under the 'Retrieve DataBus Weather Data' section and
% re-run the script. Also, remember to change the weather block in Simulink
% to point to 'Weather2.mat'.

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

% Change to 'true' to download and use DataBus data
useDataBus = false;

% Time stamps for data to retrieve (dd-mmm-yyyy HH:MM:SS)
start = '01-Jun-2013 00:00:00';
stop  = '02-Jun-2013 00:00:00';

% Run the interactive function to retrieve and use DataBus data
if useDataBus
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
    
    % NOTE: Remember to switch to 'Weather2.mat' in the Simulink model!
end

% TEST: Plot the resulting time series
% hold on
% plot(ans.GHI,'-b')
% plot(ans.DNI,'-r')
% plot(ans.DHI,'-g')
% hold off
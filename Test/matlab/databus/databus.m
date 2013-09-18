%% databus.m - Tests data import from NREL's DataBus database
% 
% This script tests the importDataBus() and batchDataBus() functions for
% importing time series data from NREL's DataBus database.
%
% Test data is drawn from TMY3 data for Golden, CO, and TMY3-formatted
% actual weather data for NREL for June 2012.
%
% FUNCTIONS:
%   databus2matlab: importDataBus, batchDataBus

%% Setup
% Sensor for single test: SRRL global horizontal irradiance (GHI) data
sensor = 'wind103W_GloCM22';

% Sensors for batch test: Various SRRL irradiance data
sensorList = struct( ...
    'varname',  {{'DNI','DHI'}}                         , ...
    'dbname',   {{'wind103W_DirCH1','wind103W_Dif848'}} , ...
    'unit',     {{'W/m²','W/m²'}}                       );

% Sensor metdata file for batch test
sensorFile = 'DataBus_sensors.csv';

% Start and end dates/times (yyyy-mm-dd HH:MM:SS)
start = '2013-06-01 00:00:00';
stop  = '2013-06-02 00:00:00';

% Time zone offset from UTC: -6 for MDT
tz = -6;

% Plot name
plotname = 'GHI';

%% Plot Setup
% Open plot
fig = figure('Visible', 'off');

%% Single Read
% Read data in various output formats and plot result

% Vector
[x,t] = importDataBus(sensor, start, stop, ...
    'timezone', tz, 'output', 'vector');
    clf('reset')
    plot(t, x)
    xlabel('MATLAB Serial Date')
    ylabel('Global Horizontal Irradiance (W/m²)')
    print(fig, [plotname '-vector'], '-dpng' );

% Matrix
x = importDataBus(sensor, start, stop, 'timezone', tz, 'output', 'matrix');
    clf('reset')
    plot(x(:,1), x(:,2))
    xlabel('MATLAB Serial Date')
    ylabel('Global Horizontal Irradiance (W/m²)')
    print(fig, [plotname '-matrix'], '-dpng' );

% Time series
x = importDataBus(sensor, start, stop, 'timezone', tz, 'output', 'ts');
    clf('reset')
    plot(x)
    print(fig, [plotname '-ts'], '-dpng' );
    
%% Multiple Read
% Read data in using a sensor specification
x = batchDataBus(sensorList, start, stop, 'timezone', tz);
 
%% Multiple Read From Sensor File
% Read data in using a sensor specification file
x = batchDataBus(sensorFile, start, stop, 'timezone', tz);

%% Clean Up
% Close figure
close(fig)
 
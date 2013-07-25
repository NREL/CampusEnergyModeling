%% One-shot PV Demo Initialization Script
% This script initializes the demo by performing the following tasks:
%   1. Import the PV-SAM model to execute in SSC from text.
%   2. Execute the model using SSC
%   3. Extract the PV production data as a time series
%   4. Save the time series to a .MAT file for use with Simulink
%
% The Research Support Facility's Wing C PV array is modeled in this demo.
%
% Run this script prior to running the Simulink simulation.

%% Import PV-SAM Model
% The function importSSC() imports SSC variables from text and stores them
% in a MATLAB structure.
SSCvar = importSSC('RSF_wing_C_pvsamv1.txt');

% Change to a local weather file
% (The weather file given in the .txt run file from SSC is specific to the
% computer that originally ran the simulation and must be modified.)
idx = find(strcmp({SSCvar.Name}, 'weather_file'));
SSCvar(idx).Value = './724666TY.csv';

%% Run PV-SAM in SSC
% Requested outputs
output = struct( 'Name', {'hourly_ac_net'}, 'Type', {'array'} );

% Run SSC; get output as Simulink-compatible time series structure
out = runSSC('pvsamv1', SSCvar, output, '--ts', '--unload');

%% Save to .MAT File
% Extract time series
netPV = out.hourly_ac_net.Value;

% Change name
netPV.Name = 'pv_power';

% Scale data: kW -> W
netPV.Data = netPV.Data * 1000;

% Save result
ans = netPV;	save('PVproduction.mat', 'ans', '-v7.3');

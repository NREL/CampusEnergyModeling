%% ev_charging.m - Test the EV charging station blocks in the Simulink library
%
% This script tests AC and DC EV charging station blocks in the Campus
% Energy Modeling Simulink library. The test is not comprehensive; it
% verifies only that the test model runs without error. Proper operation
% may be verified by simulating the model manually and examining the output
% on the scopes.
%
% FUNCTIONS:
%
% SIMULINK BLOCKS:
%   AC Charging Station
%   DC Charging Station

%% Test Electric Vehicle Charging Stations
% Name of Simulink model
mdl = 'ev_charging_stations';

% Verify that the model simulates without error
open_system(mdl);
sim(mdl);
close_system(mdl, 0);

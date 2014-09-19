%% mlep_single_building.m - Run Test the MLE+ Simulink Block
%
% This script tests that a Simulink model containing an EnergyPlus model
% connected via MLE+ simulates correctly. At present, the script checks
% only that the model simulates successfully without error.
%
% FUNCTIONS:
%
% SIMULINK BLOCKS:
%   EnergyPlus
%
% NOTES:
%   1. MLE+ launches a command window in order to run EnergyPlus. This
%      script cannot automatically close said command window; you must
%      close it manually.

%% Test EnergyPlus Block
% Name of Simulink model
mdl = 'small_office';

% Verify that the model simulates without error
open_system(mdl);
sim(mdl);
close_system(mdl, 0);
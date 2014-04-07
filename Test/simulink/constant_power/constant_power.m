%% constant_power.m - Test the Constant Power blocks in the Simulink
% library
%
% This script tests the 'Constant Power Source or Load' and 'Three-Phase
% Constant Power Source or Load' blocks in the Campus Energy Modeling
% Simulink library. The tests verify that the measured power matches the
% target power within tolerance.
%
% FUNCTIONS:
%
% SIMULINK BLOCKS:
%   Constant Power Source or Load
%   Three-Phase Constant Power Source or Load
%
% TO DO:
%   1. Test the constant source case.
%   2. Test the low-voltage limit.

%% Setup
% Tolerance for PQ comparisons
tol = sqrt(eps);    % Approx 1.5e-8

%% Test Single-Phase Constant Power
% Name of Simulink model
mdl = 'single_phase_constant_power';

% Open and run simulation
open_system(mdl);

% Adjust model settings
set_param( mdl, ...
    'FixedStep',    '1'             , ...   % 1 second
    'StartTime',    '0'             , ...
    'StopTime',     '60'            );      % 1 minute

% Run simulation
sim(mdl);

% Compare measured power
assert( abs(measured_P - target_P) <= tol, ...
    'constant_power:powerMeasurementError', ...
    ['Single-phase constant power load: ' ...
     'Difference between target and measured load real power is ' ...
     'greater than tolerance.'] );
assert( abs(measured_Q - target_Q) <= tol, ...
    'constant_power:powerMeasurementError', ...
    ['Single-phase constant power load: ' ...
     'Difference between target and measured load reactive power is ' ...
     'greater than tolerance.'] );

% Close model
close_system(mdl, 0);

%% Test Three-Phase Constant Power
% Name of Simulink model
mdl = 'three_phase_constant_power';

% Open and run simulation
open_system(mdl);

% Adjust model settings
set_param( mdl, ...
    'FixedStep',    '1'             , ...   % 1 second
    'StartTime',    '0'             , ...
    'StopTime',     '60'            );      % 1 minute

% Run simulation
sim(mdl);

% Compare measured power
assert( abs(measured_P - target_P) <= tol, ...
    'constant_power:powerMeasurementError', ...
    ['Three-phase constant power load: ' ...
     'Difference between target and measured load real power is ' ...
     'greater than tolerance.'] );
assert( abs(measured_Q - target_Q) <= tol, ...
    'constant_power:powerMeasurementError', ...
    ['Three-phase constant power load: ' ...
     'Difference between target and measured load reactive power is ' ...
     'greater than tolerance.'] );

% Close model
close_system(mdl, 0);
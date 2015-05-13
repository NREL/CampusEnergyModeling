%% Campus With Central Plant - Initialization Script
%
% This script initializes the campus with central plant demo. The demo
% integrates two EnergyPlus building models with a central cooling plant
% (electric chiller) in a third EnergyPlus model.
%
% Run this script prior to executing the Simulink simulation. (You only
% need to run it once; the necessary files and settings will persist
% afterwards.)
%
% COMMENTS:
% 1. The weather file, 'USA_CO_Golden-NREL.724666_TMY3.epw', should be
%    included with your EnergyPlus installation. If not, you must change
%    the name of the weather file to one that is included with your
%    EnergyPlus installation.
%
% 2. Simulation time in this demo is based on the run period of each
%    EnergyPlus model. The default configuration is June 1 - June 5. Time
%    t = 0 in Simulink corresponds to midnight on June 1. The simulation
%    stops automatically when one of the EnergyPlus models terminates; MLE+
%    passes a termination flag output back to Simulink which ends the
%    simulation.

%% Setup
% Time step (s) - must match IDFs!
time_step = 300;

%% Initialize Simulink Model
% System name
sys = 'campus_with_central_plant';

% Open it if not open
open_system(sys);

% Set solver type and time step
set_param(sys, ...
    'SolverType',   'Fixed-step',       ...
    'FixedStep',    num2str(time_step)  ...
    );

% Set MLE+ time step
set_param([sys '/Central Plant'], 'time_step', num2str(time_step));
set_param([sys '/Office Building 1'], 'time_step', num2str(time_step));
set_param([sys '/Office Building 2'], 'time_step', num2str(time_step));

% setSimParam
%
%
%
fileName = 'run5ZoneAirCooledTest1';

%% Simulation Parameters
set_param(fileName,'SolverType', 'Fixed-step', 'FixedStep','60')


%% MLE+ Blocks
% BLOCK progname, modelfile, weatherfile, workdir, timeout, port, host, bcvtbdir, deltaT, noutputd
blockName = 'Chiller Plant';
objName = [fileName '/' blockName];

% Set Param
param = 'progname';
value = 'C:\EnergyPlusV8-0-0-mlep\RunEPlus.bat';
set_param(objName,param,value);

% Set Param
param = 'deltaT';
value = '60';
set_param(objName,param,value);

% Set Param
param = 'weatherfile';
value = 'USA_IL_Chicago-OHare.Intl.AP.725300_TMY3';
set_param(objName,param,value);



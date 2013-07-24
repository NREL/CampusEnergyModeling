%% setSimParam
% This functions sets the Dialog Parameters for the different MLE+ Blocks.
%   Willy Bernal (willyg@seas.upenn.edu)
%   July-2013 
fileName = 'supply_demand_campus';

%% Simulation Parameters
set_param(fileName,'SolverType', 'Fixed-step', 'FixedStep','60')

%% MLE+ Blocks
%% E+ PLANT
% BLOCK progname, modelfile, weatherfile, workdir, timeout, port, host, bcvtbdir, deltaT, noutputd
blockName = 'E+ Plant';
objName = [fileName '/' blockName];

% Set Param
param = 'progname';
value = '''C:\EnergyPlusV8-0-0\RunEPlus.bat''';
set_param(objName,param,value);

% Set Param
param = 'deltaT';
value = '60';
set_param(objName,param,value);

% Set Param
param = 'weatherfile';
value = '''USA_CO_Golden-NREL.724666_TMY3''';
set_param(objName,param,value);

% Set Param
param = 'modelfile';
value = '[pwd ''\ElectricChiller\ElectricChiller'']';
set_param(objName,param,value);

% Set Param
param = 'workdir';
value = '[pwd ''\ElectricChiller'']';
set_param(objName,param,value);

% Set Param
param = 'noutputd';
value = '13';
set_param(objName,param,value);
 
%% E+ Building 
% BLOCK progname, modelfile, weatherfile, workdir, timeout, port, host, bcvtbdir, deltaT, noutputd
blockName = 'E+ Building';
objName = [fileName '/' blockName];

% Set Param
param = 'progname';
value = '''C:\EnergyPlusV8-0-0\RunEPlus.bat''';
set_param(objName,param,value);

% Set Param
param = 'deltaT';
value = '60';
set_param(objName,param,value);

% Set Param
param = 'weatherfile';
value = '''USA_CO_Golden-NREL.724666_TMY3''';
set_param(objName,param,value);

% Set Param
param = 'modelfile';
value = '[pwd ''\Building1\5ZoneAirCool'']';
set_param(objName,param,value);

% Set Param
param = 'workdir';
value = '[pwd ''\Building1'']';
set_param(objName,param,value);

% Set Param
param = 'noutputd';
value = '13';
set_param(objName,param,value);

%% E+ Building1
% BLOCK progname, modelfile, weatherfile, workdir, timeout, port, host, bcvtbdir, deltaT, noutputd
blockName = 'E+ Building1';
objName = [fileName '/' blockName];

% Set Param
param = 'progname';
value = '''C:\EnergyPlusV8-0-0\RunEPlus.bat''';
set_param(objName,param,value);

% Set Param
param = 'deltaT';
value = '60';
set_param(objName,param,value);

% Set Param
param = 'weatherfile';
value = '''USA_CO_Golden-NREL.724666_TMY3''';
set_param(objName,param,value);

% Set Param
param = 'modelfile';
value = '[pwd ''\Building2\5ZoneAirCool'']';
set_param(objName,param,value);

% Set Param
param = 'workdir';
value = '[pwd ''\Building2'']';
set_param(objName,param,value);

% Set Param
param = 'noutputd';
value = '13';
set_param(objName,param,value);


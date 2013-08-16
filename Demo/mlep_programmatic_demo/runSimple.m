% runSimple - Script to launch energy plus co-simulation
% This script shows an example of how to use the utility functions to run
% MLE+.
%
% Example:
%   Run every section of the script (CRTL+ENTER) in order. 
%   1. Variable Configuration - Sets the variables.cfg configuration. 
%   2. Control Loop - Create a Control Loop Template. Then modify the file
%   to implement your control strategy.
%   3. Run Simulation - Run the E+ instance using mlepRunTemplate. 
%   4. Visualize Inputs/Outputs - Plot results.  
%
% NOTE ====================================================================
% You only need to run 1, 2, 3 once. After that, you can just modify the 
% control file and rerun the simulation multiple times. 
% =========================================================================
% 
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTIONNAME1,  OTHER_FUNCTIONNAME2

% Author: WILLY BERNAL
% UNIVERSITY OF PENNSYLVANIA
% email address: willyg@seas.upenn.edu
% Website: http://mlab.seas.upenn.edu/mlep
% August 2013; Last revision: 16-August-2013

%------------- BEGIN CODE --------------
%% 1. VARIABLE CONFIGURATION 
% Define EnergyPlus File
idfFilePath = 'C:\Users\wbernal\Documents\Git\CampusModeling\Demo\mlep_programmatic_demo\SmOffPSZ.idf';
% Create variables.cfg
setConfig(idfFilePath);

%% 2. CONTROL LOOP
% Create Control Loop
load('InOutMlep.mat')
dirPath = 'C:\Users\wbernal\Documents\Git\CampusModeling\Demo\mlep_programmatic_demo\';
ControlFilename = 'controlFile.m';
% Create Control Loop
mlepCreateControlFile(dirPath, ControlFilename, inputTable, outputTable);
% Edit the Control File
edit(ControlFilename);

%% 3. RUN SIMULATION
% NOTE ====================================================================
% If you already created the variables.cfg, InOutMlep.mat, and your control
% file you can just run this part to run the simulation. 
%==========================================================================
% Select Control
controlFilePath = 'C:\Users\wbernal\Documents\Git\CampusModeling\Demo\mlep_programmatic_demo\controlFile.m';
% Select Weather
weatherFile = 'USA_CO_Golden-NREL.724666_TMY3';

% Set Parameter 
timeStep = 15; % in minutes. It needs to  match the idf file. 
runPeriod = 4; % Number of days
timeOut = 8000; % Time for socket to timeout if there is no answer (e.g. E+ crashed)
load('InOutMlep.mat'); % Get inputTable & outputTable variables that get produced when running setConfig.m

% Run Simulation
[time logInput logOutput] = mlepRunTemplate(idfFilePath, controlFilePath, weatherFile, timeStep, runPeriod, timeOut, inputTable, outputTable);

%% 4. VISUALIZE RESULTS
% Plot Inputs
figure;plot(logInput);

% Plot Outputs
figure;plot(logOutput);


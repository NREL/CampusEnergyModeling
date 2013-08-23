function [time logInput logOutput] = mlepRunTemplate(idfFilePath, controlFilePath, weatherFile, timeStep, runPeriod, timeOut, inputTable, outputTable)
% MLEPRUNTEMPLATE - Script to launch energy plus co-simulation
% Syntax:  [time loginput logdata] = mlepRunTemplate(idfFilePath, 
% controlFilePath, weatherFile, timeStep, runPeriod, timeOut, inputTable, 
% outputTable). 
% An example of how to use this can be found in the runSimple.m script.
%
% Example:
% [time logInput logOutput] = mlepRunTemplate(idfFilePath, controlFilePath,
% weatherFile, timeStep, runPeriod, timeOut, inputTable, outputTable);
% Inputs:
%   idfFilePath - Full Path to the IDF file. 
%   controlFileName - Control File name without Path. This should be in the
%       same folder as the IDF file. 
%   weatherFile - Name of the weather file.
%   timeStep - Time Step in minutes that the EnergyPlus File is set to.
%   runPeriod - Number of days EnergyPlus is running for. 
%   timeOut - Time in Miliseconds for the Socket Connection to time out 
%       (e.g. 6000). 
%   inputTable - Array with the Selected Inputs to EnergyPlus. This   
%   outputTable - Array with the Selected Outputs from EnergyPlus. 
%
% Outputs:
%   time
%   loginput
%   logdata
%
% Example:
%   [time loginput logdata] = mlepRunTemplate(data)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: runSimple,  setConfig

% Author: WILLY BERNAL
% UNIVERSITY OF PENNSYLVANIA
% email address: willyg@seas.upenn.edu
% Website: http://mlab.seas.upenn.edu/mlep
% August 2013; Last revision: 16-August-2013

%------------- BEGIN CODE --------------

%% Create an mlepProcess instance and configure it
% inputTable Size
if ~isempty(inputTable)
    sizeInput = size(inputTable,1);
else
    sizeInput = 0;
end

% outputTable Size
if ~isempty(outputTable)
    sizeOutput = size(outputTable,1);
else
    sizeOutput = 0;
end

% Create MLEP Process
ep = mlepProcess;
[projectPath, filename, ~] = fileparts(idfFilePath);
ep.arguments = {[projectPath filesep filename], weatherFile};
ep.acceptTimeout = timeOut; %800000
VERNUMBER = 2;  % version number of communication protocol (2 for E+ 6.0.0)

%% Start EnergyPlus cosimulation
cd(projectPath) % Change to project directory
[status, msg] = ep.start;

if status ~= 0
    error('Could not start EnergyPlus: %s.', msg);
end

% Set Simulation Paramters
deltaT = 60*timeStep;   % turn it into seconds
kStep = 1;  % current simulation step
MAXSTEPS = (runPeriod+1)*24*60/timeStep;  % max simulation time = RunPeriod days

% logdata stores set-points, outdoor temperature, and zone temperature at
% each time step.
logInput = zeros(MAXSTEPS, sizeInput);
logOutput = zeros(MAXSTEPS, sizeOutput);

% Input/Ouptut Vector
mlepInputVector = struct;
mlepOutputVector = struct;
for i = 1:sizeInput
    mlepInputVector.(inputTable{i,5}) = zeros(1,MAXSTEPS);
end

for i = 1:sizeOutput
    mlepOutputVector.(outputTable{i,5}) = zeros(1,MAXSTEPS);
end

% Time Vector
time = (0:(MAXSTEPS-1))'*deltaT/3600;

% Create Handle for Control Function
[dirPath, filename, ext] = fileparts(controlFilePath);
controlFunctionName = [dirPath filesep filename];
funcHandle = str2func(filename);

stepNumber = 1;
stepNumber = [];
inputFieldNames = {};
for i = 1:sizeInput
    inputFieldNames{i} = inputTable{i,5};
    %    stepNumber(i) = 1;
end

for i = 1:sizeOutput
    outputFieldNames{i} = outputTable{i,4};
    %    stepNumber(i) = 1;
end

mlepIn = [];
mlepOut = [];
cmd = 'init';

% Accept Socket
[status, msg] = acceptSocket(ep);

% Start Simulation
while kStep <= MAXSTEPS
    % Read a data packet from E+
    packet = ep.read;
    if isempty(packet)
        error('Could not read outputs from E+.');
    end
    
    % Parse it to obtain building outputs
    [flag, ~, outputs] = mlepDecodePacket(packet);
    if flag ~= 0
        % Packet Problem
        break;
    end
    
    % Log Outputs
    if sizeOutput
        % Save to logdata
        logOutput(kStep, :) = outputs;
        for i = 1:sizeOutput
            mlepOutputVector.(outputTable{i,5})(kStep) = outputs(i);
        end
    end
    
    % Run Control File
    userdata = [];
    [inputStruct, userdata] = feval(funcHandle, cmd, mlepOut, mlepIn, time(1:kStep), kStep, userdata);
    [inputs] = setInput2vector(inputStruct, inputTable, outputTable);
    
    %     catch err
%         if (strcmp(err.identifier,'MATLAB:unassignedOutputs'))
%             if isempty(inputTableData)
%                 noInput = 1;
%                 inputs = ones(1,0);
%             end
%         else
%             rethrow(err);
%         end
%     end
    cmd = 'normal';
    
    
    ep.write(mlepEncodeRealData(VERNUMBER, 0, (kStep-1)*deltaT, inputs));
    % Save to loginput
    logInput(kStep, :) = inputs;
    
    
    % Increment Count
    kStep = kStep + 1;
end

% Stop EnergyPlus
ep.stop;

% Remove unused entries
kStep = kStep - 1;
if kStep < MAXSTEPS
    logOutput((kStep+1):end,:) = [];
    logInput((kStep+1):end,:) = [];
end

% Time Vecotor
time = [0:(kStep-1)]'*deltaT/3600;

end

%%
% Need to create structure for inputs
function [inputs] = setInput2vector(inputStruct, inputTable, outputTable)

% Transform Struct to vector for feedback
if size(inputTable,1)
    names = fieldnames(inputStruct);
    
    
    inputs = zeros(1,size(inputTable,1));
    for j = 1:size(inputTable,1)
        vecIndex = strcmp(names, inputTable{j,5});
        % CHECK IF ALL INPUTS SPECIFIED
        if sum(vecIndex == 1)
            inputs(j) = inputStruct.(names{vecIndex});
        else
            mlepError = 'notAllInputsSpecified';
            errordlg(mlepError,'Input/Output Error')
            return;
        end
    end
else
    % CASE WHEN THERE ARE NO INPUTS
    inputs = [];
end
end

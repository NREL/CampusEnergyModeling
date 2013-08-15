function [Input, Output] = retrieveInOutIDF(filename)
% RETRIEVEINOUTIDF - This function retrieves the inputs (External
% Interface Objects) and outputs (Variable:Output Objects) from the IDF
% file.
% Usage: [Input, Output] = retrieveInOutIDF('path/to/idf/file')
% Input - Contains a cell with the ExternalInterface Schedules, Actuators
% and Variables.
% Output - Contains a cell with the Variable:Output Objects.
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-05 Started.
%

% Parse IDF
idfStruct = readIDF(filename,{'Timestep',...
    'RunPeriod',...
    'ExternalInterface:Schedule',...
    'ExternalInterface:Actuator',...
    'ExternalInterface:Variable',...
    'Output:Variable'});

timeStep = 60/str2double(char(idfStruct(1).fields{1}));
runPeriod = (str2double(char(idfStruct(2).fields{1}(4))) - str2double(char(idfStruct(2).fields{1}(2))))*31 + 1 + str2double(char(idfStruct(2).fields{1}(5))) - str2double(char(idfStruct(2).fields{1}(3)));
ExternalInterface.schedule = idfStruct(3).fields;
ExternalInterface.actuator = idfStruct(4).fields;
ExternalInterface.variable = idfStruct(5).fields;
OutputVariable.output = idfStruct(6).fields;

% Format
% List Schedules
Input = {};
count = 1;
if ~isempty(ExternalInterface.schedule)
    for i = 1:size(ExternalInterface.schedule,2)
        %ExternalInterface.Input{i,1} = char(ExternalInterface.schedule{i}(1));
        Input{count,1} = false;
        Input{count,2} = 'Ptolomy';
        Input{count,3} = 'schedule';
        Input{count,4} = char(ExternalInterface.schedule{i}(1));
        Input{count,5} = char(ExternalInterface.schedule{i}(2));
        Input{count,6} = char(ExternalInterface.schedule{i}(3));
        Input{count,7} = '';
        Input{count,8} = '';
        Input{count,9} = ['SCHEDULE: ', char(ExternalInterface.schedule{i}(1)), ' - ',char(ExternalInterface.schedule{i}(2)), ' - ', char(ExternalInterface.schedule{i}(3))];
        Input{count,10} = 'Alias';
        count = count +1;
    end
end

% List Actuators
if ~isempty(ExternalInterface.actuator)
    for i = 1:size(ExternalInterface.actuator,2)
        %ExternalInterface.Input{i,1} = char(ExternalInterface.actuator{i}(1));
        Input{count,1} = false;
        Input{count,2} = 'Ptolomy';
        Input{count,3} = 'actuator';
        Input{count,4} = char(ExternalInterface.actuator{i}(1));
        Input{count,5} = char(ExternalInterface.actuator{i}(2));
        Input{count,6} = char(ExternalInterface.actuator{i}(3));
        Input{count,7} = char(ExternalInterface.actuator{i}(4));
        Input{count,8} = char(ExternalInterface.actuator{i}(5));
        Input{count,9} = ['actuator: ', char(ExternalInterface.actuator{i}(1)), ' - ',char(ExternalInterface.actuator{i}(2)), ' - ', char(ExternalInterface.actuator{i}(3)), ' - ', char(ExternalInterface.actuator{i}(4)), ' - ', char(ExternalInterface.actuator{i}(5))];
        Input{count,10} = 'Alias';
        count = count + 1;
    end
end

% List Variables
if ~isempty(ExternalInterface.variable)
    for i = 1:size(ExternalInterface.variable,2)
        %ExternalInterface.Input{i,1} = char(ExternalInterface.schedule{i}(1));
        Input{count,1} = false;
        Input{count,2} = 'Ptolomy';
        Input{count,3} = 'variable';
        Input{count,4} = char(ExternalInterface.variable{i}(1));
        Input{count,5} = char(ExternalInterface.variable{i}(2));
        Input{count,6} = '';
        Input{count,7} = '';
        Input{count,8} = '';
        Input{count,9} = ['VARIABLE: ', char(ExternalInterface.variable{i}(1)), ' - ',char(ExternalInterface.variable{i}(2))];
        Input{count,10} = 'Alias';
        count = count + 1;
    end
end

% List Outputs
Output = {};
count = 1;
if ~isempty(OutputVariable.output)
    for i = 1:size(OutputVariable.output,2)
        % Output{i} = char(mlep.data.output{i}(2));
        Output{count,1} = false;
        Output{count,2} = 'EnergyPlus';
        Output{count,3} = char(OutputVariable.output{i}(1));
        Output{count,4} = char(OutputVariable.output{i}(2));
        Output{count,5} = char(OutputVariable.output{i}(3));
        Output{count,6} = ['OUTPUT: ', char(OutputVariable.output{i}(1)), ' - ', char(OutputVariable.output{i}(2)), ' - ', char(OutputVariable.output{i}(3))];
        Output{count,7} = 'Alias';
        count = count + 1;
    end
end




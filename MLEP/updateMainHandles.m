function updateMainHandles(mainHandles, InputTable, OutputTable)
% UPDATEMAINHANDLES - This function keeps the data updated (selected Inputs
% and Outputs) from the variables window to the Main MLE+ GUI.
%
% Usage: updateMainHandles(InputTable, OutputTable)
% Inputs:
% InputsTable - Contains a cell array with the selected Inputs to E+.
% OutputsTable - Contains a cell array with the selected Outputs to E+.
%
% Outputs:
% None.
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-07 Created.
%

% Update Inputs
if ~isempty(InputTable)
    set(mainHandles.Control_InputListbox, 'String', InputTable(:,5));
    set(mainHandles.SystemID_InputListbox, 'String', InputTable(:,5));
end

% Update Outputs
if ~isempty(OutputTable)
    set(mainHandles.Control_OutputListbox, 'String', OutputTable(:,5));
    set(mainHandles.SystemID_OutputListbox, 'String', OutputTable(:,5));
end

% Update UserData
set(mainHandles.Control_InputListbox, 'UserData', {InputTable, OutputTable});
set(mainHandles.SystemID_InputListbox, 'UserData', {InputTable, OutputTable});
end
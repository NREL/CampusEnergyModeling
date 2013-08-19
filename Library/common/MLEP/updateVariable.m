function [handles] = updateVariable(handles)

% Check if exist
if isfield(handles, 'Control_InputListbox')
    % Get Input/Output Data
    handles.DATA.variableData = get(handles.Control_InputListbox, 'UserData');
    if ~isempty(handles.DATA.variableData)
        handles.DATA.variableInput = handles.DATA.variableData(1);
        handles.DATA.variableOutput = handles.DATA.variableData(2);
    else
        handles.DATA.variableInput = {};
        handles.DATA.variableOutput = {};
    end
end


end
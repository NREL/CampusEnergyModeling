function [table] = addInOutMlep(table, listbox, index, option)
% ADDINOUTMLEP - This function updates the table with information about the
% inputs or outputs coming from the listbox with the specified index.
% Usage: [table] = addInOutMlep(table, listbox, index, option)
% Inputs:
% table - Contains the current Table information.
% listbox - Contains a cell with the ExternalInterface Objects or Output
% Variable Objects. 
% index - Contains the index for the listbox element to be added.
% option - Contains either 'inputs' or 'outputs'. This determines whether
% to add it to the Input Table or the Output Table. 
%
% Outputs:
% table - Contains the updated table after adding the elements. 
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-05 Started.
%

if ~isempty(listbox)
    if ~isempty(index)
        if strcmp(option, 'inputs')
            % Inputs
            table = [table; listbox(index,[1 2 3 4 10])];
        elseif strcmp(option, 'outputs')
            % Outputs
            table = [table; listbox(index,[1 2 3 4 7])];
        else
            MSG = 'Invalid Option: Optiont must be either ''inputs'' or ''outputs''';
            error(MSG);
        end
    else
        MSG = 'Invalid Index: Either not selected or not a number.';
        error(MSG);
    end
end




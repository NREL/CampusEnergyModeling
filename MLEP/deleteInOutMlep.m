function [table] = deleteInOutMlep(table)
% DELETEINOUTMLEP - This function updates the table by deleting the inputs
% or outputs selected in one of the table fields (1st field on the table).
%
% Usage: [table] = deleteInOutMlep(table)
% Inputs: 
% table - Contains the current cell array from the 'Data' field (cell 
% array).
%
% Outputs:
% table - Contains the updated table after deletion has taken place (cell
% array).
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-05 Started.
%

% Check whether table is empty
if ~isempty(table)
    % Check which one to keep
    index = (cell2mat(table(:,1)) == 0);
    table = table(index, :); 
    % Check if all elements got deleted
    if isempty(table)
        table = {};
    end
end





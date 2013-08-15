function [result] = prepIDF(filename)
% PREPIDF - Prepare an EnergyPlus IDF file to be used with MLE+.
%   result = prepIDF(filename)
% The program checks for ExternalInterface Object and creates it if absent.
% 
% The output result is a flag to check whether the file was properly setup.
% result = 1, The EnergyPlus Files is properly setup. 
% result = 2, The EnergyPlus Files was successfully setup. 
% result = 0, The EnergyPlus Files failed to properly setup.
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-01 Checks ExternalInterface Object.
%

% Default: NOT SUCCESSFUL
result = 0;

% Check if ExternalInterface Object exist  
classnames = {'ExternalInterface'};
data = readIDF(filename, classnames);

if ~isempty(data.fields)
    % if exist, check ExternalInterface Object properly setup
    if length(data.fields) == 1 && strcmpi(data.fields{1}, 'PTOLEMYSERVER')    
        % Properly Setup
        result = 1; % Already Properly setup
    else
        result = 0; % There is something wrong with the file. Requires manual change. 
        ERRMSG = ['MLE+ ERROR: The .IDF file ' filename ' requires manual setup. Please ensure you set up the file before running MLE+.']; 
        error(ERRMSG);
    end
else 
    % Create ExternalInterface Object 
    fid = fopen(filename, 'at');
    string =  sprintf('\n  ExternalInterface,\n    PtolemyServer;           !- Name of External Interface');
    n = fprintf(fid, '%s\n', string);
    fclose(fid);
    if n
        result = 2;
    else
        result = 0;
    end
end
end












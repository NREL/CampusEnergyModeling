function [result] = setConfig(filename)
% SETCONFIG - This function launches a GUI that helps you set the 
% variables.cfg file needed to specify the Inputs and Outputs to/from 
% EnergyPlus. This file is required so MLE+ knows which variables you will 
% be controlling and accessing in your EnergyPlus file.
% 
% Usage: result = setConfig(filename)
% Inputs:
% filename - Contains a string with the path to the .idf file 
% ('path/to/idf/file')
%
% Outputs:
% result - Contains a flag to indicate whether the function was successfull
% or not. 
% result = 1, The EnergyPlus Files is already properly setup. 
% result = 2, The EnergyPlus Files was successfully setup. 
% result = -1, The EnergyPlus Files failed to properly setup.
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% HISTORY:
%   2013-08-01 Checks ExternalInterface Object.
%

% Check if Inputs are Valid
if ischar(filename)
    if exist(filename, 'file')
        [~, ~, ext] = fileparts(filename);
        if strcmpi(ext, '.IDF')
            disp(['Filename: ' filename]);
            result = prepIDF(filename);
            if result
                % Launch GUI    
                setConfigurationFile('filename',filename);
            else
                MSG = 'Faulty IDF: Please check manually IDF file';
                error(MSG);
            end        
        else
            MSG = 'Wrong Extension: The file specified is not an IDF file';
            error(MSG);
        end
    else
        MSG = 'Wrong File: The file specified does not exist';
        error(MSG);
    end
else
    MSG = 'Wrong Input: The name of the file should be a Matlab Char (String)';
    error(MSG);
end
end




%% IMPORTSSC - Import SSC input variables from text
%
% Imports a SAM model from SAM's automatically generated SSC run file and
% parses the result into a structure. These run files may be found under
%   [HOME]\.SAM\ssc\
% after executing the model in SAM, where [HOME] is the current user's
% home directory.
%
% SYNTAX:
%   x = importSSC(filename)
%
% INPUTS:
%   filename =  The name of the SSC input variable text file to import
%
% OUTPUTS:
%   x =         A MATLAB structure array with entries for all data
%               imported from the SAM text file
%
% COMMENTS:
% 1. SSC input variable data is organized in the text file as follows:
%       [data type] [variable name] [value(s)] [description] [units]
%    Each field is seperated by a tab delimiter. Moreover, for arrays, the
%    value field contains more than one value, also tab separated. The
%    units field may be empty. Because of the variable length lines, this
%    function parses each line individually.

function x = importSSC(filename)
    %% Read Raw Data
    % Read SAM data (starts on line 3) as strings
    fid = fopen(filename,'r');
    C = textscan(fid, '%s', 'Delimiter', '\n', 'HeaderLines', 2);
    fclose(fid);
    
    % Extract cell array
    C = C{:};
    
    % Create output structure
    x = struct('Name', {}, 'Type', {}, 'Value', {}, ...
        'Description', {}, 'Units', {});
    
    %% Parse Data
    % Parse each line of data
    for i = 1:length(C)
        % Split the string for this line into components
        s = strsplit(C{i}, '\t');
        sType = s{1};
        sName = s{2};
        sVals = strjoin( s(3:(length(s)-2)), ' ' );
        sDesc = s{length(s)-1};
        sUnits = s{length(s)};
        
        % Parse the string value(s) according to string type
        switch sType
            case 'number'
                % Single number
                sVals = sscanf(sVals, '%f');
                
            case 'array'
                % Array of numbers
                sVals = sscanf(sVals, '%f');
                
                % First number is a length; use it for data checking
                len = sVals(1);
                sVals = sVals(2:end);
                if length(sVals) ~= len
                    warning('importSSC:dataMismatch', ...
                        ['Array input variable ''' sName ''' does not ' ...
                         'contain the reported number of elements; ' ...
                         'imported data may be incorrect.']);
                end
                
            case 'string'
                % No conversion required
                
            otherwise
                % Unsupported data type
                warning('importSSC:unsupportedDataType', ...
                    ['Array input variable ''' sName ''' has the ' ...
                     'unsupported data type ''' sType ''' ' ...
                     'and cannot be imported.']);
                sVals = [];
        end
        
        % Place into output structure
        x(i).Name = sName;
        x(i).Type = sType;
        x(i).Value = sVals;
        x(i).Description = sDesc;
        x(i).Units = sUnits;   
    end
    
end
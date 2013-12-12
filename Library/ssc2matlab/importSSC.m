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
%
% 2. Only the SSC number, array, matrix, and string types are supported.

function x = importSSC(filename)
    %% Read Raw Data
    % Read SAM data (starts on line 3) as strings
    fid = fopen(filename,'r');
    C = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    
    % Extract cell array
    C = C{:};
    
    % Row tracking
    r = 1;
    nRow = length(C);
    
    % Add blank cell to the end of C
    C{nRow + 1} = '';
    
    % Create output structure
    x = struct('Name', {}, 'Type', {}, 'Value', {}, ...
        'Description', {}, 'Units', {});
    
    %% Parse Data
    % Track input variables parsed
    n = 1;
    
    % Loop until the file is empty    
    while r <= nRow
        % Skip empty lines
        while isempty( C{r} )
            r = r + 1;
        end
        
        % Skip block if it is not an input data block
        if isempty( strfind( C{r}, 'var tab' ) )
            while ~isempty( C{r} )
                r = r + 1;
            end
            continue
        end
        
        % Next row
        r = r + 1;
            
        % Parse the input variables
        while ~isempty( C{r} )
            % Split the string for this line into components
            s = strsplit(C{r}, '\t');
            
            % For a matrix input, retrieve the rest of the matrix
            if strcmpi(s{1}, 'matrix')
                % Number of matrix rows
                rows = sscanf(s{3}, '%f', 1);
                
                % Add the extra rows (plus a metadata row at end)
                s = strsplit( strjoin( C(r:r+rows)', '\t' ), '\t');
                
                % Set current row to last row of matrix input
                r = r + rows;
            end
            
            % Extract data
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
                            ['Array input variable ''' sName ''' does ' ...
                             'not contain the reported number of ' ...
                             'elements; imported data may be corrupted.']);
                    end
                    
                case 'matrix'
                    % Matrix of numbers
                    sVals = sscanf(sVals, '%f');
                    
                    % First two numbers are rows/cols
                    rows = sVals(1);
                    cols = sVals(2);
                    
                    % Check size
                    if length(sVals) ~= rows*cols + 2
                        warning('importSSC:dataMismatch', ...
                            ['Matrix input variable ''' sName ''' ' ...
                             'does not contain the reported number of ' ...
                             'rows and columns; imported data may be ' ...
                             'corrupted.']);
                    end
                    
                    % Reshape rest
                    sVals = reshape(sVals(3:end), rows, cols);

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
            x(n).Name = sName;
            x(n).Type = sType;
            x(n).Value = sVals;
            x(n).Description = sDesc;
            x(n).Units = sUnits;
            
            % Increment to next variable
            n = n + 1;
            
            % Next row
            r = r + 1;
        end
    end
    
end
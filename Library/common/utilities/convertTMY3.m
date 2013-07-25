%% Function: Convert TMY3 data to useable MATLAB time series objects
% Converts typical meteorological year (TMY) version 3 weather data into a
% set of MATLAB time series objects. Each time series object corresponds to
% one data field from the TMY3 data specification.
%
% By default, only a subset of the TMY3 data are imported, as specified in
% the file 'TMY3_column_specification.txt'. This subset can be overridden
% by passing a customized column specification to the function (see
% OPTIONAL INPUTS and COMMENTS sections).
%
% To use the output of convertTMY3() in Simulink, save the result to a .MAT
% file in the variable 'ans' and load it into Simulink using a 'From File'
% block (or the 'Weather Data' block in the campus modeling Simulink
% library).
%
% SYNTAX:
%   x = convertTMY3(filename,varargin)
%
% INPUTS:
%   filename =  The name of the TMY3 data file to convert
%   varargin =  (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'filename':
%
%   'offset', [val]             Specify the time offset for the generated
%                               vector of hourly data. (Default = -0.5)
%   'columnSpec', [val]         Provide a customizes specification for
%                               which data columns should be pulled from
%                               the TMY3 data file. (This should only be
%                               necessary if the TMY3 file is nonstandard.)
%                               If specified, 'columnSpec' should be a
%                               structure with the fields:
%                                   col         Column in TMY3 file
%                                   name        Name for the column
%                                   datatype    textscan() data type
%                                               specification (e.g. '%f')
%                                   unit        Column units
%                                   desc        Description for the column
%                               Only the specified columns will be parsed
%                               from the imported TMY3 data. Note that
%                               string fields should be expressed as cell
%                               arrays.
%
%   The following optional inputs may be passed as flags following
%   'filename' and interspersed with any name-value pair above:
%
%   '--UseOriginalTimestamps'   If set, then parse the output using the
%                               original timestamps in the TMY3 file rather
%                               than create a synthesized time vector.
%
% OUTPUTS:
%   x           A MATLAB structure containing time series corresponding to
%               the TMY3 data, in time units of seconds.
%
% COMMENTS:
% 1. TMY3 data is designed to represent a single, continuous year (8760
%    hours). However, the time stamps reflect the original time stamp of
%    the recorded meteorological data. In most cases, the TMY3 time stamps
%    should not be used to create the time vector for the MATLAB time
%    series. Instead, a monotonically increasing vector of hours 1 to N,
%    where N is the number of data points (usually 8760), matches the
%    intended use of the data. To override this behavior, set the flag
%    '--UseOriginalTimestamps' (see above).
%
% 2. The optional input 'offset' adjusts the time vector by the offset
%    amount in hours (backward for negative offsets). The default value of
%    -0.5 positions the time stamp for each hour in the center of the hour
%    as opposed to at the end as is default for TMY3 data.
%
% 3. The structure organization matches Simulink's requirements for using a
%    'From File' block to import time series data. It would also be
%    possible to create a single time series with multiple data columns or
%    a 'tscollection' object containing the individual time series.
%    However, these approaches are less extensible in Simulink.
%
% 4. This function uses textscan() for the actual file I/O. It will
%    construct the string of values to import using the column
%    specification. Be aware that if the column specification does not
%    match the TMY3 file (non-standard file or custom column
%    specification), then the function may error or the data returned may
%    be incorrect. There's no error checking.
%
% 5. If you would like to use the time and date information in the TMY3
%    file AND you are using a custom column specification, then you must
%    include columns for 'date' and 'time' in the specification. These
%    columns should have the following properties:
%       datatype = '%s'
%       unit = <specify date format, e.g. 'mm:dd:yyyy'>    
%
% REFERENCES:
% 1. S. Wilcox and W. Marion, "Users Manual for TMY3 Data Sets", National
%    Renewable Energy Laboratory, Tech. Rep. NREL/TP-581-43156, May 2008.
%    [Online]. Available: http://www.nrel.gov/docs/fy08osti/43156.pdf

function x = convertTMY3(filename,varargin)
    %% Defaults
    % Default time offset to apply (in hours)
    offset = -0.5;
    
    % Empty column specification (loaded later)
    columnSpec = [];
    
    % Don't use original TMY3 timestamps
    useOrigTimestamps = false;

    %% Process Optional Arguments
    % Parses arguments from 'varargin'
    i = 1;
	while i <= length(varargin)
        % Get name part of name-value pair (or, a standalone flag)
		argName = varargin{i}; i = i + 1;
        
        % Check for flags first
        % (For flags, the value assigned is irrelevant, as only the
        % existance of the flag is checked.)
        switch argName
            case {'--UseOriginalTimestamps'}
                useOrigTimestamps = true;
                continue;
        end
        
        % Get value part of name-value pair
        argVal = varargin{i}; i = i + 1;
        
        % Assign optional values accordingly
        switch argName
			case {'unit'}
                timeUnit = argVal;      % Time unit for time series
			case {'offset'}
                offset = argVal;        % Time offset for time series
			case {'columnSpec'}
                columnSpec = argVal;    % Column specification
            otherwise
                warning('convertTMY3:unknownOption', ...
                    ['Optional argument ''' argName ''' is not ' ...
                     'recognized and has therefore been ignored.']);
        end
	end
    
    %% Setup
    % Load a column specification if none was provided
    if isempty(columnSpec)
        % Load a default column specification (follows TMY3 user's manual)
        fid = fopen('TMY3_column_specification.txt','r');
        C = textscan(fid, '%u%s%s%s%q', 'HeaderLines', 1);
        fclose(fid);
        
        % Convert to structure
        columnSpec = struct( ...
            'col', C{:,1}, ...
            'name', C(:,2), ...
            'unit', C(:,3), ...
            'datatype', C(:,4), ...
            'desc', C(:,5) );
    end
    
    % Create format strings for textscan()
    delim = ',';
    formatSpec = cell(1,max(columnSpec.col)+1);
    formatSpec(:) = {'%s'};
    formatSpec(columnSpec.col) = columnSpec.datatype;
    formatSpec(length(formatSpec)) = {'%*[^\n]'};
    formatSpec = [formatSpec{:}];
    
    %% Read Data
    % Read TMY3 data (starts on line 3)
    fid = fopen(filename,'r');
    C = textscan(fid, formatSpec, ...
        'Delimiter', delim, 'EmptyValue', NaN, 'HeaderLines', 2);
    fclose(fid);
    
    %% Create Time Vector
    % Number of data points
    n = size(C{1},1);
    
    % Default start date is unspecified
    startDate = '';
    
    % Use actual time
    % (Do not use this for typical TMY3 files, which have timestamps from
    % multipl years and are not in chronological order.)
    if useOrigTimestamps
        % Get 'date' and 'time' metadata
        dIdx = strcmpi(columnSpec.name(:), {'date'});
        tIdx = strcmpi(columnSpec.name(:), {'time'});
        dCol = columnSpec.col( dIdx );
        tCol = columnSpec.col( tIdx );
        dFormat = columnSpec.unit( dIdx );
        tFormat = columnSpec.unit( tIdx );
        
        % Parse time from 'date' and 'time' fields; apply offset
        % Output is in days since midnight, Jan 1, 0000
        datetime = [char(C{1,dCol}), repmat(' ',n,1), char(C{1,tCol})];
        t = datenum( datetime, [dFormat ' ' tFormat] ) + offset/24;
        
        % Determine the start date and adjust the time vector accordingly
        startDate = datestr(min(t));
        t = t - min(t);
        
        % Now, change time unit to seconds
        t = t * 86400;      % 60 sec * 60 min * 24 hr
        
    % Use synthesized time
    else
        % Create a standard 1:N hours time vector + offset
        t = (1:n)' + offset;
        
        % Now, change time unit to seconds
        t = t * 3600;      % 60 sec * 60 min
    end
    
    % Sort t and return sorted indices
    [t, ord] = sort(t, 'ascend');
    
    
    %% Parse Requested Columns
    % Create output structire
    x = struct();
    
    % Create a time series object for each requested column
    for i = 1:length(columnSpec.col)
        % Skip date and time columns
        if any(strcmpi(columnSpec.name{i}, {'date','time'}))
            continue
        end
        
        % Create time series from data
        col = columnSpec.col(i);
        data = C{1,col};
        x.(columnSpec.name{i}) = timeseries(data(ord), t);
        
        % Assign time series time properties
        x.(columnSpec.name{i}).TimeInfo.Units = 'seconds';
        x.(columnSpec.name{i}).TimeInfo.StartDate = startDate;
        x.(columnSpec.name{i}).TimeInfo.Format = 0;
        
        % Assign time series data properties
        x.(columnSpec.name{i}).Name = columnSpec.name{i};
        x.(columnSpec.name{i}).DataInfo.Units = columnSpec.unit{i};
        x.(columnSpec.name{i}).DataInfo.UserData = columnSpec.desc{i};
    end
    
end
%% IMPORTDATABUS - Semi-automated import of data from DataBus
%
% This is a user-interactive function to import sensor data from NREL's
% DataBus database. After import, the time series sensor data is converted
% to a structure MATLAB time series objects compatible with the Simulink
% 'From File' block.
% 
% MATLAB cannot connect to DataBus directly for a variety of reasons.
% Instead, this function relies on the user to save the data as CSV
% for import into MATLAB. The workflow for the function is as follows:
%   1. Create a specification for sensor data to import from DataBus
%   2. Call this function with the specification
%   3. For each sensor, the function
%      a. Forms the required DataBus url
%      b. Launches an external browser with the url
%      c. Prompts the user with login credentials for DataBus
%      d. Prompts the user to save the downloaded file in CSV format
%      e. Prompts the user for the name of the saved CSV file
%      f. Imports the CSV file and converts the data
%   4. The function returns the imported data as a structure
%
% To use the output of convertTMY3() in Simulink, save the result to a .MAT
% file in the variable 'ans' and load it into Simulink using a 'From File'
% block (or the 'Weather Data' block in the campus modeling Simulink
% library).
%
% SYNTAX:
%   x = importDataBus(sensors,start,end)
%
% INPUTS:
%   sensors =   A structure specifying sensor metadata, OR the name of a 
%               CSV file specifying the sensor metadata (see DETAILS)
%   start =     A string specifying the beginning of the time range to
%               import from DataBus, specified as 'dd-mmm-yyyy HH:MM:SS'
%   stop =      A string specifying the end of the time range to
%               import from DataBus, specified as 'dd-mmm-yyyy HH:MM:SS'
%   tz =        
%   varargin =  (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'tz':
%
%   'timezone', [val]           Time zone offset from GMT (in hours) for
%                               start and end times. (Default = 0)
%   'format', [val]             Specify the format for the time/date data.
%                               (Default = 'dd-mmm-yyyy HH:MM:SS')
%   'skipdownload', [val]       A boolean vector specifying whether to
%                               skip the DataBus download for each sensor.
%                               Set to true for a given sensor to use
%                               previously downloaded files rather than
%                               launch the DataBus url.
%
% OUTPUTS:
%   out =       A MATLAB structure containing time series corresponding to
%               the DataBus data, in time units of seconds.
%
% DETAILS:
% Sensor metadata for the 'sensors' input should be either a structure or
% the name of a CSV file with the following fields/columns specified for
% each sensor:
%   varname     The MATLAB variable name to use in the function output
%   tablename   The name of the DataBus table to import from
%   unit        (Optional) A text string giving the unit for the sensor
%   description (Optional) A text string describing the sensor
%
% If specified, 'unit' and 'description' will be embedded within the MATLAB
% time series metadata in the function output.
%
% COMMENTS:
% 1. The primary reason for using a user-interactive function is that
%    MATLAB cannot properly authenticate when attempting to access DataBus,
%    even when the correct credentials are supplied. Therefore, the user
%    must mannually enter the following credentials when prompted:
%       Username = robot-CampusModeling
%       Password = 3IALU6ANWW.B2.1DUMFNE91U5YG
%    The function also prompts the user interactively to enter these
%    credentials by printing output to the MATLAB command window.
%
% 2. Each time the function prompts for a file download, it will first look
%    for a file named [varname].csv, where [varname] is the name of the
%    current sensor. If this file is not found, it will prompt the user for
%    another file name. If the second file is not found, it will skip the
%    sensor (with a warning).
%
%    A side effect of this workflow is that the user can just press ENTER
%    at the file prompt to skip sensors for which DataBus is acting up.
%
%    See also: The 'skipdownload' optional input.
%
% 3. For other than UTC times, the time zone offset 'tz' must be specified
%    to convert local time to UTC in order to query DataBus properly. For
%    MST, use -7; for MDT, use -6.
%
% 4. Depending on your browser, you may need to manually clean HTML tags
%    out of the downloaded DataBus data after saving it to CSV. This
%    function requires two columns ('time' and 'value'), exactly one header
%    line, and no extraneous HTML content.
%
% 5. The structure organization matches Simulink's requirements for using a
%    'From File' block to import time series data. It would also be
%    possible to create a single time series with multiple data columns or
%    a 'tscollection' object containing the individual time series.
%    However, these approaches are less extensible in Simulink.

function out = importDataBus(sensors,start,stop,varargin)
    %% Defaults
    % Default time zone offset
    tz = 0;
    
    % Default time format
    tFormat = 'dd-mmm-yyyy HH:MM:SS';
    
    % Whether to skip downloads
    skipDownload = [];
    
    %% Process Optional Arguments
    % Parses arguments from 'varargin'
    i = 1;
    if mod(length(varargin),2) > 0
        error('importDataBus:mismatchedArgList', ...
            'All optional arguments must form name-value pairs.');
    end
	while i <= length(varargin)
        % Get name part of name-value pair
		argName = varargin{i}; i = i + 1;
        
        % Get value part of name-value pair
        argVal = varargin{i}; i = i + 1;
        
        % Assign optional values accordingly
        switch argName
			case {'timezone'}
                tz = argVal;            % Time zone (offset from GMT)
			case {'format'}
                tFormat = argVal;       % Time format
            case {'skipdownload'}
                skipDownload = argVal;  % Skip download? (Boolean vector)
            otherwise
                warning('importDataBus:unknownOption', ...
                    ['Optional argument ''' argName ''' is not ' ...
                     'recognized and has therefore been ignored.']);
        end
	end

    %% Setup
    % Load sensor metadata from file
    if ischar(sensors)
        % Load sensor metadata from CSV
        fid = fopen(sensors,'r');
        assert(fid >= 0, ...
            'importDataBus:invalidInputFile', ...
            ['Specified sensor metadata file name ''' sensors '''' ...
             'is not present in the current MATLAB path.']);
        C = textscan(fid, '%s%s%s%s', 'delimiter', ',', 'HeaderLines', 1);
        fclose(fid);
        
        % Convert to structure
        sensors = struct( ...
            'varname', C(:,1), ...
            'tablename', C(:,2), ...
            'unit', C(:,3), ...
            'description', C(:,4) );
    end
    
    % Assert structure
    assert( isstruct(sensors), ...
            'importDataBus:invalidSensorMetadata', ...
            'Sensor metadata must be specified in a structure.');
        
    % Create any missing fields
    if ~isfield(sensors, 'unit')
        sensors.unit = cell(length(sensors.varname), 1);
    end
    if ~isfield(sensors, 'description')
        sensors.description = cell(length(sensors.varname), 1);
    end
    
    % Check download skipping
    if isempty(skipDownload)
        skipDownload = false( length(sensors.varname), 1 );
    else
        assert( length(skipDownload) == length(sensors.varname), ...
            'importDataBus:mismatchedLength', ...
            ['Optional argument ''skipdownload'' must be a vector ' ...
             'with length equal to the number of sensors.'] );
    end
    
    % Convert start date to epoch time in ms (required for DataBus)
    epochStart = etime( datevec(start, tFormat), ...
        [1970 1 1 0 0 0] ) - tz * 3600;
    epochStart = epochStart * 1000; % s -> ms
    
    % Convert end date to epoch time in ms (required for DataBus)
    epochEnd = etime( datevec(stop, tFormat), ...
        [1970 1 1 0 0 0] ) - tz * 3600;
    epochEnd = epochEnd * 1000; % s -> ms
    
    %% Process Data
    % For each sensor, form the DataBus URL, launch a browser, and prompt
    % the user to save the result
    
    % String versions of epoch times
    epochStartStr = sprintf('%i', epochStart);
    epochEndStr   = sprintf('%i', epochEnd);
    
    % Prompt user with login info
    disp( ['You will be prompted to save a CSV file for each ' ...
        'requested sensor.'] );
    disp('Use the following credentials at the DataBus login prompt:');
    fprintf('\t%s\n','Username = robot-CampusModeling');
    fprintf('\t%s\n','Password = 3IALU6ANWW.B2.1DUMFNE91U5YG');
    disp(' ');
    
    % Create output structure
    out = struct();
    
    % Loop through sensors
    for i = 1:length(sensors.varname)
        % Sensor name
        sname = sensors.varname{i};
        
        % Retrieve data from DataBus
        if ~skipDownload(i)
            % Form DataBus url
            url = ['https://databus.nrel.gov/api/csv/rawdataV1/' ...
                sensors.tablename{i} '/' epochStartStr '/' epochEndStr];
            
            % Launch browser
            fprintf( ...
                'Launching external browser for sensor %s (%s)... ', ...
                sname, sensors.tablename{i});
            web(url, '-browser');
            fprintf('%s\n','done.');

            fprintf( ...
                'Please save the downloaded data as "%s.csv" now.\n', ...
                sname);
            disp('Press any key to continue...');
            pause
        else
            fprintf( ['Looking for previously downloaded data '...
                'for sensor %s...\n'], sname );
        end
        
        % Find (or promp for) the CSV file
        fname = [sname '.csv'];
        if exist(fname, 'file')
            % Default file name is present
            fprintf('Found file "%s".\n', fname);
        else
            % Default file name not found; prompt for another file name
            fprintf('File "%s" not found.\n', fname);
            fname = input( ...
                sprintf('Please enter file name for sensor %s (%s): ', ...
                sname, sensors.tablename{i}), 's');
            
            % Recheck
            if isempty(fname)
                % No file name given
                fprintf('No file name specified. Skipping sensor %s.\n', ...
                    sname);
            elseif exist(fname, 'file')
                % File name is present
                fprintf('OK! Found user-specified file "%s".\n', fname);
            else
                % Invalid file name
                warning( ...
                    'importDataBus:invalidDataFile', ...
                    ['Could not find file "' fname '". Skipping ' ...
                     'sensor ' sname '.' ] );
                fname = '';
            end
        end
        
        % Load data from file
        if ~isempty(fname)
            % Read CSV file
            try
                d = csvread(fname,1,0);
                t = d(:,1);
                x = d(:,2);
            catch err
                warning( ...
                   'importDataBus:fileReadFailed', ...
                   ['Failed to read CSV file "' fname '". ' ...
                    'MATLAB error message was:\n' err.message ...
                    'Skipping sensor ' sname '.'] );
                t = [];
                x = [];
            end
        else
            % Empty data
            t = [];
            x = [];
        end
        
        % Process data
        if ~isempty(t)            
            % Convert time to seconds from starting time stamp
            t = t - epochStart;
            
            % Convert time to seconds from ms
            t = t / 1000;
        end
        
        % Create time series
        out.(sname) = timeseries(x, t);

        % Assign time series time properties
        out.(sname).TimeInfo.Units = 'seconds';
        out.(sname).TimeInfo.StartDate = start;
        out.(sname).TimeInfo.Format = tFormat;
        
        % Assign time series data properties
        out.(sname).Name = sensors.varname{i};
        out.(sname).DataInfo.Units = sensors.unit{i};
        out.(sname).DataInfo.UserData = sensors.description{i};
        
        % Message
        fprintf('Finished with sensor %s.\n\n', sname);
    end
end
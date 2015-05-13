%% IMPORTDATABUS - Import time series data from DataBus database
%
% NOTE: DataBus has been deprecated for NREL use and is no longer actively
% maintained. This function is provided for legacy purposes.
%
% Imports a raw data stream from NREL's DataBus time series database using
% an HTTP request. Options are available to return the data as a pair of
% vectors (the default), as a matrix, as a MATLAB time series object, or as
% a text string (JSON or CSV); see DETAILS.
%
% SYNTAX:
%   x = importDataBus(sensor, start, stop, ...)
%   [x, t] = importDataBus(sensor, start, stop, ...)
%
% INPUTS:
%   sensor =    The unique name of the DataBus sensor
%   start =     A string specifying the beginning of the time range to
%               import from DataBus; the default format is
%               'yyyy-mm-dd HH:MM:SS'
%   stop =      A string specifying the end of the time range to import
%               from DataBus; the default format is 'yyyy-mm-dd HH:MM:SS'
%   ... =       (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'stop':
%
%   'timezone', [val]      	Time zone offset from GMT (in hours) for start
%                          	and end times. (Default = 0)
%   'timeformat', [val]     Specify the format for the start and end date/
%                           time data.
%                           (Default = 'yyyy-mm-dd HH:MM:SS')
%   'output', [val]         Specify the output format (see DETAILS):
%                               csv     -> CSV text
%                               json    -> JSON text
%                               matrix  -> 2-column matrix (time/value)
%                               ts      -> MATLAB time series
%                               vector  -> seperate value and time vectors
%                           (Default = 'vector')
%   'url', [val]            Root URL for the DataBus API; see DETAILS for
%                           default value
%   'username', [val]       Username for accessing DataBus; see DETAILS for
%                           default value
%   'password', [val]       Password for accessing DataBus; see DETAILS for
%                           default value
%   'urlreadcmd', [val]     Override the default urlread() function; see
%                           COMMENT #4
%
% OUTPUTS:
%   x =       The imported data as a vector (array), a 2-column matrix, a
%             MATLAB time series, or a text string (CSV or JSON); see
%             DETAILS
%   t =       The time vector associated with the data (as MATLAB serial
%             date number); returned only if the output type is 'vector'
%             (the default)
%
% DETAILS:
% By default, this function accesses NREL's internally deployed DataBus
% database using the robot credentials for the Campus Energy Modeling
% project:
%   url =     	https://databus.nrel.gov
%   username =	robot-CampusModeling
%   password =  3IALU6ANWW.B2.1DUMFNE91U5YG
%
% This robot provides read-only access to NREL campus data via DataBus.
% Access is only available within the NREL intranet. For tables that this
% robot is not allowed to access and/or DataBus instances outside of NREL,
% the user may override these credentials via the optional arguments listed
% above.
%
% DataBus returns raw data in either JSON or CSV text format. By default,
% this function converts the raw data to seperate value and time vectors,
% 'x' and 't'. Optionally, the user may specify a different output format
% using the optional argument 'output'. Output format details:
%   JSON            Returns the raw JSON output from DataBus as a string
%   CSV             Returns the raw CSV output from DataBus as a string
%   Vector          Converts the data to two vectors:
%                     x = value
%                     t = time (as MATLAB serial date number)
%   Matrix          Converts the data to a 2-column matrix:
%                     Column 1 = time (as MATLAB serial date number)
%                     Column 2 = value
%   Time series     Converts the data to a MATLAB time series with units of
%                   seconds
% 
% The default behavior is to convert the data to a pair of vectors 'x' and
% 't'.
%
% COMMENTS:
% 1. If MATLAB returns an exception when attempting to access NREL's
%    internal DataBus installation, you may need to manually add the SSL
%    certificate for databus.nrel.gov to Java's list of trusted SSL
%    certificates. For more information and solution instructions, see
%    the following MathWorks support solution:
%       http://www.mathworks.com/support/solutions/en/data/1-3SMHXD/
%
% 2. If you use a time format other than the ISO standard, yyyy-mm-dd
%    HH:MM:SS, then you must specify the format used in the optional
%    argument 'timeformat'. See the documentation for MATLAB's datenum()
%    function for details. Note that the start and end times are always in
%    the local time zone (UTC by default).
%
% 3. For time zones other than UTC, the optional argument 'timezone' must
%    be specified to convert local time to UTC in order to query DataBus
%    properly. For MST, use -7; for MDT, use -6.
%
% 4. Access to DataBus requires basic authentication. Prior to MATLAB
%    2013a, the built-in urlread() command did not support basic
%    authentication. Workarounds (hacks) do exist; see for example:
%       * http://stackoverflow.com/questions/1317931
%       * http://www.mathworks.com/support/solutions/en/data/1-4EO8VK/
%
%    If you are using MATLAB 2012b or earlier, you may choose to write your
%    own replacement function for urlread() (or to use a version downloaded
%    from the internet) and pass the string specifying that function name
%    to importDataBus() via the optional argument 'urlreadcmd'. Your
%    replacement function must accept the following syntax:
%       output = function(url, username, password)
%    For example, you could try the urlread_auth() function from the Stack
%    Overflow post linked above. (Note: said urlread_auth() function is not
%    included with the Campus Energy Modeling library to avoid known
%    copyright and license conflicts.)
%
% TO DO:
% 1. Error and consistency checking of input arguments

function [x, varargout] = importDataBus(sensor, start, stop, varargin)
    %% Defaults
    % Time zone offset
    tz = 0;
    
    % Time format
    tFormat = 'yyyy-mm-dd HH:MM:SS';
    
    % Output format
    output = 'vector';
    
    % Root URL and robot credentials
    rootUrl =   'https://databus.nrel.gov';
    username =  'robot-CampusModeling';
    password =  '3IALU6ANWW.B2.1DUMFNE91U5YG';
    
    % No override for urlread()
    urlreadcmd = [];
    
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
			case {'timeformat'}
                tFormat = argVal;       % Time format
            case {'output'}
                output = argVal;        % Output format
            case {'url'}
                rootUrl = argVal;       % DataBus root URL
            case {'username'}
                username = argVal;      % DataBus username
            case {'password'}
                password = argVal;      % DataBus password
            case {'urlreadcmd'}
                urlreadcmd = argVal;    % urlread() replacement function
            otherwise
                warning('importDataBus:unknownOption', ...
                    ['Optional argument ''' argName ''' is not ' ...
                     'recognized and has therefore been ignored.']);
        end
    end
    
    %% Setup
    % Initialize varargout w/ empty output
    varargout = {};
    
    %% Retrieve Data
    % Convert start and stop dates to epoch time in ms
    % (required by DataBus)   
    epochStart = dateNumToEpoch(datenum(start, tFormat), tz, 'ms');
    epochEnd =   dateNumToEpoch(datenum(stop,  tFormat), tz, 'ms');
    
    % String versions of epoch times
    epochStartStr = sprintf('%i', epochStart);
    epochEndStr   = sprintf('%i', epochEnd);
    
    % Form the DataBus URL
    if strcmpi(output, 'json')
        apiType = 'json';
    else
        apiType = 'csv';
    end
    url = [rootUrl '/api/' apiType '/rawdataV1/' sensor '/' ...
        epochStartStr '/' epochEndStr];
    
    % Read DataBus
    try
        if isempty(urlreadcmd)
            raw = urlread(url, 'Authentication', 'Basic', ...
                'Username', username, 'Password', password);
        else
            raw = eval( [urlreadcmd '(' ...
                '''' url ''',' ...
                '''' username ''',' ...
                '''' password ''')' ] );
        end
    catch me1
        % Create a new exception
        me2 = MException('importDataBus:readError', ...
            'Unable to query DataBus for sensor ''%s'' using url: %s.', ...
            sensor, url);
        me2 = addCause(me2, me1);
        throw(me2);
    end
    
    % Assert non-empty result
    assert( ~isempty(raw), ...
        'importDataBus:noData', ...
        ['DataBus returned no data for sensor ''%s'' for the ' ...
         'specified time range'], ...
        sensor);
    
    %% Convert Data
    % Parse data, if required
    if any( strcmpi(output, {'vector','matrix','ts'}) )
        % Parse raw numbers
        d = textscan(raw, '%f%f', 'HeaderLines', 1, 'delimiter', ',', ...
            'treatAsEmpty', {'NA', 'null'} );
        
        % Convert to output
        t = epochToDateNum(d{1}, tz, 'ms');
        x = d{2};
        
        % Strip empties
        empt = (isnan(x) | isnan(t));
        x = x( ~empt );
        t = t( ~empt );
    end
    
    % Convert to requested output format
    switch lower(output)
        case 'vector'
            % Use vectors 'x' and 't' as is
            varargout{1} = t;
            
        case 'matrix'
            % Construc matrix
            x = [t, x];
            
        case 'ts'
            % Offset time vector by start time
            t = t - datenum(start, tFormat);
            
            % Convert time to seconds
            t = t * 86400;
            
            % Create time series
            x = timeseries(x, t);
 
            % Assign time series time properties
            x.TimeInfo.Units = 'seconds';
            x.TimeInfo.StartDate = start;
            x.TimeInfo.Format = tFormat;

            % Assign time series data properties
            x.Name = sensor;
            
        case {'json','csv'}
            % Use raw output
            x = raw;
    end
end


%% Subfunctions
% Convert epoch time to MATLAB serial date number
% 
% INPUTS:
%   epoch =	Epoch time
%   tz =    Time zone offset from UTC (in hours)
%   unit =	Input unit: 's' for seconds, 'ms' for milliseconds
%
% OUTPUTS:
%   dn =    MATLAB serial date number corresponding to 'epoch'
function dn = epochToDateNum(epoch, tz, unit)
    % If unspecified assume unit of seconds
    if nargin < 3
        unit = 's';
    end
    
    % Convert to units of days
    switch unit
        case 's'
            epoch = epoch / 3600 / 24;
        case 'ms'
            epoch = epoch / 1000 / 3600 / 24;
    end       
    
    % Convert to serial date number
    dn = datenum([1970, 1, 1, 0, 0, 0]) + epoch + tz/24;
end

% Convert MATLAB serial date number to epoch time
% 
% INPUTS:
%   dn =    MATLAB serial date number
%   tz =    Time zone offset from UTC (in hours)
%   unit =	Desired output unit: 's' for seconds, 'ms' for milliseconds
%
% OUTPUTS:
%   epoch =	Epoch time corresponding to 'dn'
function epoch = dateNumToEpoch(dn, tz, unit)
    % If unspecified assume unit of seconds
    if nargin < 3
        unit = 's';
    end
    
    % Convert to epoch time
    epoch = etime( datevec(dn), [1970, 1, 1, 0, 0, 0] ) - tz * 3600;
    
    % Output in 'ms' if desired
    if strcmpi(unit, 'ms')
        epoch = epoch * 1000;
    end
end


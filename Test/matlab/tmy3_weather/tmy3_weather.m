%% tmy3_weather.m - Tests conversion of TMY3 weather data to time series
% 
% This script tests the convertTMY3() function, which converts data from
% TMY3-formatted CSV files to a structure of MATLAB time series objects.
%
% Test data is drawn from TMY3 data for Golden, CO, and TMY3-formatted
% actual weather data for NREL for June 2012.
%
% FUNCTIONS:
%   utilities: convertTMY3

%% Setup
% Data files
fyear  = ['..' filesep '..' filesep 'data' filesep '724666TY.csv'];
fmonth = ['..' filesep '..' filesep 'data' filesep '201206ty.csv'];

%% Default Settings
% Use convertTMY3() conversion utility with default settings
dyear  = convertTMY3(fyear);	% TMY3 data - full year
dmonth = convertTMY3(fmonth);	% Actual data - 1 month

%% Offsets
% The default offset is -0.5; see comvertTMY3() documentation

% Use 0 offset as baseline
dyear1 = convertTMY3(fyear, 'offset', 0);

% Use +1 hr offset; check resulting timestamps
dyear2 = convertTMY3(fyear, 'offset', 1);
assert( all(dyear2.GHI.Time - dyear1.GHI.Time == 3600), ...
    'tmy3_weather:offsetError', ...
    ['''offset'' optional argument in convertTMY3() did not produce ' ...
    'the expected offset in seconds.'] );

% Use -0.5 hr offset; check resulting timestamps
dyear2 = convertTMY3(fyear, 'offset', -0.5);
assert( all(dyear2.GHI.Time - dyear1.GHI.Time == -1800), ...
    'tmy3_weather:offsetError', ...
    ['''offset'' optional argument in convertTMY3() did not produce ' ...
    'the expected offset in seconds.'] );

%% Use Actual Dates
% Use actual dates for June 2012 NREL data and check resulting time series
dmonth = convertTMY3(fmonth, '--UseOriginalTimestamps');

% Check start date and time (also checks for correct formatting)
assert( strcmpi(dmonth.GHI.TimeInfo.StartDate, '2012-06-01 00:30:00'), ...
    'tmy3_weather:incorrectStartTime', ...
    'convertTMY3() did not import the expected start time and date.' );

%% Specify Custom Fields
% Format specification for importing only GHI
columnSpec.col =        [1, 2, 5];
columnSpec.name =       {'date','time','GHI'};
columnSpec.unit =       {'mm/dd/yyyy','HH:MM','Wh/m²'};
columnSpec.datatype =   {'%s','%s','%f'};
columnSpec.desc =       {'Date','Time','Global Horizontal Irradiance'};

% Default
dyear1 = convertTMY3(fyear);

% Custom
dyear2 = convertTMY3(fyear, 'columnSpec', columnSpec);

% Compare
assert( all(dyear2.GHI.Data == dyear1.GHI.Data), ...
    'tmy3_weather:importError', ...
    ['Importing identical data with custom column specification ' ...
     'in convertTMY3() did not produce idential result.'] );

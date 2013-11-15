%% BATCHDATABUS - Batch import time series data from DataBus database
%
% This is a user-friendly function to batch import sensor data from NREL's
% DataBus database. After import, the data are converted to a structure
% of MATLAB time series objects compatible with the Simulink 'From File'
% block.
%
% To use the output of batchDataBus() in Simulink, save the result to a
% .MAT file in the variable 'ans' and load it into Simulink using a 'From
% File' block.
%
% SYNTAX:
%   x = batchDataBus(sensor, start, stop, ...)
%
% INPUTS:
%   sensors =   A structure specifying sensor metadata, OR the name of a 
%               CSV file specifying the sensor metadata (see DETAILS)
%   start =     A string specifying the beginning of the time range to
%               import from DataBus; the default format is
%               'yyyy-mm-dd HH:MM:SS'
%   stop =      A string specifying the end of the time range to import
%               from DataBus; the default format is 'yyyy-mm-dd HH:MM:SS'
%   ... =       (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   With the exception of 'output' (which is always a MATLAB time series),
%   batchDataBus() supports the same optional arguments as importDataBus();
%   see the documentation for importDataBus() for details.
%
% OUTPUTS:
%   x =         A MATLAB structure containing time series corresponding to
%               the DataBus data, in time units of seconds.
%
% DETAILS:
% Sensor metadata for the 'sensors' input should be either a structure or
% the name of a CSV file with the following fields/columns specified for
% each sensor:
%   varname     The MATLAB variable name to use in the function output
%   dbname      The canonical sensor name in DataBus
%   unit        (Optional) A text string giving the unit for the sensor
%   description (Optional) A text string describing the sensor
%
% If specified, 'unit' and 'description' will be embedded within the MATLAB
% time series metadata in the function output.
%
% COMMENTS:
% 1. batchDataBus() is a utility wrapper for importDataBus(). For a
%    technical discussion of DataBus access from within MATLAB, see the
%    documentation for importDataBus()
%
% 2. For time zones other than UTC, the optional argument 'timezone' must
%    be specified to convert local time to UTC in order to query DataBus
%    properly. For MST, use -7; for MDT, use -6.
%
% 3. The output structure organization matches Simulink's requirements for
%    using a 'From File' block to import time series data. It would also be
%    possible to create a single time series with multiple data columns or
%    a 'tscollection' object containing the individual time series.
%    However, these approaches are less extensible in Simulink.

function x = batchDataBus(sensors,start,stop,varargin)    
    %% Process Optional Arguments
    % Override 'output' for varargin, but leave others to pass to
    % importDataBus()
    idx = find( strcmpi('output',varargin) );
    if isempty(idx)
        varargin = [varargin, {'output', 'ts'}];
    else
        varargin(idx + 1) = {'ts'};
    end
    
    %% Setup
    % Load sensor metadata from file
    if ischar(sensors)
        % Open CSV
        fid = fopen(sensors,'r');
        assert(fid >= 0, ...
            'batchDataBus:fileNotFound', ...
            ['Specified sensor metadata file name ''' sensors '''' ...
             'is not present in the current MATLAB path.']);
        
        % Read column names
        cols = textscan(fid, '%s\n', 1, 'delimiter', '');
        cols = strsplit( cols{:}{:}, ',' );
        
        % Read 
        C = textscan(fid, repmat('%s', 1, length(cols)), 'delimiter', ',');
        fclose(fid);
        
        % Convert to structure
        sensors = struct();
        for i = 1:length(cols)
            sensors.(cols{i}) = C{:,i};
        end
    end
    
    % Assert structure
    assert( isstruct(sensors), ...
        'batchDataBus:invalidSensorMetadata', ...
        'Sensor metadata must be specified in a structure.');
        
    % Create any missing fields
    if ~isfield(sensors, 'unit')
        sensors.unit = cell(length(sensors.varname), 1);
    end
    if ~isfield(sensors, 'description')
        sensors.description = cell(length(sensors.varname), 1);
    end
    
    %% Process and Return Data
    % Set up output structure
    x = struct();
    
    % For each sensor, use importDataBus() to download the data
    for i = 1:length(sensors.varname)
        % Sensor name
        sname = sensors.varname{i};
        
        % Retrieve data
        x.(sname) = ...
            importDataBus(sensors.dbname{i}, start, stop, varargin{:});
        
        % Assign time series data properties
        x.(sname).Name = sensors.varname{i};
        x.(sname).DataInfo.Units = sensors.unit{i};
        x.(sname).DataInfo.UserData = sensors.description{i};
    end
end
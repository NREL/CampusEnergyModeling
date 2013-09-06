%% RUNSSC - Run SSC Module
%
% Runs a Sam Simulation Core (SSC) module using the specified data and
% returns the result.
%
% SYNTAX:
%   output = runSSC(module, input, output, ...)
%
% INPUTS:
%   module =	The name of the SSC module to run
%   input =     A structure array containing input variables to pass to the
%               SSC module; see comments
%   output =    A structure array containing information on the output 
%               variables to return from the SSC module; see comments
%   ... =       (Optional) Additional arguments passed as name-value pairs
%               (see OPTIONAL INPUTS below)
%
% OUTPUTS:
%   output =    A modified output structure array containing the values
%               read from the SSC module, OR, a structure containing MATLAB
%               time series corresponding to the outputs (see '--ts' in
%               OPTIONAL INPUTS below)
%
% OPTIONAL INPUTS:
%   The following optional inputs may be passed as name-value pairs
%   following 'filename':
%
%   'offset', [val]             Specify the time offset for the generated
%                               vector of hourly data. Applies only for a
%                               time series output. (Default = -0.5)
%
%   The following optional inputs may be passed as flags following
%   'filename' and interspersed with any name-value pair above:
%
%   '--unload'                  Unload the SSC library after executing the
%                               function
%   '--ts'                      Format the output as a structure of MATLAB
%                               time series compatible with the Simulink
%                               'From File' block. If this option is
%                               selected, an hourly time step in the
%                               output data is assumed.
%
% COMMENTS:
% 1. Both 'input' and 'output' are structure arrays with fields:
%       Name    Name of the SSC input or output variable
%       Type    SSC variable type (one of 'string', 'number', 'array',
%               'matrix', or 'table')
%       Value   SSC variable value (required for 'input' only;
%               automatically created for 'output')
%    A structure array returned from importSSC() will have the correct
%    fields for use with runSSC() and may also be used as a template for 
%    constructing 'output'.
%
% 2. Errors from SSC.ssccall() are not handled; check the SSC documentation
%    if you see errors.
%
% 3. If sending outputs to time series, be sure that the requested variable
%    names are valid structure field names. Otherwise, an error will occur.

function output = runSSC(module, input, output, varargin)
    %% Setup
    % Load SSC library
    SSC.ssccall('load');
    
    % Defaults:
    doUnload = false;
    asTimeSeries = false;
    offset = -0.5;
    
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
			case {'--unload'}
                doUnload = true;        % Unload SSC library
                continue;
			case {'--ts'}
                asTimeSeries = true;    % Return outputs as time series
                continue;
        end
        
        % Get value part of name-value pair
        argVal = varargin{i}; i = i + 1;
        
        % Assign optional values accordingly
        switch argName
			case {'offset'}
                offset = argVal;        % Time offset for time series
            otherwise
                warning('runSSC:unknownOption', ...
                    ['Optional argument ''' argName ''' is not ' ...
                     'recognized and has therefore been ignored.']);
        end
	end
    
    %% Parse Input Data
    % Create an SSC data container
    data = SSC.ssccall('data_create');
    
    % Populate data container
    for i = 1:length(input)
        % Get data
        name = input(i).Name;
        type = input(i).Type;
        val  = input(i).Value;
        
        % Store in data container
        SSC.ssccall(['data_set_' type], data, name, val);
    end
    
    %% Run Simulation
    % Create the module
    module = SSC.ssccall('module_create', module);
    
    % Run the simulation
    ok = SSC.ssccall('module_exec', module, data);
    
    % Check for errors
    if ~ok
        % Get error messages
        i = 0;
        msg = '';
        while true,
            err = SSC.ssccall('module_log', module, i);
            if strcmp(err,''),
                break;
            else
                msg = [msg err '\n'];
                i = i + 1;
            end
        end
        
        % Throw error
    	error('runSSC:sscError', ['SSC library returned errors:\n' msg]);
    end
        
    %% Extract Results
    % For each requested output
    for i = 1:length(output)
        % Get data
        name = output(i).Name;
        type = output(i).Type;
        
        % Store in data container
        output(i).Value = SSC.ssccall(['data_get_' type], data, name);
    end
    
    % Format as time series if requested
    if asTimeSeries
        newOut = struct();
        for i = 1:length(output)
            % Name
            n = output(i).Name;

            % Move existing data
            newOut.(n) = output(i);

            % Change to time series
            t = ((1:length(output(i).Value)) + offset) * 3600;
            x = timeseries(output(i).Value, t);

            % Assign time series time properties
            x.TimeInfo.Units = 'seconds';
            x.TimeInfo.Format = 0;

            % Assign time series data properties
            x.Name = output(i).Name;
            if isfield(output(i), 'Units')
                x.DataInfo.Units = output(i).Units;
            end
            if isfield(output(i), 'Description')
                x.DataInfo.UserData = output(i).Description;
            end

            % Store time series
            newOut.(n).Value = x;
        end
        output = newOut;
    end
    
    %% Cleanup
    % Free the SSC module that we created
    SSC.ssccall('module_free', module);
    
    % Release the data container and all of its variables
    SSC.ssccall('data_free', data);
    
    % Unload SSC library
    if doUnload
        SSC.ssccall('unload');
    end
end
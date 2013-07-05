%% S-Function: Implements the 'PVWatts' S-function Simulink block
% This function implements the 'PVWatts' block in the NREL Campus Modeling
% Simulink block library as an S-function.

function pvwatts_sfun(block)
    % Set the basic attributes of the S-function and registers the required
    % callbacks
    setup(block);
end

%% Setup
% Set up the S-function block's basic characteristics
function setup(block)
    %% Parameters
    % Register the number of parameters
    block.NumDialogPrms = 21;
    
    % Manually trigger CheckParameters() to check the dialog parameters
    CheckParameters(block)
    
    % Parse the dialog parameters
    ParseParameters(block)
    
    % Retrieve parameters from user data
    d = get_param(block.BlockHandle, 'UserData');
    
    % Retrieve time step
    time_step = d.dialog.time_step;
    
    %% Ports
    % Input ports:
    %   1 - Beam irradiance
    %   2 - Diffuse irradiance
    %   3 - Ambient temperature
    %   4 - Wind speed
    %
    % Output ports (on/off configurable):
    %   Array DC power
    %   Cell temperature
    %   Plane of array irradiance
    
    % Register the number of input ports
    block.NumInputPorts  = 4;
    
    % Register the number of output ports
    output_dc = d.dialog.output_dc;
    output_celltemp = d.dialog.output_celltemp;
    output_poa = d.dialog.output_poa;
    block.NumOutputPorts = output_dc + output_celltemp + output_poa;
    
    % Set out the assignment of output ports to outputs
    outNames = {'dc', 'tcell', 'poa'};
    outNames = outNames( ...
        logical([output_dc, output_celltemp, output_poa]) );
    d.outputs = struct( 'VarName', outNames, ...
        'OutputPort', num2cell(1:length(outNames)) );
    
    % Set input port properties
    for i = 1:block.NumInputPorts
        block.InputPort(i).Dimensions = 1;
        block.InputPort(i).DatatypeID  = 0;
        block.InputPort(i).Complexity  = 'Real';
        block.InputPort(i).SamplingMode  = 'Sample';
        block.InputPort(i).DirectFeedthrough = 1;
    end
    
    % Set output port properties
    for i = 1:block.NumOutputPorts
        block.OutputPort(i).Dimensions = 1;
        block.OutputPort(i).DatatypeID  = 0;
        block.OutputPort(i).Complexity  = 'Real';
        block.OutputPort(i).SamplingMode  = 'Sample';
    end
    
    % Register the sample times: Discrete; no offset
    block.SampleTimes = [time_step 0];
    
    %% Options
    % Set the block simStateCompliance to default
    % (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';
    
    %% Register S-function methods
    % Check dialog parameters
    block.RegBlockMethod('CheckParameters', @CheckParameters);
    
	% Simulation start
    block.RegBlockMethod('Start', @Start);
    
    % Compute output (required)
    block.RegBlockMethod('Outputs', @Outputs);
    
    % Simulation end (required)
    block.RegBlockMethod('Terminate', @Terminate);
    
    %% Save User Data
    % Save user data back to block for later access
    set_param(block.BlockHandle, 'UserData', d);
end

%% Check Parameters
% Checks the dialog parameters
function CheckParameters(block)
    % TO DO: Implement this function.
    
end

%% Parse Parameters
% Parse the dialog parameters and store them in the block user data
function ParseParameters(block)
    % Get existing user data, if any
    d = get_param(block.BlockHandle, 'UserData');
    if isempty(d)
        d = struct();
    end
    
    % Define names of dialog parameters (in order)
    dialogNames = { ...
        'lat', 'lon', 'start_time', 'tz', 'time_step', 'system_size', ...
        'derate', 'azimuth', 'tilt', 'track_mode', 'rotlim', 't_ref', ...
        't_noct', 'gamma', 'i_ref', 'poa_cutin', 'init_tcell', ...
        'init_poa', 'output_dc', 'output_celltemp', 'output_poa' };
    
    % Put dialog parameters into data structure
    d.dialog = struct();
    for i = 1:length(dialogNames)
        d.dialog.(dialogNames{i}) = block.DialogPrm(i).Data;
    end
    
    % Store in block user data; set as persistent
    set_param(block.BlockHandle, 'UserData', d);
    set_param(block.BlockHandle, 'UserDataPersistent', 'on');
end

%% Start Simulation
% Executes initialization when the simulation starts
function Start(block)
    % Retrieve user data
    d = get_param(block.BlockHandle, 'UserData');
    
    % Compute simulation start time as a date number
    d.simstart = datenum(d.dialog.start_time, 'dd-mmm-yyyy HH:MM:SS');

    % Convert dialog parameters to values useable by pvwattsfunc (SSC)
    d.sscvar = struct();
    d.sscvar.lat = d.dialog.lat;
    d.sscvar.lon = d.dialog.lon;
    d.sscvar.tz = -d.dialog.tz;                         % TO DO: Check this timezone conversion
    d.sscvar.time_step = d.dialog.time_step / 3600;     % sec -> hr
    d.sscvar.system_size = d.dialog.time_step / 1000;   % W -> kW
    d.sscvar.derate = d.dialog.derate;
    d.sscvar.track_mode = d.dialog.track_mode - 1;
    d.sscvar.azimuth = d.dialog.azimuth;
    d.sscvar.tilt = d.dialog.tilt;
    d.sscvar.rotlim = d.dialog.rotlim;
    d.sscvar.t_noct = d.dialog.t_noct;
    d.sscvar.t_ref = d.dialog.t_ref;
    d.sscvar.gamma = d.dialog.gamma;
    d.sscvar.i_ref = d.dialog.i_ref;
    d.sscvar.poa_cutin = d.dialog.poa_cutin;
    d.sscvar.tcell = d.dialog.init_tcell;
    d.sscvar.poa = d.dialog.init_poa;
    
    % NOTES:
    % 1. 'year', 'month', 'day', 'hour', and 'minute' are set during each
    %    output calculation by parsing the current simulation time
    % 2. Timezone 'tz' must be converted from a UTC offset in hours to the
    %    internal format required by pvwattsfunc (TO DO: which is what?)
    % 3. 'track_mode' is offset by -1 to convert from a 1-4 scale to 0-3.
    
    % Initialize pvwattsfunc module in SSC...
    % Load SSC library
    SSC.ssccall('load');
    
    % Create SSC data container
    d.sscdata = SSC.ssccall('data_create');
    
    % Populate data container
    fn = fieldnames(d.sscvar);
    for i = 1:length(fn)
        n = fn{i};
        SSC.ssccall('data_set_number', d.sscdata, n, d.sscvar.(n));
    end
    
    % Create SSC pvwattsfunc module
    d.sscmodule = SSC.ssccall('module_create', 'pvwattsfunc');
    
    % Store in block user data
    set_param(block.BlockHandle, 'UserData', d);
end

%% Compute Outputs
% Computes the S-function outputs
function Outputs(block)
    % Retrieve user data
    d = get_param(block.BlockHandle, 'UserData');
    
    % Compute current simulation time, rounded to nearest minute
    currentTime = d.simstart * 86400 + block.CurrentTime;   % sec
    currentTime = round( currentTime / 60 ) * 60;           % sec
    currentTime = currentTime / 86400;                      % days
    
    % Convert to required SSC format
    v = datevec(currentTime);
    d.sscvar.year = v(1);
    d.sscvar.month = v(2);
    d.sscvar.day = v(3);
    d.sscvar.hour = v(4);
    d.sscvar.minute = v(5);

    % Store in SSC data container
    fn = {'year','month','day','hour','minute'};
    for i = 1:length(fn)
        n = fn{i};
        SSC.ssccall('data_set_number', d.sscdata, n, d.sscvar.(n));
    end
    
    % Get Simulink inputs
    d.sscvar.beam =     block.InputPort(1).Data;
    d.sscvar.diffuse =  block.InputPort(2).Data;
    d.sscvar.tamb =     block.InputPort(3).Data;
    d.sscvar.wspd =     block.InputPort(4).Data;
    
    % Store in SSC data container
    fn = {'beam','diffuse','tamb','wspd'};
    for i = 1:length(fn)
        n = fn{i};
        SSC.ssccall('data_set_number', d.sscdata, n, d.sscvar.(n));
    end
    
    % Run pvwattsfunc in SSC
    ok = SSC.ssccall('module_exec', d.sscmodule, d.sscdata);
    
    % Check for errors
    if ~ok
        % Get error messages
        i = 0;
        msg = '';
        while true,
            err = SSC.ssccall('module_log', d.sscmodule, i);
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
    
    % Retrieve results
    fn = {'tcell','poa','dc'};
    for i = 1:length(fn)
        n = fn{i};
        d.sscvar.(n) = ...
            double( SSC.ssccall('data_get_number', d.sscdata, n) );
    end
    
    % Write to output ports
    for i = 1:length(d.outputs)
        block.OutputPort(d.outputs(i).OutputPort).Data = ...
            d.sscvar.(d.outputs(i).VarName);
    end
    
    % Store in block user data
    set_param(block.BlockHandle, 'UserData', d);
end

%% Simulation End
% Executes clean up when the simulation ends
function Terminate(block)
    % Retrieve user data
    d = get_param(block.BlockHandle, 'UserData');

    % Free the pvwattsfunc module that we created
    SSC.ssccall('module_free', d.sscmodule);
    d.sscmodule = [];
    
    % Release the data container and all of its variables
    SSC.ssccall('data_free', d.sscdata);
    d.sscdata = [];
    
    % Unload SSC library
    SSC.ssccall('unload');
    
    % Store in block user data
    set_param(block.BlockHandle, 'UserData', d);
end

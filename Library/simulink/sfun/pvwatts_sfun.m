%% PVWATTS_SFUN - Implements the 'PVWatts' Simulink block
%
% This function implements the 'PVWatts' block in the NREL Campus Energy
% Modeling Simulink block library as an S-function.
%
% SYNTAX:
%   pvwatts_sfun(block)
%
% INPUTS:
%   block =     Simulink block which uses the S-function
%
% COMMENTS:
% 1. This is a Simulink S-function. Its structure and conventions conform
%    with the Simulink documentation for S-functions; for more info. see
%    doc('S-Function').
% 
% 2. This function is not intended for use outside of the NREL Campus
%    Energy Modeling Simulink library; therefore the error checking and
%    documentation are minimal. View the code to see what is going on.

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
    % 1. 'lat' - Array latitude
    lat = block.DialogPrm(1).Data;
    assert( isnumeric(lat), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Latitude must be a number.' );
    assert( -90 <= lat && lat <= 90, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Latitude must be greater than or equal to -90° and less than ' ...
         'or equal to +90°.'] );
    
    % 2. 'lon' - Array longitude
    lon = block.DialogPrm(2).Data;
    assert( isnumeric(lon), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Longitude must be a number.' );
    assert( -180 <= lon && lon <= 180, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Longitude must be greater than or equal to -180° and less ' ...
         'than or equal to +180°.'] );
    
    % 3. 'start_time' - Simulation starting timestamp
    start_time = block.DialogPrm(3).Data;
    try
        datenum(start_time, 'yyyy-mm-dd HH:MM:SS');
    catch err
        error('CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
            ['Starting timestamp must be given in the form ' ...
             'yyyy-mm-dd HH:MM:SS'] );
    end
    
    % 4. 'tz' - Time zone (offset from UTC)
    tz = block.DialogPrm(4).Data;
    assert( isnumeric(tz), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Time zone must be a number (offset in hours from UTC).' );
    assert( -12 <= tz && tz <= 12, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Time zone must be specified as an offset in hours from ' ...
         'UTC between -12 and +12, inclusive.'] );
    
    % 5. 'time_step' - Cosimulation time step (s)
    time_step = block.DialogPrm(5).Data;
    assert( isnumeric(time_step) && time_step > 0, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Simulation time step must be a positive number.' );
    
    % 6. 'system_size' - System nameplate capacity (W)
    system_size = block.DialogPrm(6).Data;
    assert( isnumeric(system_size), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'System size must be a number.' );
    assert( 50 <= system_size && system_size <= 500000000, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['System size must be a positive number between 50 W and ' ...
         '500000000 W, inclusive.'] );
    
    % 7. 'derate' - System derating factor
    derate = block.DialogPrm(7).Data;
    assert( isnumeric(derate), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'System derate factor must be a number.' );
    assert( 0 <= derate && derate <= 1, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['System derate factor must be a positive number between 0 ' ...
         'and 1, inclusive.'] );
    
    % 8. 'azimuth' - Array azimuth angle (deg)
    azimuth = block.DialogPrm(8).Data;
    assert( isnumeric(azimuth), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Array azimuth angle must be a number.' );
    assert( 0 <= azimuth && azimuth <= 360, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Array azimuth angle must be greater than or equal to 0° ' ...
         'and less than or equal to 360°.'] );
     
    % 9. 'tilt' - Array tile angle (deg)
    tilt = block.DialogPrm(9).Data;
    assert( isnumeric(tilt), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Array tilt angle must be a number.' );
    assert( 0 <= tilt && tilt <= 90, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Array tilt angle must be greater than or equal to 0° ' ...
         'and less than or equal to 90°.'] );
    
    % 11. 'rotlim' - Array rotation limit (deg)
    rotlim = block.DialogPrm(11).Data;
    assert( isnumeric(rotlim), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Array rotation limit angle must be a number.' );
    assert( 1 <= rotlim && rotlim <= 90, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Array rotation limit angle must be greater than or equal ' ...
         'to 1° and less than or equal to 90°.'] );
    
    % 12. 't_ref' - Reference cell temperature (deg C)
    t_ref = block.DialogPrm(12).Data;
    assert( isnumeric(t_ref) && t_ref > 0, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Reference cell temperature must be a positive number.' );
    
    % 13. 't_noct' - Nominal operating cell temperature (deg C)
    t_noct = block.DialogPrm(13).Data;
    assert( isnumeric(t_noct) && t_noct > 0, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Nominal operating cell temperature must be a positive ' ...
         'number.'] );
    
    % 14. 'gamma' - Max. power temperature coefficient (%/deg C)
    gamma = block.DialogPrm(14).Data;
    assert( isnumeric(gamma), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Maximum power temperature coefficient must be a number.' );
    
    % 15. 'i_ref' - Reference condition irradiance (W/m^2)
    i_ref = block.DialogPrm(15).Data;
    assert( isnumeric(i_ref) && i_ref > 0, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Reference irradiance for cell rating must be a positive ' ...
         'number.'] );
    
    % 16. 'poa_cutin' - Minimum irradiance for operation (W/m^2)
    poa_cutin = block.DialogPrm(16).Data;
    assert( isnumeric(poa_cutin) && poa_cutin >= 0, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Minimum irradiance for cell operation must be a nonnegative ' ...
         'number.'] );
    
    % 17. 'init_tcell' - Initial cell temperature (deg C)
    init_tcell = block.DialogPrm(17).Data;
    assert( isnumeric(init_tcell), ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        'Initial cell temperature must be a number.' );
    
    % 18. 'init_poa' - Initial plane of array irradiance (W/m^2)
    init_poa = block.DialogPrm(18).Data;
    assert( isnumeric(init_poa) && init_poa >= 0, ...
        'CampusEnergyModeling:PVWatts:invalidMaskParameter', ...
        ['Initial plane of array irradiance must be a nonnegative ' ...
         'number.'] );
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
    d.simstart = datenum(d.dialog.start_time, 'yyyy-mm-dd HH:MM:SS');

    % Convert dialog parameters to values useable by pvwattsfunc (SSC)
    d.sscvar = struct();
    d.sscvar.lat = d.dialog.lat;
    d.sscvar.lon = d.dialog.lon;
    d.sscvar.tz = d.dialog.tz;
    d.sscvar.time_step = d.dialog.time_step / 3600;     % sec -> hr
    d.sscvar.system_size = d.dialog.system_size / 1000; % W -> kW
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
    % 2. 'track_mode' is offset by -1 to convert from a 1-4 scale to 0-3.
    
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
    % (Note data cleaning to avoid invalid inputs)
    d.sscvar.beam =     max(block.InputPort(1).Data, 0);
    d.sscvar.diffuse =  max(block.InputPort(2).Data, 0);
    d.sscvar.tamb =     max(block.InputPort(3).Data, -273.15);
    d.sscvar.wspd =     max(block.InputPort(4).Data, 0);
    
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

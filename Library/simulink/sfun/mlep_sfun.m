%% MLEP_SFUN - Implements the 'E+ Model' Simulink block
%
% This function implements the 'E+ Model' block in the NREL Campus Energy
% Modeling Simulink block library as an S-function. The S-function provides
% and interface between Simulink and EnergyPlus using MLE+.
% 
% This S-function is modified from the original function written by Truong
% Nghiem and distributed with MLE+ v. 1.1. It is modified and redistributed
% under the [TO DO: FIGURE THIS OUT] license.
%
% SYNTAX:
%   mlep_sfun(block)
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
%
% HISTORY:
%   Nov. 2010       Original version by Truong Nghiem
%                   (nghiem@seas.upenn.edu) with support for BCVTB
%                   protocol v. 2.
%                   
%                   Original code (C) 2010 by Truong Nghiem;
%                   reused with permission.
%
%   Aug. 2013       Modified by Willy Bernal (willyg@seas.upenn.edu) for
%                   use with the NREL Campus Energy Modeling project
%
%   Nov. 2013       Modified by Stephen Frank for readability and ease of
%                   use
%

function mlep_sfun(block)
    % Set the basic attributes of the S-function and registers the required
    % callbacks
    setup(block);
end

%% Setup
% Set up the S-function block's basic characteristics
function setup(block)
    %% Parameters
    % Register the number of parameters
    block.NumDialogPrms = 11;
    
    % TO DO: Implement CheckParameters()
    
    % Manually trigger CheckParameters() to check the dialog parameters
    %CheckParameters(block)
    
    % Parse the dialog parameters
    ParseParameters(block)
    
    % Retrieve parameters from user data
    d = get_param(block.BlockHandle, 'UserData');

    %% Ports
    % Input ports:
    %   1 - Vector of EnergyPlus inputs
    %
    % Output ports:
    %   1 - Termination/error flag
    %   2 - EnergyPlus time stamp
    %   3 - Vector of EnergyPlus outputs
    
    % Register the number of input ports
    block.NumInputPorts  = 1;
    
    % Register the number of output ports
    block.NumOutputPorts = 3;

    % Setup port properties to be dynamic
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;
    
    % Override input port properties
    block.InputPort(1).Dimensions  = -1;            % inherited size
    block.InputPort(1).DatatypeID  = 0;             % double
    block.InputPort(1).Complexity  = 'Real';
    block.InputPort(1).DirectFeedthrough = true;
    
    % Override output port properties
    block.OutputPort(1).Dimensions  = 1;            % flag
    block.OutputPort(1).DatatypeID  = 0;            % double
    block.OutputPort(1).Complexity  = 'Real';
    block.OutputPort(1).SamplingMode = 'sample';

    block.OutputPort(2).Dimensions  = 1;            % time
    block.OutputPort(2).DatatypeID  = 0;            % double
    block.OutputPort(2).Complexity  = 'Real';
    block.OutputPort(2).SamplingMode = 'sample';

    nDim = d.dialog.nout;
    block.OutputPort(3).Dimensions  = nDim;         % output vector
    block.OutputPort(3).DatatypeID  = 0;            % double
    block.OutputPort(3).Complexity  = 'Real';
    block.OutputPort(3).SamplingMode = 'sample';

    %% Options
    % Register the sample times: Discrete; no offset
    block.SampleTimes = [d.dialog.time_step 0];
    
    % Set the block simStateCompliance to default
    % (i.e., same as a built-in block)
    block.SimStateCompliance = 'DefaultSimState';

    %% Register S-function methods
    % Initialize conditions
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    
    % Set input port properties
    block.RegBlockMethod('SetInputPortDimensions', @SetInputPortDimensions);
    block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
    
    % Check dialog parameters
    %block.RegBlockMethod('CheckParameters', @CheckParameters);
    
	% Simulation start
    block.RegBlockMethod('Start', @Start);
    
    % Compute output (required)
    block.RegBlockMethod('Outputs', @Outputs);
    
    % Simulation end (required)
    block.RegBlockMethod('Terminate', @Terminate);
    
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
        'work_dir', ...         % Working directory
        'rel_path', ...         % Working directory is relative path (T/F)
        'fname', ...            % Name of IDF file
        'weather_profile', ...  % Name of weather profile file
        'time_step', ...        % Model time step
        'nout', ...             % Number of real outputs
        'timeout', ...          % Communication timeout
        'eplus_path', ...       % Path to EnergyPlus executable
        'bcvtb_dir', ...        % Path to BCVTB library
        'port', ...             % Socket port
        'host' };               % Host machine
    
    % Put dialog parameters into data structure
    d.dialog = struct();
    for i = 1:length(dialogNames)
        d.dialog.(dialogNames{i}) = block.DialogPrm(i).Data;
    end
    
    % Store in block user data; set as persistent
    set_param(block.BlockHandle, 'UserData', d);
    set_param(block.BlockHandle, 'UserDataPersistent', 'on');
end


%% Set sampling mode for input ports
% Not sure if really needed?
function SetInputPortSamplingMode(block, port, mode)
    block.InputPort(port).SamplingMode = mode;
end


%% Set dimension for input ports
% Not sure if really needed?
function SetInputPortDimensions(block, port, dimsInfo)
    block.InputPort(port).Dimensions = dimsInfo;
end


%% Start
function Start(block)
    %% Setup
    % Load user data (includes parsed dialog parameters)
    d = get_param(block.BlockHandle, 'UserData');
    
    %% Start MLE+
    % Create the mlepProcess object
    processobj = mlepProcess;
    
    % Parse working directory path
    if isempty(d.dialog.work_dir)
        % Empty = use current working directory
        work_dir = [pwd];
        
    elseif d.dialog.rel_path
        % Parse relative path
        if strcmp(d.dialog.work_dir(1), filesep)
            work_dir = [pwd d.dialog.work_dir];
        else
            work_dir = [pwd filesep d.dialog.work_dir];
        end
    else
        % Use absolute path
        work_dir = d.dialog.work_dir;
    end
    if strcmp(work_dir(end), filesep)
        % Strip trailing file sep
        work_dir = work_dir(1:end-1);
    end
    
    % Parse model file location
    fname = [work_dir filesep d.dialog.fname];
    if ~strcmpi(d.dialog.fname(end-3:end), '.idf')
        % Strip extension
        fname = [fname '.idf'];
    end
    
    % Check paths
    assert( ...
        exist(work_dir, 'dir') > 0, ...
        'EnergyPlusCosim:invalidWorkingDirectory', ...
        'Specified working directory %s does not exist.', ...
        work_dir );
    assert( ...
        exist(fname, 'file') > 0, ...
        'EnergyPlusCosim:invalidModelFile', ...
        'Specified IDF file %s does not exist.', ...
        fname );
    
    % For EnergyPlus call, strip extensions
    fname = fname(1:end-4);
    
    % Parse arguments
    arg = [fname ' ' d.dialog.weather_profile];
    
    % Setup up MLE+
    processobj.workDir =        work_dir;
    processobj.arguments =      arg;
    processobj.acceptTimeout =  d.dialog.timeout*1000; % s -> ms
    processobj.port =           d.dialog.port;
    processobj.host =           d.dialog.host;
    if ~isempty(d.dialog.eplus_path)
        processobj.program =    d.dialog.eplus_path;
    end
    if ~isempty(d.dialog.bcvtb_dir)
        processobj.bcvtbDir =   d.dialog.bcvtb_dir;
    end

    % Start MLE+ process
    [status, msg] = processobj.start;
    processobj.status = status;
    processobj.msg = msg;

    assert( ...
        status == 0, ...
        'EnergyPlusCosim:startupError', ...
        'Cannot start EnergyPlus: %s.', msg );

    % Save processobj to UserData of the block
    d.processobj = processobj;
    set_param(block.BlockHandle, 'UserData', d);

end

%% InitializeConditions:
function InitializeConditions(block)
    % Get processobj
    d = get_param(block.BlockHandle, 'UserData');
    processobj = d.processobj;
    assert( ...
        isa(processobj, 'mlepProcess'), ...
        'EnergyPlusCosim:lostCosimulationProcess', ...
        'Internal error: Cosimulation process object is lost.' );

    %% Accept Socket 
    [status, msg] = processobj.acceptSocket;
        assert( ...
        status == 0, ...
        'EnergyPlusCosim:startupError', ...
        'Cannot start EnergyPlus: %s.', msg );

    % Save processobj back to UserData of the block
    set_param(block.BlockHandle, 'UserData', d);

end


%% Outputs
function Outputs(block)
    % Get processobj
    d = get_param(block.BlockHandle, 'UserData');
    processobj = d.processobj;
    assert( ...
        isa(processobj, 'mlepProcess'), ...
        'EnergyPlusCosim:lostCosimulationProcess', ...
        'Internal error: Cosimulation process object is lost.' );

    % Step EnergyPlus and get outputs
    if processobj.isRunning
        % MLE+ version number
        VERNUMBER = 2;

        % Write data to E+
        rvalues = block.InputPort(1).Data;
        processobj.write( ...
            mlepEncodeRealData(VERNUMBER, 0, block.CurrentTime, rvalues));
        
        % Read data from E+
        readpacket = processobj.read;
        assert( ...
            ~isempty(readpacket), ...
            'EnergyPlusCosim:readError', ...
            'Could not read data from EnergyPlus.' );

        % Decode data
        % (Currently, ivalues and bvalues are not used)
        [flag, timevalue, rvalues] = mlepDecodePacket(readpacket);
        
        % Process output
        if flag ~= 0
            processobj.stop(false);
            block.OutputPort(1).Data = flag;
            
        else
            % Case where no data is returned
            if isempty(rvalues), rvalues = 0; end

            % Set outputs of block
            block.OutputPort(1).Data = flag;
            block.OutputPort(2).Data = timevalue;
            block.OutputPort(3).Data = rvalues(:);
        end
    end

end

%% Terminate
function Terminate(block)
    % Get processobj
    d = get_param(block.BlockHandle, 'UserData');
    processobj = d.processobj;
    assert( ...
        isa(processobj, 'mlepProcess'), ...
        'EnergyPlusCosim:lostCosimulationProcess', ...
        'Internal error: Cosimulation process object is lost.' );
    
    % Stop the running process
    if processobj.isRunning
        processobj.stop(true);
    end
    
end
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
%   Nov. 2013       Modified by Stephen Frank for ease of use
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
    block.NumDialogPrms = 10;
    
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

    nDim = max(block.DialogPrm(10).Data, 1);
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
        'progname', 'modelfile', 'weatherfile', 'workdir', 'timeout', ...
        'port', 'host', 'bcvtbdir', 'time_step', 'noutputd' };
    
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
function SetInputPortSamplingMode(block, port, mode)
    block.InputPort(port).SamplingMode = mode;
end

% endfunction

%% Set dimension for input ports
function SetInputPortDimensions(block, port, dimsInfo)
    block.InputPort(port).Dimensions = dimsInfo;
end
% endfunction




%% Start
function Start(block)
    % Dialog parameters
    % progname, modelfile, weatherfile, workdir, timeout,
    % port, host, bcvtbdir, deltaT, noutputd,
    % noutputi, noutputb

    %% Start MLE+ 
    % Create the mlepProcess object and start EnergyPlus
    processobj = mlepProcess;
    processobj.program = block.DialogPrm(1).Data;
    processobj.workDir = block.DialogPrm(4).Data;
    if ~isempty(block.DialogPrm(8).Data)
        processobj.bcvtbDir = block.DialogPrm(8).Data;
    end
    %processobj.bcvtbDir = block.DialogPrm(8).Data;
    processobj.arguments = [block.DialogPrm(2).Data ' ' block.DialogPrm(3).Data];
    processobj.acceptTimeout = block.DialogPrm(5).Data;
    processobj.port = block.DialogPrm(6).Data;
    processobj.host = block.DialogPrm(7).Data;

    % Start processobj
    [status, msg] = processobj.start;
    processobj.status = status;
    processobj.msg = msg;

    if status ~= 0
        error('Cannot start EnergyPlus: %s.', msg);
    end

    % Save processobj to UserData of the block
    d = get_param(block.BlockHandle, 'UserData');
    d.processobj = processobj;
    set_param(block.BlockHandle, 'UserData', d);

end

%% InitializeConditions:
function InitializeConditions(block)
    % Get processobj
    d = get_param(block.BlockHandle, 'UserData');
    if ~isa(d.processobj, 'mlepProcess')
        error('Internal error: Cosimulation process object is lost.');
    end

    %% Accept Socket 
    [status, msg] = d.processobj.acceptSocket;
    if status ~= 0
        error('Cannot start EnergyPlus: %s.', msg);
    end
    
    % Save processobj to UserData of the block
    set_param(block.BlockHandle, 'UserData', d);

end


%% Outputs
function Outputs(block)
    % Get processobj
    d = get_param(block.BlockHandle, 'UserData');
    if ~isa(d.processobj, 'mlepProcess')
        error('Internal error: Cosimulation process object is lost.');
    end


    if d.processobj.isRunning

        VERNUMBER = 2;

        % Send signals to E+
        rvalues = block.InputPort(1).Data;
    %     ivalues = block.InputPort(2).Data;
    %     bvalues = block.InputPort(3).Data;

        d.processobj.write(mlepEncodeRealData(VERNUMBER, 0, block.CurrentTime, rvalues));
        % Read from E+
        readpacket = d.processobj.read;

        if isempty(readpacket)
            error('Cannot read from EnergyPlus.');
        end

        % Currently, ivalues and bvalues are not used
        [flag, timevalue, rvalues] = mlepDecodePacket(readpacket);
        if flag ~= 0
            d.processobj.stop(false);
            block.OutputPort(1).Data = flag;
        else
            if isempty(rvalues), rvalues = 0; end
    %         if isempty(ivalues), ivalues = 0; end
    %         if isempty(bvalues), bvalues = 0; end

            % Set outputs of block
            block.OutputPort(1).Data = flag;
            block.OutputPort(2).Data = timevalue;
            block.OutputPort(3).Data = rvalues(:);
    %         block.OutputPort(4).Data = ivalues(:);
    %         block.OutputPort(5).Data = bvalues(:);
        end
    end

end

%% Terminate
function Terminate(block)

    % Get processobj
    d = get_param(block.BlockHandle, 'UserData');
    if ~isa(d.processobj, 'mlepProcess')
        error('Internal error: Cosimulation process object is lost.');
    end

    if d.processobj.isRunning
        d.processobj.stop(true);
    end

end
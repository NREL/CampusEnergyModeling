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
% Function: setup ===================================================
% Abstract:
%   Set up the S-function block's basic characteristics such as:
%   - Input ports
%   - Output ports
%   - Dialog parameters
%   - Options
%
%   Required         : Yes
%   C-Mex counterpart: mdlInitializeSizes
%
function setup(block)

    % Register number of ports
    block.NumInputPorts  = 1;  % real, int, and boolean signals
    block.NumOutputPorts = 3;  % flag, time, real, int, and boolean outputs

    % Register parameters
    % The dialog parameters
    % progname, modelfile, weatherfile, workdir, timeout,
    % port, host, bcvtbdir, deltaT, noutputd
    block.NumDialogPrms  = 10;

    % Setup port properties to be inherited or dynamic
    block.SetPreCompInpPortInfoToDynamic;
    block.SetPreCompOutPortInfoToDynamic;

    % Override input port properties
    block.InputPort(1).Dimensions  = -1;  % inherited size
    block.InputPort(1).DatatypeID  = 0;  % double
    block.InputPort(1).Complexity  = 'Real';
    block.InputPort(1).DirectFeedthrough = true; % false

    % block.InputPort(2).Dimensions  = -1;  % inherited size
    % block.InputPort(2).DatatypeID  = -1;  % inherited type
    % block.InputPort(2).Complexity  = 'Real';
    % block.InputPort(2).DirectFeedthrough = false;
    % 
    % block.InputPort(3).Dimensions        = -1;  % inherited size
    % block.InputPort(3).DatatypeID  = -1;  % inherited type
    % block.InputPort(3).Complexity  = 'Real';
    % block.InputPort(3).DirectFeedthrough = false;

    % Override output port properties
    block.OutputPort(1).Dimensions  = 1;  % flag
    block.OutputPort(1).DatatypeID  = 0; % double
    block.OutputPort(1).Complexity  = 'Real';
    block.OutputPort(1).SamplingMode = 'sample';

    block.OutputPort(2).Dimensions  = 1;  % time
    block.OutputPort(2).DatatypeID  = 0; % double
    block.OutputPort(2).Complexity  = 'Real';
    block.OutputPort(2).SamplingMode = 'sample';

    nDim = block.DialogPrm(10).Data;  % real outputs
    if nDim < 1, nDim = 1; end
    block.OutputPort(3).Dimensions  = nDim;
    block.OutputPort(3).DatatypeID  = 0; % double
    block.OutputPort(3).Complexity  = 'Real';
    block.OutputPort(3).SamplingMode = 'sample';

    % nDim = block.DialogPrm(11).Data;  % real outputs
    % if nDim < 1, nDim = 1; end
    % block.OutputPort(4).Dimensions  = nDim;  % int outputs
    % block.OutputPort(4).DatatypeID  = 0; % double
    % block.OutputPort(4).Complexity  = 'Real';
    % block.OutputPort(4).SamplingMode = 'sample';
    % 
    % nDim = block.DialogPrm(12).Data;  % real outputs
    % if nDim < 1, nDim = 1; end
    % block.OutputPort(5).Dimensions  = nDim;  % bool outputs
    % block.OutputPort(5).DatatypeID  = 0; % double
    % block.OutputPort(5).Complexity  = 'Real';
    % block.OutputPort(5).SamplingMode = 'sample';

    % Register sample times
    %  [0 offset]            : Continuous sample time
    %  [positive_num offset] : Discrete sample time
    %
    %  [-1, 0]               : Inherited sample time
    %  [-2, 0]               : Variable sample time
    block.SampleTimes = [block.DialogPrm(9).Data 0];

    % Specify the block simStateCompliance. The allowed values are:
    %    'UnknownSimState', < The default setting; warn and assume DefaultSimState
    %    'DefaultSimState', < Same sim state as a built-in block
    %    'HasNoSimState',   < No sim state
    %    'CustomSimState',  < Has GetSimState and SetSimState methods
    %    'DisallowSimState' < Error out when saving or restoring the model sim state
    block.SimStateCompliance = 'DefaultSimState';

    % -----------------------------------------------------------------
    % The M-file S-function uses an internal registry for all
    % block methods. You should register all relevant methods
    % (optional and required) as illustrated below. You may choose
    % any suitable name for the methods and implement these methods
    % as local functions within the same file. See comments
    % provided for each function for more information.
    % -----------------------------------------------------------------

    % block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    % block.RegBlockMethod('Update', @Update);
    % block.RegBlockMethod('Derivatives', @Derivatives);
    block.RegBlockMethod('Terminate', @Terminate); % Required
    block.RegBlockMethod('SetInputPortDimensions', @SetInputPortDimensions);
    block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
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
    processobj.host= block.DialogPrm(7).Data;

    % Start processobj
    [status, msg] = processobj.start;
    processobj.status = status;
    processobj.msg = msg;

    if status ~= 0
        error('Cannot start EnergyPlus: %s.', msg);
    end

    % Save processobj to UserData of the block
    set_param(block.BlockHandle, 'UserData', processobj);

end

%% InitializeConditions:
function InitializeConditions(block)
    % Get processobj
    processobj = get_param(block.BlockHandle, 'UserData');
    if ~isa(processobj, 'mlepProcess')
        error('Internal error: Cosimulation process object is lost.');
    end

    %% Accept Socket 
    [status, msg] = processobj.acceptSocket;
    if status ~= 0
        error('Cannot start EnergyPlus: %s.', msg);
    end
    % % Save processobj to UserData of the block
    set_param(block.BlockHandle, 'UserData', processobj);

end


%% Outputs
function Outputs(block)

    % Get processobj
    processobj = get_param(block.BlockHandle, 'UserData');
    if ~isa(processobj, 'mlepProcess')
        error('Internal error: Cosimulation process object is lost.');
    end


    if processobj.isRunning

        VERNUMBER = 2;

        % Send signals to E+
        rvalues = block.InputPort(1).Data;
    %     ivalues = block.InputPort(2).Data;
    %     bvalues = block.InputPort(3).Data;

        processobj.write(mlepEncodeRealData(VERNUMBER, 0, block.CurrentTime, rvalues));
        % Read from E+
        readpacket = processobj.read;

        if isempty(readpacket)
            error('Cannot read from EnergyPlus.');
        end

        % Currently, ivalues and bvalues are not used
        [flag, timevalue, rvalues] = mlepDecodePacket(readpacket);
        if flag ~= 0
            processobj.stop(false);
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
    processobj = get_param(block.BlockHandle, 'UserData');
    if ~isa(processobj, 'mlepProcess')
        error('Internal error: Cosimulation process object is lost.');
    end

    if processobj.isRunning
        processobj.stop(true);
    end

end
%% PSEUDO_RT_SFUN - Implements the 'Pseudo Real-Time Clock' Simulink block
%
% This function implements the 'Pseudo Real-Time Clock' block in the NREL
% Campus Energy Modeling Simulink block library as an S-function.
%
% SYNTAX:
%   pseudo_rt_sfun(block)
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

function pseudo_rt_sfun(block)
    % Set the basic attributes of the S-function and registers the required
    % callbacks
    setup(block);
end

%% Setup
% Set up the S-function block's basic characteristics
function setup(block)
    %% Parameters
    % Register the number of parameters
    block.NumDialogPrms = 3;
    
    % Manually trigger CheckParameters() to check the dialog parameters
    CheckParameters(block)
    
    % Parse the dialog parameters
    ParseParameters(block)
    
    %% Ports
    % Input ports: None
    % Output ports: None
    
    % Register the number of input ports
    block.NumInputPorts  = 0;
    block.NumOutputPorts = 0;
    
    %% Options
    % Register the sample times: Inherit
    block.SampleTimes = [-1, 0];
    
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
end

%% Check Parameters
% Checks the dialog parameters
function CheckParameters(block)
    % List of the parameters passed to the S-function:
    %
    % Name              Mask Position       S-Function Argument Position
    % enab              1                   1
    % speedup           2                   2
    % rtv_action        3                   3

    % 1. 'enab' - Pseudo real-time enable [no check required]
    
    % 2. 'speedup' - Speedupt factor
    speedup = block.DialogPrm(2).Data;
    assert( isnumeric(speedup), ...
        'CampusEnergyModeling:PseudoRealTimeClock:invalidMaskParameter', ...
        'Speedup factor must be a number.' );
    assert( 0 < speedup && speedup < Inf, ...
        'CampusEnergyModeling:PseudoRealTimeClock:invalidMaskParameter', ...
        ['Speedup factor must be strictly positive and cannot be ' ...
         'infinite.'] );
    
    % 3. 'rtv_action' - Action on real-time violation [no check required]
end

%% Parse Parameters
% Parse the dialog parameters and store them in the block user data
% (See CheckParameters above for the list of parameters)
function ParseParameters(block)
    % Get existing user data, if any
    d = get_param(block.BlockHandle, 'UserData');
    if isempty(d)
        d = struct();
    end
    
    % Define names of dialog parameters (in order)
    dialogNames = { 'enab', 'speedup', 'rtv_action' };
    
    % Put dialog parameters into data structure
    d.dialog = struct();
    for i = 1:length(dialogNames)
        d.dialog.(dialogNames{i}) = block.DialogPrm(i).Data;
    end
    
    % Parse action on real-time violation
    switch d.dialog.rtv_action
        case 1
            d.dialog.rtv_action = 'silent';
        case 2
            d.dialog.rtv_action = 'warning';
        case 3
            d.dialog.rtv_action = 'error';
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
    
    % Get simulation start time as a serial date number
    d.tstart = now();
    
    % Store in block user data
    set_param(block.BlockHandle, 'UserData', d);
end

%% Compute Outputs
% Normally, computes the S-function outputs. In this case, executes the
% pseudo real-time delay.
function Outputs(block)
    % Retrieve user data
    d = get_param(block.BlockHandle, 'UserData');
    
    % If block is disabled, return
    if ~ d.dialog.enab, return; end
    
    % Get the current simulation time
    t = block.CurrentTime;
    
    % Skip delay if t = 0
    if t == 0, return; end
    
    % Calculate serial date number for next simulation step to achieve
    % pseudo real-time execution
    ttarget = d.tstart + (t / d.dialog.speedup) / 86400;
    
    % Calculate required delay (s) to achieve pseudo real-time execution
    delay = (ttarget - now()) * 86400;
    
    % Check for real-time violation (i.e. target time has already passed)
    if delay < 0
        % Violation; execute appropriate action
        switch d.dialog.rtv_action
            case 'warning'
                % Warn on real-time violation
                warning( ...
                    ['CampusEnergyModeling:PseudoRealTimeClock:' ...
                     'RealTimeViolation'], ...
                    ['Pseudo real-time violation at simulation time ' ...
                     't = %f.'], t);
            case 'error'
                % Stop on real-time violation
                error( ...
                    ['CampusEnergyModeling:PseudoRealTimeClock:' ...
                     'RealTimeViolation'], ...
                    ['Pseudo real-time violation at simulation time ' ...
                     't = %f.'], t);
        end
        
        % Return without a delay
        return
    else
        % No violation; execute the delay
        pause(delay);
    end
    
end

%% Simulation End
% Executes clean up when the simulation ends
function Terminate(~)
    % Nothing happens here
end

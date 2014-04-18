%% ELECTRICVEHICLE_CB - Implements callbacks for 'Electric Vehicle' block
%
% This function implements the mask callbacks for the 'Electric Vehicle'
% block in the NREL Campus Energy Modeling Simulink block library. It is
% designed to be called from the block mask.
%
% SYNTAX:
%   varargout = ElectricVehicle_cb(block, callback, varargin)
%
% INPUTS:
%   block =     Simulink block path
%   callback =  String specifying the callback to perform; see code
%   varargin =  Inputs which vary depending on the callback; see code
%
% OUTPUTS:
%   varargout = Outputs which vary depending on the callback
%
% COMMENTS:
% 1. This function is not intended for use outside of the NREL Campus
%    Energy Modeling Simulink library; therefore the error checking and
%    documentation are minimal. View the code to see what is going on.

function varargout = ElectricVehicle_cb(block, callback, varargin)
    %% Setup
    % Default output = none
    varargout = {};

    %% Callbacks
    % Select and execute desired callback
    switch callback
        % Initialization
        case 'init'
            ElectricVehicle_cb_init(block, varargin{:});

        % Mask Visibilities - Charger Type
        case 'charger_type'
            ElectricVehicle_cb_charger_type(block);

        % Mask Visibilities - Charging profile
        case 'profile'
            ElectricVehicle_cb_profile(block);
            
        otherwise
            warning([block ':unimplementedCallback'], ...
                ['Callback ''' callback ''' not implemented.']);
        
    end
end

%% Subfunctions
% Initialization
function ElectricVehicle_cb_init(block, chargerType)
    % Find and rename input port 1
    inPort = find_system(block, ...
        'FollowLinks',      'on'        , ...
        'LookUnderMasks',   'all'       , ...
        'SearchDepth',      1           , ...
        'BlockType',        'Inport'    , ...
        'Port',             '1'         );
    set_param(inPort{1}, 'Name', 'InPort');
    inPort = strjoin({block, 'InPort'}, '/');
    
    % Find and rename output port 1
    outPort = find_system(block, ...
        'FollowLinks',      'on'        , ...
        'LookUnderMasks',   'all'       , ...
        'SearchDepth',      1           , ...
        'BlockType',        'Outport'   , ...
        'Port',             '1'         );
    set_param(outPort{1}, 'Name', 'OutPort');
    outPort = strjoin({block, 'OutPort'}, '/');
    
    % From block for input value
    inValBlock = strjoin({block, 'InputVal'}, '/');
    outValBlock = strjoin({block, 'OutputVal'}, '/');

    % Reconfigure block according to the charger type
    switch chargerType
        % AC
        case 1
            % Input port = limit
            set_param(inPort, 'Name', 'Limit');
            set_param(inValBlock, 'GotoTag', 'ExtLimit');
            
            % Output port = power
            set_param(outPort, 'Name', 'Power');
            set_param(outValBlock, 'GotoTag', 'ExtPower');
            
            % AC Charge Controller: Connect output
            set_param(strjoin({block, 'AC ExtPower'}, '/'), ...
                'GotoTag', 'ExtPower');
            
            % DC Charge Controller: Disconnect output
            set_param(strjoin({block, 'DC ExtLimit'}, '/'), ...
                'GotoTag', 'Unused');
        
        % DC
        case 2
            % Input port = power
            set_param(inPort, 'Name', 'Power');
            set_param(inValBlock, 'GotoTag', 'ExtPower');
            
            % Output port = limit
            set_param(outPort, 'Name', 'Limit');
            set_param(outValBlock, 'GotoTag', 'ExtLimit');
            
            % DC Charge Controller: Connect output
            set_param(strjoin({block, 'DC ExtLimit'}, '/'), ...
                'GotoTag', 'ExtLimit');
            
            % AC Charge Controller: Disconnect output
            set_param(strjoin({block, 'AC ExtPower'}, '/'), ...
                'GotoTag', 'Unused');
    end
    
end

% Modify mask dialog - charger type
function ElectricVehicle_cb_charger_type(block)
    % Automatically hides the internal charger rating and efficiency if DC
    % charging is selected.
    
    % Get visibilities
    vis = get_param(block, 'MaskVisibilities');
    
    % Define the indices for parameters in the mask
    xCHARGERRATING = 2;
    xCHARGEREFF    = 3;
    
    % Set dialog visibility based on the charger type
    if strcmp( get_param(block, 'ctype'), 'DC' )
        vis{xCHARGERRATING} = 'off';
        vis{xCHARGEREFF} = 'off';
    else
        vis{xCHARGERRATING} = 'on';
        vis{xCHARGEREFF} = 'on';
    end
    set_param(block, 'MaskVisibilities', vis);
end

% Modify mask dialog - customized charging profile
function ElectricVehicle_cb_profile(block)
    % Enables or disables the charging profile input fields based on
    % whether the appropriate checkbox is checked
    
    % Get enables
    enab = get_param(block, 'MaskEnables');
    vis = get_param(block, 'MaskVisibilities');
    
    % Define the indices for parameters in the mask
    xPROFSOC =  5;
    xPROFRATE = 6;
    
    % Set parameters, mask enables, and visibilities based on checkbox
    if strcmp( get_param(block, 'profile'), 'off' )
        % Restore default values
        set_param(block, 'profileSOC', '[0.00 0.10 0.20 0.80 0.99 1.00]');
        set_param(block, 'profileRate', '[0.10 0.20 1.00 1.00 0.01 0.00]');
        
        % Enables
        enab{xPROFSOC} =  'off';
        enab{xPROFRATE} = 'off';
        
        % Visibility
        vis{xPROFSOC} =  'off';
        vis{xPROFRATE} = 'off';
    else
        % Enables
        enab{xPROFSOC} =  'on';
        enab{xPROFRATE} = 'on';
        
        % Visibility
        vis{xPROFSOC} =  'on';
        vis{xPROFRATE} = 'on';
    end
    
    % Store enables/visibilities to block
    set_param(block, 'MaskEnables', enab);
    set_param(block, 'MaskVisibilities', vis);
end
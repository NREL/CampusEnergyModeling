%% EVCHARGINGSUPERVISORYCONTROL_CB - Implements callbacks for 'EV Charging
% Supervisory Control' block
%
% This function implements the mask callbacks for the 'EV Charging
% Supervisory Control' block in the NREL Campus Energy Modeling Simulink
% block library. It is designed to be called from the block mask.
%
% SYNTAX:
%   varargout = EVChargingSupervisoryControl_cb(block, callback, varargin)
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

function varargout = EVChargingSupervisoryControl_cb(block, callback, varargin)
    %% Setup
    % Default output = none
    varargout = {};

    %% Callbacks
    % Select and execute desired callback
    switch callback
        % Initialization
        case 'init'
            EVChargingSupervisoryControl_cb_init(block, varargin{:});

        % Mask Visibilities - Charger Type
        case 'charger_type'
            EVChargingSupervisoryControl_cb_charger_type(block);

        % Mask Visibilities - Charging profile
        case 'limit_detect'
            EVChargingSupervisoryControl_cb_limit_detect(block);
            
        otherwise
            warning([block ':unimplementedCallback'], ...
                ['Callback ''' callback ''' not implemented.']);
        
    end
end

%% Subfunctions
% Initialization
function EVChargingSupervisoryControl_cb_init(block, chargerType, ...
    ramp, ldSettings, ldSweepInt, ldSweepRamp, ldThr)
    % Automatic sweep rate assignment
    if chargerType == 1 && ldSettings == 0
        ldSweepRamp = ramp;
    end
    
    % Input checking
    assert(ramp > 0, [block ':incorrectParameter'], ...
        'Maximum ramp rate must be strictly positive.');
    if chargerType == 1
        assert(ldSweepInt > 0, [block ':incorrectParameter'], ...
            'Limit detection sweep interval must be strictly positive.');
        assert(ldSweepRamp > 0, [block ':incorrectParameter'], ...
            'Limit detection sweep ramp rate must be strictly positive.');
        assert(ldThr >= 0, [block ':incorrectParameter'], ...
            'Limit detection threshold must be nonnegative.');
    end
    
    % Find and rename input port 4
    inPort = find_system(block, ...
        'FollowLinks',      'on'        , ...
        'LookUnderMasks',   'all'       , ...
        'SearchDepth',      1           , ...
        'BlockType',        'Inport'    , ...
        'Port',             '4'         );
    set_param(inPort{1}, 'Name', 'InPort');
    inPort = strjoin({block, 'InPort'}, '/');
    
    % From block for input value
    inValBlock = strjoin({block, 'InputVal'}, '/');
    outValBlock = strjoin({block, 'OutputVal'}, '/');

    % Reconfigure block according to the charger type
    switch chargerType
        % AC
        case 1
            % Input port = measured power
            set_param(inPort, 'Name', 'PMeas');
            set_param(inValBlock, 'GotoTag', 'Power');
            
            % Limit Detection: Enable
            set_param(strjoin({block, 'LimitDetectEnable'}, '/'), ...
                'Value', '1');
            
            % Limit Detection: Connect output
            set_param(strjoin({block, 'LimitDetect'}, '/'), ...
                'GotoTag', 'Limit');
            
            % Zero Signal: Disconnect output
            set_param(strjoin({block, 'ZeroSig'}, '/'), ...
                'GotoTag', 'Unused');
        
        % DC
        case 2
            % Input port = battery limit
            set_param(inPort, 'Name', 'BattLim');
            set_param(inValBlock, 'GotoTag', 'Limit');
            
            % Limit Detection: Disable
            set_param(strjoin({block, 'LimitDetectEnable'}, '/'), ...
                'Value', '0');
            
            % Limit Detection: Disconnect output
            set_param(strjoin({block, 'LimitDetect'}, '/'), ...
                'GotoTag', 'Unused');
            
            % Zero Signal: Connect output
            set_param(strjoin({block, 'ZeroSig'}, '/'), ...
                'GotoTag', 'Power');
    end
    
end

% Modify mask dialog - charger type
function EVChargingSupervisoryControl_cb_charger_type(block)
    % Automatically hides the limit detection settings if DC charging is
    % selected.
    
    % Get visibilities
    vis = get_param(block, 'MaskVisibilities');
    
    % Define the indices for parameters in the mask
    xLIMITDETECTSETTINGS  = 3;
    xLIMITDETECTSWEEP     = 4;
    xLIMITDETECTRAMP      = 5;
    xLIMITDETECTTHRESHOLD = 6;
    
    % Set dialog visibility based on the charger type
    if strcmp( get_param(block, 'ctype'), 'DC' )
        vis{xLIMITDETECTSETTINGS}  = 'off';
        vis{xLIMITDETECTSWEEP}     = 'off';
        vis{xLIMITDETECTRAMP}      = 'off';
        vis{xLIMITDETECTTHRESHOLD} = 'off';
    else
        % Other visibilities controlled by the limit detect checkbox...
        EVChargingSupervisoryControl_cb_limit_detect(block)
        
        % Set visibility of limit detect checkbox to 'on'
        vis = get_param(block, 'MaskVisibilities');
        vis{xLIMITDETECTSETTINGS}  = 'on';
    end
    set_param(block, 'MaskVisibilities', vis);

end

% Modify mask dialog - limit detection settings
function EVChargingSupervisoryControl_cb_limit_detect(block)
    % Enables or disables the limit detection input fields based on
    % whether the appropriate checkbox is checked
    
    % Get enables
    enab = get_param(block, 'MaskEnables');
    vis = get_param(block, 'MaskVisibilities');
    
    % Define the indices for parameters in the mask
    xLIMITDETECTSWEEP     = 4;
    xLIMITDETECTRAMP      = 5;
    xLIMITDETECTTHRESHOLD = 6;
    
    % Set parameters, mask enables, and visibilities based on checkbox
    if strcmp( get_param(block, 'ldsettings'), 'off' )
        % Restore default values
        set_param(block, 'sweepint', '300');
        set_param(block, 'sweepramp', get_param(block, 'ramp'));
        set_param(block, 'thr', '1.0');
        
        % Enables
        enab{xLIMITDETECTSWEEP}     = 'off';
        enab{xLIMITDETECTRAMP}      = 'off';
        enab{xLIMITDETECTTHRESHOLD} = 'off';
        
        % Visibility
        vis{xLIMITDETECTSWEEP}     = 'off';
        vis{xLIMITDETECTRAMP}      = 'off';
        vis{xLIMITDETECTTHRESHOLD} = 'off';
    else
        % Enables
        enab{xLIMITDETECTSWEEP}     = 'on';
        enab{xLIMITDETECTRAMP}      = 'on';
        enab{xLIMITDETECTTHRESHOLD} = 'on';
        
        % Visibility
        vis{xLIMITDETECTSWEEP}     = 'on';
        vis{xLIMITDETECTRAMP}      = 'on';
        vis{xLIMITDETECTTHRESHOLD} = 'on';
    end
    
    % Store enables/visibilities to block
    set_param(block, 'MaskEnables', enab);
    set_param(block, 'MaskVisibilities', vis);
end
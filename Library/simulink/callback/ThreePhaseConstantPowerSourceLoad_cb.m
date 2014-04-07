%% ThreePhaseConstantPowerSourceLoad_cb - Implements callbacks for 
% 'Three-Phase Constant Power Source or Load' block
%
% This function implements the mask callbacks for the 'Three-Phase Constant
% Power Source or Load' block in the NREL Campus Energy Modeling Simulink
% block library. It is designed to be called from the block mask.
% 
% SYNTAX:
%   varargout = ThreePhaseConstantPowerSourceLoad_cb(block, callback, varargin)
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

function varargout = ThreePhaseConstantPowerSourceLoad_cb(block, ...
    callback, varargin)

    %% Setup
    % Default output = none
    varargout = {};

    %% Callbacks
    % Select and execute desired callback
    switch callback
        % Initialization
        case 'init'
            varargout = ...
                ThreePhaseConstantPowerSourceLoad_cb_init(block, ...
                    varargin{:});
            
        otherwise
            warning([block ':unimplementedCallback'], ...
                ['Callback ''' callback ''' not implemented.']);
        
    end
end

%% Subfunctions
% Initialization
function out = ThreePhaseConstantPowerSourceLoad_cb_init(block, Conven, ...
    ~, ~, VNom, fNom, VLow)
    % Check voltages
    assert(VNom > 0, [block ':incorrectParameter'], ...
        ['Nominal line-to-line voltage for a ' ...
         'three-phase constant power source/load block ' ...
         'must be strictly positive.']);
    assert(VLow > 0, [block ':incorrectParameter'], ...
        ['Lower cutoff voltage for a ' ...
         'three-phase constant power source/load block ' ...
         'must be strictly positive.']);
     
    % Check frequency
    assert(fNom > 0, [block ':incorrectParameter'], ...
        ['Nominal frequency for a ' ...
         'three-phase constant power source/load block ' ...
         'must be strictly positive.']);
    
    % Note: block internals are with a load convention.
    % The following supplies a negative multiplier to the load
    % if the source convention is selected.
    if Conven == 1
        % Source convention
        InputGain = -1;
    else
        % Load convention
        InputGain = 1;
    end
    
    % Return computed variables in cell array (compatible w/ varargout)
    out = {InputGain};
end

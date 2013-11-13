%% GENERICINVERTER_CB - Implements callbacks for 'Generic Inverter' block
%
% This function implements the mask callbacks for the 'Generic Inverter'
% block in the NREL Campus Energy Modeling Simulink block library. It is
% designed to be called from the block mask.
%
% SYNTAX:
%   varargout = GenericInverter_cb(block, callback, varargin)
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

function varargout = GenericInverter_cb(block, callback, varargin)

    %% Setup
    % Default output = none
    varargout = {};

    %% Callbacks
    % Select and execute desired callback
    switch callback
        % Initialization
        case 'init'
            varargout = GenericInverter_cb_init(block, varargin{:});
        
        % Dynamic mask dialog
        case {'model_type', 'lookup_pair'}
            GenericInverter_cb_dynamicmask(block);
            
        otherwise
            warning([block ':unimplementedCallback'], ...
                ['Callback ''' callback ''' not implemented.']);
        
    end
end

%% Subfunctions
% Initialization
function out = GenericInverter_cb_init(block, model_type, fixed_eff, ...
	alpha, beta, gamma, lookup_pair, lookup_in, lookup_out, lookup_eff)
    % Initialize outputs
    a = 0;
    b = 0;
    c = 0;
    look_Pin = 0:1;
    look_Pout = look_Pin;
    
    % Modify output variables based on type of model
    switch model_type
        case 1
            % Fixed efficiency
            b = 1 - fixed_eff;

        case 2
            % Quadratic
            a = alpha;
            b = beta;
            c = gamma;

        case 3
            % Lookup table
            switch lookup_pair
                case 1
                    % Input power + output power
                    assert( length(lookup_in) == length(lookup_out), ...
                        [block ':incorrectParameter'], ...
                        'Lookup table vector lengths must match.');
                    look_Pin = lookup_in;
                    look_Pout = lookup_out;

                case 2
                    % Input power + efficiency
                    assert( length(lookup_in) == length(lookup_eff), ...
                        [block ':incorrectParameter'], ...
                        'Lookup table vector lengths must match.');
                    look_Pin = lookup_in;
                    look_Pout = lookup_in .* lookup_eff;

                case 3
                    % Output power + efficiency
                    assert( length(lookup_out) == length(lookup_eff), ...
                        [block ':incorrectParameter'], ...
                        'Lookup table vector lengths must match.');
                    look_Pin = lookup_out ./ lookup_eff;
                    look_Pout = lookup_out;
            end
    end
    
    % Return computed variables in cell array (compatible w/ varargout)
    out = {a, b, c, look_Pin, look_Pout};
end

% Dynamic mask dialog
function GenericInverter_cb_dynamicmask(block)
    % Get block info
    vis = get_param(block, 'MaskVisibilities');
    model_type = get_param(block, 'model_type');
    
    % Set visibilities
    % See mask parameter dialog for number-to-name matching
    switch model_type
        case 'Fixed Efficiency'
            vis(2) = {'on'};
            vis(3:5) = {'off'};
            vis(6:9) = {'off'};

        case 'Quadratic'
            vis(2) = {'off'};
            vis(3:5) = {'on'};
            vis(6:9) = {'off'};

        case 'Lookup Table'
            vis(2) = {'off'};
            vis(3:5) = {'off'};
            vis(6) = {'on'};
            lookup_pair = get_param(gcb, 'lookup_pair');
            switch lookup_pair
                case 'Input Power + Output Power'
                    vis{7} = 'on';
                    vis{8} = 'on';
                    vis{9} = 'off';

                case 'Input Power + Efficiency'
                    vis{7} = 'on';
                    vis{8} = 'off';
                    vis{9} = 'on';

                case 'Output Power + Efficiency'
                    vis{7} = 'off';
                    vis{8} = 'on';
                    vis{9} = 'on';
            end
    end

    % Write visibilities to mask; match mask enables to visibilities
    set_param(block, 'MaskVisibilities', vis);
    set_param(block, 'MaskEnables', vis);
end




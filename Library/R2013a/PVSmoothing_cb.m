%% PVSMOOTHING_CB - Implements callbacks for 'PV Smoothing' block
%
% This function implements the mask callbacks for the 'PV Smoothing' block
% in the NREL Campus Energy Modeling Simulink block library. It is designed
% to be called from the block mask.
%
% SYNTAX:
%   varargout = PVSmoothing_cb(block, callback, varargin)
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

function varargout = PVSmoothing_cb(block, callback, varargin)
    %% Setup
    % Default output = none
    varargout = {};

    %% Callbacks
    % Select and execute desired callback
    switch callback
        % Initialization
        case 'init'
            varargout = PVSmoothing_cb_init(block, varargin{:});
        
        % Dynamic mask dialog
        case 'dynamic_mask'
            PVSmoothing_cb_dynamicmask(block);
            
        otherwise
            warning([block ':unimplementedCallback'], ...
                ['Callback ''' callback ''' not implemented.']);
        
    end
end

%% Subfunctions
% Initialization
function out = PVSmoothing_cb_init(block, sel, ...
    tc, area, size, density, coverage)
    % Switch based on what is specified
    switch sel
        % Specify time constant
        case 1
            % Check and copy to output
            %assert(tc > 0, [block ':incorrectParameter'], ...
            %    'Specified time constant must be strictly positive.');
            tau = tc;
        
        % Specify array size
        case 2
            % Check input
            assert(area > 0, [block ':incorrectParameter'], ...
                'Array area must be strictly positive.');
            
            % Convert to hectares (Ha)
            area = area / 10000;
            
            % Calculate time constant based on empirical formulate from
            % Marcos et al. (2011)
            tau = sqrt(area) / (2*pi*0.020);
            
        % Specify array area and power density
        case 3
            % Check inputs
            assert(size > 0, [block ':incorrectParameter'], ...
                'Array size must be strictly positive.');
            assert(density > 0, [block ':incorrectParameter'], ...
                'Panel power density must be strictly positive.');
            assert(coverage > 0, [block ':incorrectParameter'], ...
                ['Panel coverage ratio must be greater than zero and ' ...
                'less than or equal to one.']);
            
            % Estimate array area (Ha)
            area = size / density / coverage / 10000;
            
            % Calculate time constant based on empirical formulate from
            % Marcos et al. (2011)
            tau = sqrt(area) / (2*pi*0.020);
    end
    
    % Return computed variables in cell array (compatible w/ varargout)
    out = {tau};
end

% Dynamic mask dialog
function PVSmoothing_cb_dynamicmask(block)
    % Get block info
    vis = get_param(block, 'MaskVisibilities');
    sel = get_param(block, 'sel');
    
    % Set visibilities
    % See mask parameter dialog for number-to-name matching
    switch sel
        case 'Time Constant'
            vis(2) = {'on'};
            vis(3) = {'off'};
            vis(4:6) = {'off'};
        
        case 'Array Area'
            vis(2) = {'off'};
            vis(3) = {'on'};
            vis(4:6) = {'off'};
        
        case 'Array Size and Power Density'
            vis(2) = {'off'};
            vis(3) = {'off'};
            vis(4:6) = {'on'}; 
    end

    % Write visibilities to mask; match mask enables to visibilities
    set_param(block, 'MaskVisibilities', vis);
    set_param(block, 'MaskEnables', vis);
end

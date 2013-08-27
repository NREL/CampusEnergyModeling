%% WEATHER_CB - Implements callbacks for 'Weather' block
%
% This function implements the mask callbacks for the 'Weather' block in
% the NREL Campus Energy Modeling Simulink block library. It is designed to
% be called from the block mask.
%
% SYNTAX:
%   varargout = Weather_cb(block, callback, varargin)
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

function varargout = Weather_cb(block, callback, varargin)
    %% Setup
    % Default output = none
    varargout = {};

    %% Callbacks
    % Select and execute desired callback
    switch callback
        % Initialization
        case 'init'
            Weather_cb_init(block, varargin{:});
            
        otherwise
            warning([block ':unimplementedCallback'], ...
                ['Callback ''' callback ''' not implemented.']);
        
    end
end

%% Subfunctions
% Initialization
function Weather_cb_init(block, fname, initbus)
    % Set the input file
    set_param([block '/From File'], 'Filename', fname);

    % Create the weather bus automatically
    if initbus
        % Open the weather data file
        try
            load(fname);
            tmy3 = ans;
        catch err
            warning('CampusModeling:Weather:invalidFile', ...
                ['Cannot open specified weather data file. ' ...
                 'Simulink bus definition cannot be created ' ...
                 'automatically.']);
            return
        end

        % Create the bus
        BusDef_Weather = Simulink.Bus;
        BusDef_Weather.Description = 'TMY3 Weather Data';

        % Populate the bus
        fn = fieldnames(tmy3);
        for i = 1:length(fn)
            % Create bus element w/ proper names, etc
            x = Simulink.BusElement;
            x.Name = fn{i};
            if isfield( tmy3.(fn{i}).DataInfo, 'Units')
                x.DocUnits = tmy3.(fn{i}).DataInfo.Units;
            end
            if isfield( tmy3.(fn{i}).DataInfo, 'UserData')
                x.Description = tmy3.(fn{i}).DataInfo.UserData;
            end

            % Store in bus
            BusDef_Weather.Elements(i) = x;
        end

        % Place in base workspace
        assignin('base', 'BusDef_Weather', BusDef_Weather);

        % Clear local copy
        clear('BusDef_Weather');
    end

    % Check for the precense of a bus definition
    ok = evalin( 'base', 'exist(''BusDef_Weather'',''var'')' );
    assert( ok == 1, ...
        'CampusModeling:Weather:missingBusDefinition', ...
        ['No bus definition for weather data exists in ' ...
         'the base workspace; please create one.'] );
end

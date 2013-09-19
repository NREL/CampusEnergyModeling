%% ssc_pvwattsfunc.m - Test the PVWatts module of SSC
%
% This script provides a MATLAB test of running the pvwattsfunc module
% from SSC. The pvwattsfunc module runs a single time step PVWatts
% calculation using the data provided and returns the PV array power.
%
% FUNCTIONS:
%   ssc2matlab: importSSC, runSSC
%
% COMMENTS:
% 1. The SSC input file was created manually for this particular example
%    rather than derived from SAM output. Not all pvwattsfunc inputs are
%    included; omitted inputs have default values set by pvwattsfunc.

%% Setup
% Import SSC data from text file using importSSC()
SSCvar = importSSC('ssc_pvwattsfunc_data.txt');

% Set array initial conditions:
    len = length(SSCvar);

    % Module temperature
    SSCvar(len + 1) = struct( ...
        'Name', 'tcell', ...
        'Type', 'number', ...
        'Value', 25, ...
        'Description', 'Module temperature', ...
        'Units', 'C' );
    
    % Irradiance
    SSCvar(len + 2) = struct( ...
        'Name', 'poa', ...
        'Type', 'number', ...
        'Value', 1000, ...
        'Description', 'Plane of array irradiance', ...
        'Units', 'W/m2' );

% Set up requested outputs
output = struct( ...
    'Name', {'tcell', 'poa', 'dc', 'ac'}, ...
    'Type', {'number', 'number', 'number', 'number'}, ...
    'Units', {'C', 'W/m2', 'Wdc', 'Wac'} );

%% Run
% Run PVWatts via pvwattsfunc module
out = runSSC('pvwattsfunc', SSCvar, output);

% Display results
for i = 1:length(out)
    s = sprintf('%s:\t%f\t(%s)', out(i).Name, out(i).Value, out(i).Units);
    disp(s);
end


%% Clean Up
% Unload SSC library
SSC.ssccall('unload');
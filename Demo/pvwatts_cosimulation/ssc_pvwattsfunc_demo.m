%% MATLAB Demo for pvwattsfunc Module in SSC
% This script provides a MATLAB example of running the pvwattsfunc module
% from SSC. The pvwattsfunc module runs a single time step PVWatts
% calculation using the data provided and returns the PV array power.
%
% TO DO: Discuss the Simulink block; discuss similarities/differences to
% this example; mention this example stands alone.

%% Setup
% Import SSC data from text file using importSSC()
SSCvar = importSSC('ssc_pvwattsfunc_demo_data.txt');

% NOTE: This text file was created manually for this particular example
% rather than derived from SAM output. Not all pvwattsfunc inputs are
% included; omitted inputs have default values set by pvwattsfunc.

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
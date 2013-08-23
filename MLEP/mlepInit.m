%% mlepInit.m - Setup script for MLE+
%
% This script loads stored MLE+ settings from the settings file created
% during installation. It works only with the customized MLE+ version that
% comes with the Campus Energy Modeling library. However, the difference is
% transparent to other MLE+ functions that call mlepInit(), such as
% mlepProcess().
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)
%
% Last update: 2013-08-23 by Stephen Frank (stephen.frank@nrel.gov)

if ~exist('MLEPSETTINGS', 'var') || ~isstruct(MLEPSETTINGS)
    try
        load('mlepSettings.mat', 'MLEPSETTINGS')
    catch exception
        msg = ['Failed to load MLE+ settings file. Please ensure that ' ...
        	'MLE+ is installed correctly. Error message was: ' ...
            exception.message];
        error('MLE+:mlepInit:noSettingsFile', msg)   
    end
end
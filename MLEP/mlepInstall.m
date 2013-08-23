%% mlepInstall.m - Install MLE+ for Campus Energy Modeling project
%
% This script installs a customized version of MLE+ for the Campus Energy
% Modeling project. It may edited and run alone or called from an external
% wrapper script. It installed MLE+ via the MATLAB command line instead of
% the GUI installer that MLE+ usually uses.
%
% COMMENTS:
% 1. If you run this script directly, run the 'clear all' command in MATLAB
%    first just to be safe.
%
% 2. In the future, this installation script may disappear when the Campus
%    Energy Modeling project migrates back to the official version of MLE+.
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)
%
% Last update: 2013-08-23 by Stephen Frank (stephen.frank@nrel.gov)

%% User Settings
% If running this installation script directly, modify the following paths
% to match your local configuration.

% Location of EnergyPlus installation
myEplusDir = 'C:\EnergyPlusV8-0-0\';

% Location of Java installation
myJavaDir = 'C:\Program Files (x86)\Java\jre6\bin';

% Location of MLE+ installation
%   Leave blank or comment out to automatically set the MLE+ directory to
%   the folder that contains this script. Otherwise, specify the location
%   where you unzipped the MLE+ files.
myMlepDir = '';

%% Parse Paths
% First check for directories declared outside this script (present as
% variables in MATLAB workspace); if not found use the paths specified in
% this script.

% EnergyPlus directory
if exist('EplusDir', 'var')
    % Parse to remove any trailing file seperator
    if strcmp(EplusDir(length(EplusDir)), filesep)
        EplusDir = EplusDir(1:(length(EplusDir)-1));
    end
else
    % Use user-specified directory
    EplusDir = myEplusDir;
end

% Java directory
if exist('JavaDir', 'var')
    % Parse to remove any trailing file seperator
    if strcmp(JavaDir(length(JavaDir)), filesep)
        JavaDir = JavaDir(1:(length(JavaDir)-1));
    end
else
    % Use user-specified directory
    JavaDir = myJavaDir;
end

% MLE+ directory
if exist('MlepDir', 'var')
    % Parse to remove any trailing file seperator
    if strcmp(MlepDir(length(MlepDir)), filesep)
        MlepDir = MlepDir(1:(length(MlepDir)-1));
    end
elseif exist('myMlepDir', 'var') && ~isempty(myMlepDir)
    % Use user-specified directory
    MlepDir = myMlepDir;
else
    % Determine directory from file path
    lpath = strsplit( mfilename('fullpath'), filesep );
    MlepDir = strjoin( lpath(1:(length(lpath)-1)), filesep);
end

%% Store Path
% Set BCVTB directory
bcvtbDir = [MlepDir filesep 'bcvtb'];

% Store MLE+ paths
addpath(MlepDir,bcvtbDir)
savepath;

%% Save MLE+ Settings
% Create a global variable for MLE+ settings
global MLEPSETTINGS

% Set global MLEPSETTINGS
if ispc
    % Windows
    MLEPSETTINGS = struct(...
        'version', 2,...   % Version of the protocol
        'program', [EplusDir filesep 'RunEplus'],...    % Path to the program to run EnergyPlus
        'bcvtbDir', bcvtbDir,...                        % Path to BCVTB installation
        'execcmd', 'system'...                          % Use the system command to execute E+
        );
    MLEPSETTINGS.env = {...
        {'ENERGYPLUS_DIR', EplusDir},...                % Path to the EnergyPlus folder
        {'PATH', [JavaDir ';' EplusDir]}...             % System path, should include E+ and JRE
        };
else
    % Mac and Linux
    MLEPSETTINGS = struct(...
        'version', 2,...                                % Version of the protocol
        'program', 'runenergyplus',...                  % Path to the program to run EnergyPlus
        'bcvtbDir', bcvtbDir,...                        % Path to BCVTB installation bcvtbDir
        'execcmd', 'java'...                            % Use Java to execute E+
        );
    
    MLEPSETTINGS.env = {};
    MLEPSETTINGS.path = {    ...
        {'ENERGYPLUS_DIR', EplusDir},...                % Path to the EnergyPlus
        {'PATH', ['usr/bin/java' ';' EplusDir]}...      % System path, should include E+ and JRE
        };
end

% Switch to MLE+ directory
oldFolder = cd(MlepDir);

% Save configuration
save('mlepSettings.mat','MLEPSETTINGS');

% Switch back
cd(oldFolder);

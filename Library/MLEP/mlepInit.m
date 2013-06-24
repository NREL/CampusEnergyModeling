% This script sets up the environment for MLE+.
% It should be modified to the actual settings of the computer,
% including path to BCVTB, EnergyPlus, etc.
% Run this script once before using any MLE+ functions.
% Generally, this is only necessary on Windows machines.  On
% Linux/MacOS, the default settings often work.
%
% (C) 2013 by Willy Bernal (willyg@seas.upenn.edu)

% Last update: 2013-06-24 by Willy Bernal

global MLEPSETTINGS

EplusDir = 'C:\EnergyPlusV8-0-0-mlep';
JavaDir = 'C:\Program Files (x86)\Java\jre6\bin';

% Get MLE+ Path Name
homePath = mfilename('fullpath');
indexHome = strfind(homePath, 'mlepInit');
homePath = homePath(1:indexHome-1);
bcvtbDir = [homePath 'bcvtb'];

currDir = pwd;
cd([homePath '..']);

% Add and Save MLE+ Path
libPath = pwd;
addpath(libPath);
addpath(homePath);
addpath(bcvtbDir);
savepath;

cd(currDir);

if ispc
    % Windows
    MLEPSETTINGS = struct(...
        'version', 2,...   % Version of the protocol
        'program', [EplusDir filesep 'RunEplus'],...   % Path to the program to run EnergyPlus
        'bcvtbDir', bcvtbDir,...   % Path to BCVTB installation
        'execcmd', 'system'...   % Use the system command to execute E+
        );
    MLEPSETTINGS.env = {...
        {'ENERGYPLUS_DIR', EplusDir},...  % Path to the EnergyPlus folder
        {'PATH', [JavaDir ';' EplusDir]}...  % System path, should include E+ and JRE
        };
else
    % Mac and Linux
    MLEPSETTINGS = struct(...
        'version', 2,...   % Version of the protocol
        'program', 'runenergyplus',...   % Path to the program to run EnergyPlus
        'bcvtbDir', bcvtbDir,...   % Path to BCVTB installation bcvtbDir
        'execcmd', 'java'...   % Use Java to execute E+
        );
    
    MLEPSETTINGS.env = {};
    MLEPSETTINGS.path = {    ...
        {'ENERGYPLUS_DIR', EplusDir},...  % Path to the EnergyPlus
        {'PATH', ['usr/bin/java' ';' EplusDir]}...  % System path, should include E+ and JRE
        };
end
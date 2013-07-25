%% Campus Modeling Installation Script
% This script installs the Campus Modeling MATLAB functions and Simulink
% libraries to the MATLAB path. To perform the installation:
%   1. Download the Campus Modeling repository to the desired location on
%      your network or local hard drive.
%   2. Set the MATLAB working directory to the directory of this script.
%   2. Execute this script.
%
% NOTES
% 1. On Windows, administrative access may be required in order to save
%    the MATLAB path. Either run MATLAB as an administrator or enter the 
%    appropriate credentials at the Windows User Access Control (UAC)
%    prompt.
% 2. This installation script does not install all dependecies required to
%    use the Campus Modeling libraries and models; it only installs the
%    functions and library blocks developed by the Campus Modeling team.
%    To run the models, you will need a variety of other software packages;
%    see the Campus Modeling manual for details.

%% Initialization
% NOTE: the 'filesep' command gives the correct file seperator for the
% current MATLAB platform.

% Get path of current directory
localPath = strsplit( mfilename('fullpath'), filesep );
localPath = strjoin( localPath(1:(length(localPath)-1)), filesep);

% Get MATLAB version; set Simulink library path accordingly
v = ver('MATLAB');
vNum = str2double( v.Version );
rel = strrep( strrep(v.Release, '(', ''), ')', '');
if strcmpi(rel,'R2013a') || vNum >= 8.1
    % MATLAB 2013a or newer
    libPath = 'R2013a';
    disp( ['Found MATLAB release ' rel ' (version ' v.Version ').']);
    disp( 'Installing Simulink library version R2013a.' );
    disp( 'This library version is intended for offline simulation.' );
    
elseif strcmpi(rel,'R2011b')
    % MATLAB 2011b or newer
    libPath = 'R2011b';
    disp( ['Found MATLAB release ' rel ' (version ' v.Version ').']);
    disp( 'Installing Simulink library version R2011b.' );
    disp( ['This library version is intended for real time ' ...
        'simulation using Optal-RT version 10.5.']);
    disp( ['NOTE: Not all blocks from the R2013a library are present ' ...
        'in this library version!']);

else
    % Other versions unsupported
    libPath = 'R2011b';
    disp( ['Found MATLAB release ' rel ' (version ' v.Version ').']);
    warning( 'CampusModeling:installation:incompatibleVersion', ...
        ['Your MATLAB release is %s, but the CampusModeling ' ...
         'library requires 2013a or newer (for offline simulation) ' ...
         'or 2011b (for hardware-in-loop simulation with Opal-RT ' ...
         'version 10.5).\nThe R2011b Simulink library will be ' ...
         'installed, but is not guaranteed to work properly!'], rel );
    disp( 'Installing Simulink library version R2011b.' );
    disp( ['This library version is intended for hardware-in-loop ' ...
        'simulation using Optal-RT version 10.5.']);
    disp( ['NOTE: Not all blocks from the R2013a library are present ' ...
        'in this library version!']);
end

%% Set Path
% Directories to add to path (relative to 'Library' root)
dirs = { ...
    strjoin({localPath,'common'},filesep), ...
    strjoin({localPath,'common','MLEP'},filesep), ...
    strjoin({localPath,'common','MLEP','bcvtb'},filesep), ...
    strjoin({localPath,'common','SimulinkToSSC'},filesep), ...
    strjoin({localPath,libPath},filesep)
    };

% NOTE: You can also use genpath() to add all subdirectories, but we
% actually don't need all the subdirectories in this case. (For instance,
% MLE+ has some subdirectories that aren't directly relevant. Also, we
% don't want to add paths to both the 2011b and 2013a Simulink libraries
% simultaneously.)

% Set path
addpath(dirs{:});

%% Save Path
% Save for all users
savepath


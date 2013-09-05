%% install.m - Campus Energy Modeling Installation Script
%
% This script installs the Campus Energy Modeling MATLAB functions and 
% Simulink library to the MATLAB path. To perform the installation:
%   1. Download the Campus Modeling repository to the desired location on
%      your network or local hard drive.
%   2. Set the MATLAB working directory to the location of this script.
%   3. Examine the variables defined under User Settings and modify as
%      required to match your local computer (see comment #3)
%   4. Execute the script.
%
% COMMENTS:
% 1. On Windows, administrative access may be required in order to save
%    the MATLAB path. Either run MATLAB as an administrator or enter the 
%    appropriate credentials at the Windows User Access Control (UAC)
%    prompt.
%
% 2. This installation script does not install all dependecies required to
%    use the Campus Energy Modeling libraries and models; it only installs
%    the functions and library blocks developed by the Campus Energy
%    Modeling team. To run the models, you will need a variety of other
%    software packages; see the Campus Energy Modeling manual for details.
%
% 3. The exception to comment #2 is that this script can, at the user's
%    option, install the MLE+ version presently included with the Campus
%    Energy Modeling project. To perform this installation, do the
%    following before running the script:
%       i.  Set 'installMLEP = true'
%       ii. Edit the MLE+ paths to match your local configuration.
%    At some point in the future, the library may revert to the main MLE+
%    code and installer, at which point this installation option will be
%    removed.

%% User Settings
% Install MLE+ via this script?
installMLEP = true;

% If installing MLE+, set the following paths correctly:
     % Location of EnergyPlus installation
     EplusDir = 'C:\EnergyPlusV8-0-1\';
 
     % Location of Java installation
     JavaDir = 'C:\Program Files (x86)\Java\jre6\bin';
     
% NOTE: The MLE+ paths are ignored if installMLEP == false

%% Initialization
% NOTE: the 'filesep' command gives the correct file seperator for the
% current MATLAB platform.

% Get path of current directory
localPath = strsplit( mfilename('fullpath'), filesep );
localPath = strjoin( localPath(1:(length(localPath)-1)), filesep);

% Check that the local path came out correctly
assert( ~isempty(localPath), ...
    'CampusEnergyModeling:install:invalidInstallationPath', ...
    ['Empty installation path detected; installation failed. ' ...
     'To avoid this error, run the entire script directly from the ' ...
     'MATLAB command line or by using the Run button in the editor.'] ...
    );

% Change to local path
oldPath = cd(localPath);

%% Install MLE+
% ...if requested
if installMLEP
    disp('Installing MLE+...');
    run(['.' filesep 'MLEP' filesep 'mlepInstall']); %#ok<*UNRCH>
    disp(' ');
end

%% Set Path
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
    warning( 'CampusEnergyModeling:installation:incompatibleVersion', ...
        ['Your MATLAB release is %s, but the Campus Energy Modeling ' ...
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

% Directories to add to path (relative to 'Library' root)
dirs = { ...
    strjoin({localPath,'Library','common'},filesep), ...
    strjoin({localPath,'Library','common','databus2matlab'},filesep), ...
	strjoin({localPath,'Library','common','graphics'},filesep), ...
    strjoin({localPath,'Library','common','sfun'},filesep), ...
    strjoin({localPath,'Library','common','ssc2matlab'},filesep), ...
    strjoin({localPath,'Library','common','utilities'},filesep), ...
    strjoin({localPath,'Library',libPath},filesep)
    };

% NOTE: You can also use genpath() to add all subdirectories, but we
% actually don't need all the subdirectories in this case. (For instance,
% we don't want to add paths to both the 2011b and 2013a Simulink libraries
% simultaneously.)

% Set path
addpath(dirs{:});

% Save for all users
savepath

%% Clean Up
% Switch back to original path
cd(oldPath);
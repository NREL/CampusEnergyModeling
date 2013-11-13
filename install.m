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
%    software packages; see the Campus Energy Modeling wiki for details.
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
     EplusDir = 'C:\EnergyPlusV8-1-0\';
 
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
    ['Empty installation path detected; installation failed! ' ...
     '(Probably, MATLAB was unable to automatically determine the ' ...
     'location of this installation script.)\n\n' ...
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

%% Check MATLAB version
% Get MATLAB version
v = ver('MATLAB');
vNum = str2double( v.Version );
rel = strrep( strrep(v.Release, '(', ''), ')', '');

% Display MATLAB version
disp( ['Found MATLAB release ' rel ' (version ' v.Version ').']);

% Warn if prior to R2013a
if vNum < 8.1
	warning( 'CampusEnergyModeling:installation:incompatibleVersion', ...
        ['Your MATLAB release is %s, but the Campus Energy Modeling ' ...
         'library requires 2013a or newer. The Campus Energy Modeling ' ...
		 'library will be installed, but is not guaranteed to work ' ...
         'properly!'], rel );
end

%% Set Path
% Installation message
disp('Installing Campus Energy Modeling Library...');

% Generate path (everything under ./Library)
dirs = genpath( strjoin({localPath,'Library'},filesep) );

% Set path
addpath(dirs);

% Remove the ./Library folder (but keep subdirectories)
rmpath(strjoin({localPath,'Library'},filesep));

% Save for all users
savepath

%% Clean Up
% Done!
disp('Finished.')

% Switch back to original path
cd(oldPath);
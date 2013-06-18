%mlepInstall Install MLE+.
%   This function closes the co-simulation sockets, created by mlepCreate,
%   if they are non-empty.  This function should be called at the end of
%   the co-simulation.
%
%   mlepClose(serversock, simsock, pid)
%
%   If pid (the process ID of E+) is provided, it will be destroyed.
%
%
% (C) 2013 by Willy Bernal(willyg@seas.upenn.edu)

% Last update: 2013-06-18
% HISTORY:
%   2013-06-18  

%% PATH TO E+/JAVA BIN
if ispc
    % Windows
    eplusPath = 'C:\EnergyPlusV8-0-0';
    javaPath = 'C:\Program Files (x86)\Java\jre6\bin'; 
else
    % Unix
    eplusPath = '/Applications/EnergyPlus-8-0-0';
end

%% Get MLE+ Path
mlepFolder = mfilename('fullpath');
% Remove filename
indexHome = strfind(mlepFolder, ['mlepInstall']);
mlepFolder = mlepFolder(1:indexHome-1);

%% Add & Save Path to MLE+
addpath(mlepFolder);
savepath;


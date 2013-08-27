function blkStruct = slblocks
% SLBLOCKS - Defines the NREL Campus Modeling Simulink block library
%
% Predefined function which returns information about a blockset to
% Simulink. In this case, it defines the blockset for the NREL Campus
% Modeling Simulink library.
% 
% The information returned is in the form of a BlocksetStruct with the
% following fields:
%
%   Name            Name of the Blockset in the Simulink block library
%                   Blocksets & Toolboxes subsystem.
%   OpenFcn         MATLAB expression (function) to call when you
%                   double-click on the block in the Blocksets & Toolboxes
%                   subsystem.
%   MaskDisplay     Optional field that specifies the Mask Display commands
%                   to use for the block in the Blocksets & Toolboxes
%                   subsystem.
%   Browser         Array of Simulink Library Browser structures, described
%                   below.
%
% The Simulink Library Browser needs to know which libraries in your
% Blockset it should show, and what names to give them. To provide this
% information, define an array of Browser data structures with one array
% element for each library to display in the Simulink Library Browser.
% Each array element has two fields:
%
%   Library         File name of the library (mdl-file) to include in the
%                   Library Browser.
%   Name            Name displayed for the library in the Library Browser
%                   window.  Note that the Name is not required to be the
%                   same as the mdl-file name.
%
% SYNTAX:
%   blkStruct = slblocks
% 
% OUTPUTS:
%   blkStruct =     Structure object containing block library information
%
% COMMENTS:
% 1. For this function, the function definition must be the first line in
%    the file. Otherwise, Simulink will not parse it properly.

    % Name of the subsystem which will show up in the Simulink Blocksets
    % and Toolboxes subsystem.
    blkStruct.Name = sprintf('Campus\nEnergy\nModeling');

    % The function that will be called when the user double-clicks on
    % this icon.
    blkStruct.OpenFcn = 'open(''CampusModeling.mdl'');';

    % The argument to be set as the Mask Display for the subsystem.
    blkStruct.MaskDisplay = 'disp(''Campus\nEnergy\nModeling'');';

    % Library information for Simulink library browser
    blkStruct.Browser = struct();
    blkStruct.Browser.Library = 'CampusModeling';
    blkStruct.Browser.Name    = 'NREL - Campus Energy Modeling';

% No end keyword for this function
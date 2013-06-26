function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.
%   SLBLOCKS returns information about a Blockset to Simulink.  The
%   information returned is in the form of a BlocksetStruct with the
%   following fields:
%
%     Name         Name of the Blockset in the Simulink block library
%                  Blocksets & Toolboxes subsystem.
%     OpenFcn      MATLAB expression (function) to call when you
%                  double-click on the block in the Blocksets & Toolboxes
%                  subsystem.
%     MaskDisplay  Optional field that specifies the Mask Display commands
%                  to use for the block in the Blocksets & Toolboxes
%                  subsystem.
%     Browser      Array of Simulink Library Browser structures, described
%                  below.
%
%   The Simulink Library Browser needs to know which libraries in your
%   Blockset it should show, and what names to give them.  To provide
%   this information, define an array of Browser data structures with one
%   array element for each library to display in the Simulink Library
%   Browser.  Each array element has two fields:
%
%     Library      File name of the library (mdl-file) to include in the
%                  Library Browser.
%     Name         Name displayed for the library in the Library Browser
%                  window.  Note that the Name is not required to be the
%                  same as the mdl-file name.

% Name of the subsystem which will show up in the Simulink Blocksets
% and Toolboxes subsystem.
blkStruct.Name = ['Campus' sprintf('\n') 'Modeling'];

% The function that will be called when the user double-clicks on
% this icon. (Unsure what to put here.)
blkStruct.OpenFcn = '';

% The argument to be set as the Mask Display for the subsystem.
blkStruct.MaskDisplay = sprintf('Campus\nModeling');

% Library information for Simulink library browser
blkStruct.Browser = struct();
blkStruct.Browser.Library = 'CampusModeling';
blkStruct.Browser.Name    = 'NREL - Campus Modeling LDRD';

% End of slblocks
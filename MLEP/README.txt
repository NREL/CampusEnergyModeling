Installation Instructions
=========================

This folder contains a specially modified version of MLE+ which can be
installed automatically by the Campus Energy Modeling installation script.
Alternatively, you can run mlepInstall.m directly.

Installing with Campus Energy Modeling library
----------------------------------------------

Follow the instructions in install.m and/or consult the Campus Energy
Modeling wiki documentation.

Installing via mlepInstall.m
----------------------------

1. Modify the myEplusDir variable to match your current E+ installation.
	E.g. myEplusDir = 'C:\EnergyPlusV8-0-0';
	  
2. Modify the myJavaDir variable to match your current Java binary folder.
	E.g. myEplusDir = 'C:\Program Files (x86)\Java\jre6\bin';

3. Run mlepInit.m in MATLAB. (Be sure to run the entire script as opposed
   to line-by-line from within the editor. Otherwise, MATLAB will not
   properly detect the installation directory for MLE+.
   
You only need to run the script once to install MLE+; the MLE+ settings
and MATLAB path will be saved automatically.

Usage Instructions
==================

See the MLE+ documentation on the Campus Energy Modeling wiki:
{TO DO: Insert link when available}




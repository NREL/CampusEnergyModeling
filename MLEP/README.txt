Installation Instructions
=========================

0. This instructions are for Windows OS. You must have Matlab and E+ ver 8.0.0. 
   on your machine. 

Changes in mlepInit.m
---------------------

1. Modify the EplusDir variable to match your current E+ installation. 
	E.g. EplusDir = 'C:\EnergyPlusV8-0-0'; 
	Note: Make sure it does not have a file separation character at the end. 
	  
2. Modify the JavaDir variable to match your current Java binary folder. 
	E.g. EplusDir = 'C:\Program Files (x86)\Java\jre6\bin';
	Note: Make sure it does not have a file separation character at the end. 

3. Run mlepInit.m from Matlab. You only need to run this file once to install MLE+.
This will save the necessary paths in your Matlab path. 

4. Done. Now go ahead and use the MLE+ block from the library. There are some demos 
in the Demo folder. 




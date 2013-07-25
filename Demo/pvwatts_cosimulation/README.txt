This demonstration executes PVWatts cosimulation within Simulink using the MATLAB-SSC interface. The simulation uses weather data at NREL for June 2012.

Features:
•	Execute PVWatts SSC module within Simulink using the MATLAB-SSC interface
•	Demonstrate cosimulation of PVWatts and Simulink
•	Demonstrate generic inverter block for computing DC-AC conversion efficiency

Requirements:
•	MATLAB/Simulink (R2013a)
•	Campus Modeling project MATLAB/Simulink libraries
•	SSC SDK

Instructions: 
1.	Open MATLAB and set the working directory to the folder that contains this README file.
2.	Ensure the MATLAB interface folder for the SSC SDK is in the MATLAB path.
3.	Run the script 'pvwatts_cosimulation_demo_init.m' to initialize the weather data.
5.  Run the Simulink model and examine the results in the scope.

Comments:
•	In addition to the Simulink model, the file 'ssc_pvwattsfunc_demo.m' provides an example of running PVWatts directly from MATLAB.
•	The help for the 'PVWatts Cosimulation' and 'Generic Inverter' Simulink blocks contain additional information.
•	Some aspects of the PVWatts module in SSC (pvwattsfunc) are not well understood, such as the proper way to specify a time zone. These will be resolved at a later time, at which point this demo may change.

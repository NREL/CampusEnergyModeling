This is a RT-LAB simulation for 5 buildings (E+), a simple power network (SimPowerSystem), and HIL that displays the total power consumption to an oscilloscope. 

Features:
•	This is setup to run on the RT-LAB machine but can also run properly in Simulink. 
•	Multiple E+ building in Simulink via MLE+: three hospitals and two secondary school buildings
•	The aggregated power of the buildings is an input to the power network system. 
•	You can control these plant knobs:
	i.		Chilled Water Temperature. 
	ii.		Chiller Plant Loop on/off control. 
•	You can control these Weather knobs:
	i.		Outside Dry Bulb Temperature.
	ii.		Direct Solar Radiation. 
	iii.	Diffuse Solar Radiation.
•	You can output to the oscilloscope the aggregated power of the buildings. 

Requirements:
•	MATLAB/Simulink (R2013a)
•	Campus Modeling project MATLAB/Simulink libraries
•	SimPowerSystems
•	EnergyPlus
•	MLE+
•	RT-LAB
•	Compatible Opal-RT real-time target

Instructions: 
1.	Review the the MLE+ instructions included in the Library Folder.
2.	Open MATLAB and set the working directory to the folder that contains this README file.
3.	Open 'runCampusSim.mdl' in Simulink.
4.	Adjust the block mask parameters for each EnergyPlus Cosimulation block, if necessary.
5.	Simulate the model in Simulink and verify that no errors occur.
6.	Create a project in RT-LAB and add these files (see the RT-LAB documentation).
	NOTE: Make sure to include the conf and bin files.
7.	Make the required hardware connections (see 'Details').
8.	Compile and run the project on the Opal-RT target.

Details:
TO DO: Put in details for the hardware connections. (Copy from other demo README?)
This is demonstration of a continuous (time-domain) SimPowerSystems model running on Opal-RT hardware using RT-LAB and MATLAB 2011b.

Features: 
•	SimPowerSystems continuous (time-domain) model running in real-time
•	Demonstration of I/O with RT-LAB for plotting/visualization
	
Requirements:
•	MATLAB/Simulink (R2011b)
•	SimPowerSystems
•	RT-LAB
•	Compatible Opal-RT real-time target

Instructions: 
1.	Open the model in Simulink
2.	Simulate the model in Simulink and verify that no errors occur
3.	Create a project in RT-LAB and add these files (see the RT-LAB documentation)
4.	Compile and run the project on the Opal-RT target

Comments:
•	The model is set up to run on the RT-LAB machine but will also run properly in Simulink.
•	Eventually, this demo might (should?) include the RT-LAB project files.


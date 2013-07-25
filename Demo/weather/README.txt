This is a demonstration of the work flow for importing TMY3 weather data into Simulink. Importing TMY3 weather data is a three step process:
1.	Convert TMY3-formatted weather data into MATLAB time series,
2.	Save the time series to file, and
3.	Read the file into Simulink at run time.

The utility function convertTMY3() and Simulink library block named 'Weather Data' facilitate this workflow; these are available in the 'Library' folder. Additional documentation may be found in the help files for convertTMY3() and the 'Weather Data' block.

Features:
•	Import two weather data types from a TMY3-compatible weather file and display the results.
•	Model file 'create_weather_data.mdl' illustrates how to export weather data from Simulink.

Requirements:
•	MATLAB/Simulink (R2013a)
•	Campus Modeling project MATLAB/Simulink libraries

Instructions: 
1.	Open MATLAB and set the working directory to the folder that contains this README file.
2.	Run the script 'weather_demo_init.m' to convert and save the TMY3 weather data to binary format.
3.	Run the model 'weather_demo.mdl' and view the results on the scope.
4.	If desired, change the 'Weather Data' block to read a different data source and re-run the model.

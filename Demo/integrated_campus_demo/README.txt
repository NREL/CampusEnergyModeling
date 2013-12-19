This demonstrations integrates multiple modeling tools to create a complete campus energy model. It
includes the following models:
•   Two office buildings (EnergyPlus)
•   A campus thermal plant (EnergyPlus)
•   A PV system (PVWatts)
•   An electrical distribution system (SimPowerSystems)
•   Electric vehicles (EVs) and charging stations

Features:
•   Integrates energy models from EnergyPlus, PVWatts, and SimPowerSystems into a single campus
    model
•   Demonstrates modulation of EV charging power to smooth PV array output
•   Demonstrates control of building and campus thermal plant setpoints based on a real time pricing
    signal

Requirements:
•   MATLAB/Simulink (R2013a)
•   Campus Energy Modeling project MATLAB/Simulink library
•   EnergyPlus
•   MLE+
•   SimPowerSystems
•   SSC SDK

Instructions: 
1.  Open MATLAB and set the working directory to the folder that contains this README file.
2.  Ensure that EnergyPlus, MLE+, SSC, and SimPowerSystems are installed and properly configured.
3.  Edit the initialization script 'integrated_campus_demo_init.m' to select a source for the
    weather data.
4.  Run the initialization script to initialize the model and weather data. (This should also
    automatically open the 'integrated_campus_demo.mdl' Simulink model.)
5.  Run the Simulink model and examine the results in the scopes.

Comments:
1.  This demo requires a custom build of EnergyPlus (8.0.1); it is not intended for release until it
    can be modified and verified to work with an official EnergyPlus release (e.g. 8.1).
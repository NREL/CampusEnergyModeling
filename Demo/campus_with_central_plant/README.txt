This demonstration models a small campus consisting of two identical office buildings and a central
chiller plant. The two buildings and the central plant are each modeled in a seperate EnergyPlus
model; the models communicate in Simulink via MLE+ to simulate the campus interactions. 

Features:
•   Demonstrates cosimulation of multiple EnergyPlus models
•   Demonstrates interaction of buildings with a central plant using load profile objects
•   Includes a run script for generating example plots: 'campus_with_central_plant_plots.m'

Requirements:
•   MATLAB/Simulink (R2013a)
•   Campus Energy Modeling project MATLAB/Simulink library
•   EnergyPlus
•   MLE+

Instructions: 
1.  Open MATLAB and set the working directory to the folder that contains this README file.
2.  Ensure that EnergyPlus and MLE+ are installed and properly configured. (See the Campus Energy
    Modeling wiki for installation guidance.)
3.  Run the initialization script to initialize the model. (This should also automatically open the
    'campus_with_central_plant.mdl' Simulink model.)
4.  Run the Simulink model and examine the results in the scopes.

Comments:
1.  The building models interact with the central plant by exchanging temperature, mass flow rate,
    and demand information for the chilled water system: the central plant model supplies the
    chilled water temperature and a maximum available flow rate to the building models, while the
    building models return actual flow rates and thermal demand to the central plant model.
2.  The COMMENTS section of 'campus_with_central_plant_init.m' contains some additional information.
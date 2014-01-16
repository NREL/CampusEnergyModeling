This demonstration integrates demand response (DR) controls in Simulink with an EnergyPlus model of
a small office building. Demand response is achieved via setback of the zone temperature. Weather
data are drawn from NREL Solar Radiation Research Laboratory data for August 3, 2012 - a
particularly warm day.

Features:
•   Executes EnergyPlus cosimulation within Simulink using MLE+
•   Demonstrates open-loop (manual) DR with user-selectable temperature setback
•   Demonstrates closed-loop (automatic) DR with user-selectable demand target

Requirements:
•   MATLAB/Simulink (R2013a)
•   Campus Energy Modeling project MATLAB/Simulink library
•   EnergyPlus
•   MLE+

Instructions: 
1.  Open MATLAB and set the working directory to the folder that contains this README file.
2.  Ensure that EnergyPlus and MLE+ are installed and properly configured. (See the Campus Energy
    Modeling wiki for installation guidance.)
3.  Run the initialization script to initialize the model and weather data. (This should also
    automatically open the 'demand_reponse.mdl' Simulink model.)
4.  If desired, adjust the demand response control settings in the Simulink model using the switches
    and highlighted boxes; see Comments.
5.  Run the Simulink model and examine the results in the scopes.

Comments:
1.  The Simulink model has switches for controling the type of demand response: off, manual, or
    automatic. Look for the red "DR Control" label within the model. Similarly, you may adjust the
    temperature setback for manual DR or the target demand limit for automatic DR in the red
    highlighted boxes labeled "DR Settings".
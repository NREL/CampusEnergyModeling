This demonstration models the use of a supervisory controller for electric vehicle (EV) charging to
smooth the output of a PV array. The simulation offers a choice of two weather data sources: one
minute data from NREL's Solar Radiation Research Laboratory (SRRL) for May 17, 2012, or high
resolution (approximately 3 second) SRRL weather data for June 1, 2013, from NREL's DataBus
database.

Features:
•   Demonstrates cosimulation of PVWatts with Simulink-based EV models
•   Demonstrates Simulink blocks for EVs, EV charging stations, and EV charging supervisory control
•   Demonstrates some basic control algorithms for PV smoothing

Requirements:
•   MATLAB/Simulink (R2013a)
•   Campus Energy Modeling project MATLAB/Simulink library
•   SimPowerSystems
•   SSC SDK

Instructions: 
1.  Open MATLAB and set the working directory to the folder that contains this README file.
2.  Ensure that the SSC SDK is installed in the MATLAB path and properly configured. (See the
    Campus Energy Modeling wiki for installation guidance.)
3.  Run the script 'ev_pv_smoothing_init.m' to initialize the weather data. (This should also
    automatically open the 'ev_pv_smoothing.mdl' Simulink model.)
4.  If desired, select a different scenario in the initialization script; see Comments.
5.  If desired, configure the model via the manual switches; see Comments.
6.  Run the Simulink model and examine the results in the scopes.

Comments:
1.  In 'ev_pv_smoothing_init.m', you can select either of two weather scenarios, each of which spans
    a single day with highly variable solar irradiance. The one minute data set runs significantly
    faster because it uses a larger time step; see the comments in the initialization script for
    further details.
2.  The help for the 'EV Charging Supervisory Control', 'AC Charging Station', and 'Electric
    Vehicle' Simulink blocks contain additional information about how the various EV models are
    implemented.
3.  The Simulink model contains two manual switches: one labeled 'Enable Regulation' and one labeled
    'Signal Select'. The 'Enable Regulation' switch enables or disables control of the EVs to
    regulate (smooth) the PV array output. The 'Signal Select' switch selects whether the controller
    attempts to smooth the PV signal or the grid signal. For best results, change the parameters of
    the PI controller as noted in the model when changing the setting of the 'Signal Select' switch.
4.  The COMMENTS section of 'ev_pv_smoothing_init.m' contains some additional information.
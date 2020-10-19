# GeneticToggleSwitch_In_Silico_Control

## "Balancing cell populations endowed with a synthetic toggle switch via adaptive pulsatile feedback control"

### A. Guarino (@AgostinoGuarino), D. Fiore, D. Salzano, M. di Bernardo

ACS Synthetic Biology 9(4), 793–803, 2020

available at https://pubs.acs.org/doi/abs/10.1021/acssynbio.9b00464

In- Silico Feedback control strategies for the Genetic Toggle Switch.

The folders contains all the files to carry out both MATLAB and BSim simulations.


**Matlab Simulations** :

Include in the path all the folders and subfolders you find in MATLAB/

The simulation can be conducted running the file Main.

General details about the simulation (simulation method, simulation time, number of cells) can be set in the file SimulationSettings as 
explained in the comments.

Deatils about the control strategies can be set in the file ControlSettings, as explained in the comments.


**Agent-Based simulations in Bsim** :

* PI-PWM Control Strategy:

Import all the files in a new Java project (files were developed with Eclipse 2019-06).

The main file to run the simulation is in the package Control_Experiment_Bacteria >> bMain >> BSim_Lugagne_Main


* MPC Control Strategy:

Import all the files in a new Java project (files were developed with Eclipse 2019-06).

Open MATLAB and add the root of the project (that contains the file bsim_mpc.m) to the path.

The main file to run the simulation is in the package Control_Experiment_Bacteria >> bMain >> BSim_Lugagne_Main

%% Control of Synthetic Toggle Switch
% A. Guarino, D. Fiore, D. Salzano, M. di Bernardo
% "Balancing cell populations endowed with a synthetic toggle switch
% via adaptive pulsatile feedback control"

clear 
close all

%% Simulation and plot settings
 settings = SimulationSettings();

%% Load Parameters of the Model
load('Parameters');
                                                                                                                                                                                                                   
%% Control Settings
[controller, Controller_obj, LacI_inputs, TetR_inputs, inputs] = ...
                                            ControlSettings(settings, P);

%% Simulation
if(strcmp(settings.sim_method, 'ODE'))
    [tvec, TargetCell, controller, inputs, othercells] =...
      Simulate_ode_events(P, settings, inputs, controller, Controller_obj);
else
    [tvec, TargetCell, controller, inputs, othercells] =...
      Simulate_ssa(P, settings, inputs, controller, LacI_inputs,...
       TetR_inputs, Controller_obj);
end

%% Plot
PlotScript; 

%% End of the simulation
disp('End of the simulation.')
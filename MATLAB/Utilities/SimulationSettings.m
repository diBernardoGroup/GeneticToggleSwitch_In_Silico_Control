function settings = SimulationSettings()
%%Simulation Settings [Choose One, comment/uncomment]
% settings.sim_method = 'ODE'; %Deterministic
settings.sim_method = 'SSA'; %Stochastic
settings.diffusion = 'YES';
settings.var_param = 0; %0 if no variation in parameters, 1 
                        %if yes -> quantity in simulation routine

%%Time Settings [minutes]
settings.tstep = 5;           %Simulation Step Time
settings.period = 240;        %Control/PWM Period
settings.nperiod = 18;        %Number of periods in the simulation
%The following duration can be evaluated in other ways
% settings.duration = settings.period*settings.nperiod; %Total duration of
%the simulation as multiple of periods
settings.duration = 72*60; %in minutes

%%Plot Settings [0 no, 1 yes]
settings.showprogress = 1;  %Show Simulation Progress
settings.plot.complete=1;   %Plot a resumee fig with all the data


%%Number of other Cells
if(strcmp(settings.sim_method, 'ODE')) %Deterministic Simulation with a Single Cell
    settings.numcells = 0;
else
    settings.numcells = 2; %Number of additional cells in the Stochastic Simulation
end

end
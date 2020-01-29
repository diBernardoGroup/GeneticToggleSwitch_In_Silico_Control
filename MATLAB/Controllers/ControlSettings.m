function [controller, Controller_obj , LacI_inputs, TetR_inputs, inputs] = ControlSettings(settings, P)
%ControlSettings Defines the parameters of the controller and the Inputs of
%the simulation. Setpoint definition here.

    %% Control Types [release, pop_avg 0 no, 1 yes]
    controller.list_of = {'SquareWave','PIPWM','MPC'}; %Controllers List
    controller.choice = controller.list_of{2}; %Choice of the Controller
    controller.rel_control = 0; %Release the control, percentage of the simulation time
    if strcmp(controller.choice, 'PIPWM')
        controller.olperiods=1; %number of open loop periods before the loop closure
    end
    
    %% Inputs:
    inputs.iptg = 0;            %Initialization of the IPTG control input
    inputs.atc = 0;             %Inizialization of the aTc control input

    %% SetPoint for the Controller
    controller.setpoint.LacIref = 750;  %LacI-RFP setpoint [750 for mid level]
    controller.setpoint.TetRref = 300;  %TetR-GFP setpoint [300 for mid level]
    controller.setpoint.ref= [controller.setpoint.LacIref...
                                    controller.setpoint.TetRref];
    controller.setpoint.Xref= controller.setpoint.ref./[P.thetalaci P.thetatetr];%reference for the average model
    %% Controllers:
    if strcmp(controller.choice, 'PIPWM')
      PIPWMinitialization;
      Controller_obj = PIPWMControl(controller.kp, controller.ki,...
                               controller.setpoint.pjXref, settings.period,...
                               controller.olperiods, controller.Dref);
      LacI_inputs = SquareWave(settings.tstep, settings.period, 0, 'Direct');
      TetR_inputs = SquareWave(settings.tstep, settings.period, 0, 'Reverse');
    elseif strcmp(controller.choice, 'MPC')
      MPCInitialization;
      Controller_obj = MPCControlGA(controller.Tp, controller.Tc,...
          controller.setpoint.ref, controller.Dref, controller.GA.MG,...
          controller.GA.PS, controller.GA.MS, inputs.aTc_amp,...
          inputs.IPTG_amp, settings.period);
      LacI_inputs = SquareWave(settings.tstep, settings.period, 0, 'Direct');
      TetR_inputs = SquareWave(settings.tstep, settings.period, 0, 'Reverse'); 
    else
      %% Open Loop Square Wave
      % if choice is 1 or incorrect it falls back to open loop square wave
      controller.DutyC = 0.7;   %Value of the Duty Cycle for the Open Loop Simulation
      controller.amplitude = 0.5; %Amplitude of the inputs
      LacI_inputs = SquareWave(settings.tstep, settings.period, 0, 'Direct');
      TetR_inputs = SquareWave(settings.tstep, settings.period, 0, 'Reverse');
    end
    
end


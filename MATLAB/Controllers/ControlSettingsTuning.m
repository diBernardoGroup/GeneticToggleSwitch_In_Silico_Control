function [controller, MAIN_ctrl , LacI_ctrl, TetR_ctrl, inputs] = ControlSettingsTuning(settings, P, ext_kp, ext_ki)
%ControlSettings Defines the parameters of the controller and the Inputs of
%the simulation. Setpoint definition here.
%   Detailed explanation goes here

    %% Control Types [release, pop_avg 0 no, 1 yes]
    controller.c_type_choices = {'weakPI','strongPI','BangBang',...
                                'SquareWave','PIPWM','ZAD'}; %Controllers List
    controller.c_type = controller.c_type_choices{5}; %Choice of the Controller
    controller.rel_control = 0; %Release the control, percentage of the simulation time
    controller.population_avg = 0; %to remove and integrate in the controller
    if strcmp(controller.c_type, 'PIPWM')
        controller.olperiods=1; %number of open loop periods before the loop closure
    end
    
    %% Inputs:
    inputs.iptg = 0;            %Initialization of the IPTG control input
    inputs.atc = 0;             %Inizialization of the aTc control input
    inputs.IPTG_mult = 1/100;   %IPTG Multiplier
    inputs.aTc_mult = 1;        %aTc Multiplier

    %% SetPoint for the Controller
    controller.setpoint.LacIref = 750;  %LacI-RFP setpoint
    controller.setpoint.TetRref = 300;  %TetR-GFP setpoint
    controller.setpoint.ref= [controller.setpoint.LacIref...
                                    controller.setpoint.TetRref];

    %% Controllers:
    if strcmp(controller.c_type, 'weakPI') % Parameters as in experiments
      LacI_ctrl = PIcontrol(0.0330,1.38e-4,[750, Inf],[0,50],20,0,0);
      TetR_ctrl = PIcontrol(0.025,6.9e-4,[350, Inf],[0,50],25,0,0);
    elseif strcmp(controller.c_type, 'strongPI') % Parameters as in ED figure 7
      LacI_ctrl = PIcontrol(5e-2,2e-4,[750, Inf],[0,50],20,0,0);
      TetR_ctrl = PIcontrol(2.5e-2,6.94e-4,[350, Inf],[0,50],25,0,0);
    elseif strcmp(controller.c_type, 'BangBang') % Parameters as in experiments
      LacI_ctrl = BBcontrol([750, Inf],[0,50]);
      TetR_ctrl = BBcontrol([350, Inf],[0,50]);
    elseif strcmp(controller.c_type, 'SquareWave')
      controller.DutyC = 0.7;
      controller.amplitude = 0.5;
      LacI_ctrl = SquareWave(settings.tstep, settings.period, 0, 'Direct');
      TetR_ctrl = SquareWave(settings.tstep, settings.period, 0, 'Reverse');
    elseif strcmp(controller.c_type, 'PIPWM')
      PIPWMinitializationTuning;
      controller.Dref=0.40;
    %   settings.olperiods = settings.nperiod; %%Used not to close the control loop
      MAIN_ctrl = PIPWMControl(controller.kp, controller.ki,...
                                controller.setpoint.pjXref, settings.period,...
                                controller.olperiods, controller.Dref);
      LacI_ctrl = SquareWave(settings.tstep, settings.period, 0, 'Direct');
      TetR_ctrl = SquareWave(settings.tstep, settings.period, 0, 'Reverse');
    elseif strcmp(settings.c_type, 'ZAD')
      inputs.IPTG_amp=0.35;
      inputs.aTc_amp=35;
      controller.Curve=dCurve(inputs.aTc_amp,inputs.IPTG_amp, P);
      controller.setpoint.Xref = [controller.setpoint.ref(1)/P.thetalaci;...
                             controller.setpoint.ref(2)/P.thetatetr];
      controller.amplitude = 1;
      LacI_ctrl = SquareWave(settings.tstep, settings.period, 0, 'Direct');
      TetR_ctrl = SquareWave(settings.tstep, settings.period, 0, 'Reverse');
      k_zad=2;
      ZADinitialization; %%To Optimize
    else
      keyboard
    end
    
end


%% MPC variables Initialization
[controller.Curve, inputs.IPTG_amp, inputs.aTc_amp]...
                             =amplitudeController(controller.setpoint.ref, P);
[controller.setpoint.pjXref, ~] = Projection(controller.Curve(1:2,:),...
                                      controller.setpoint.Xref, [0;0]); %Project the setpoint onto the equilibrium curve
[~, DRindex] = min(abs(controller.Curve(1,:)-controller.setpoint.pjXref(1)));
controller.Dref=controller.Curve(3,DRindex);
controller.DutyC = [];
controller.Xav = [];

%% MPC Settings
controller.Tp = 3; %Prediction Horizon
controller.Tc = 1; %Control Horizon
controller.Ts = 1*settings.period; %Sampling Time

%% Genetic Algorithm Settings
controller.GA.MG=150;    %Max number of generations
controller.GA.PS=50;     %Population size
controller.GA.MS=30;     %Max number of stall generations
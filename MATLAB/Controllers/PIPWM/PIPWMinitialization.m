%% PIPWM variables Initialization 
[controller.Curve, inputs.IPTG_amp, inputs.aTc_amp]...
                              =amplitudeController(controller.setpoint.ref, P);
% controller.kp=0.0051;
% controller.ki=(2.37e-04)/48;
% 
% controller.kp=0.0051/0.0101*0.0101;
% controller.ki=((2.37e-04)/48)/0.0401*0.0451;
%    kpg=0.5050;
%    kpi=1.231297e-4;
controller.kp=0.0101;
controller.ki=0.0401;

[controller.setpoint.pjXref, ~] = Projection(controller.Curve(1:2,:),...
                                      controller.setpoint.Xref, [0;0]); %Project the setpoint onto the equilibrium curve
[~, DRindex] = min(abs(controller.Curve(1,:)-controller.setpoint.pjXref(1)));
controller.Dref=controller.Curve(3,DRindex);
controller.DutyC=zeros(1);
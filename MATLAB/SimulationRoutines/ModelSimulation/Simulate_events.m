function [tvec, TargetCell, controller, inputs, othercells, variance, meanv, J] = Simulate_events(P, settings, inputs, controller, MAIN_ctrl)
%Simulate computes the simulation of the selected control strategy
%   Detailed explanation goes here

%% Set simulation parameters: tfinal = T * N_cycles, where T is the period of the PWM signal
N_cycles = settings.nperiod;
tstart = 0;
nSample = 100; % time samples per period
qSS=0;


%% Set initial condition of the toggle-switch
z0 = [ 0; 0; 11.2069401104877; 0.893251542605729; 660.570425712825; 63.3261279179171];

tvec = tstart;
zout = z0.';



    for k = 1:N_cycles
    %% Control Evaluation
        if strcmp(controller.choice, 'PIPWM')
        %% Case PIPWM Controller
            [controller.DutyC(end+1)] = MAIN_ctrl.decision_ev(P,...
              tvec(end), zout(:,5), zout(:,6), settings, controller.Curve);

        elseif strcmp(controller.choice, 'ZAD')
        %% Case ZAD Controller
            [controller.DutyC(end+1), controller.Xav(:,end+1),...
                controller.surface(end+1), controller.sdotp(end+1),...
                controller.sdotm(end+1)] = MAIN_ctrl.decide(P, curr_tp, LacI(numel(LacI)), TetR(numel(TetR)),...
                                                        LacImRNA(numel(LacImRNA)),TetRmRNA(numel(TetRmRNA)),...
                                                                settings, inputs);
            controller.dimErr(:,end+1)=[controller.setpoint.LacIref; controller.setpoint.TetRref]...
                    - [LacI(numel(LacI)); TetR(numel(TetR))];
            controller.err(:,end+1)=controller.setpoint.Xref-controller.Xav(end);
            if and(mod(curr_tp,settings.period)==0,curr_tp>0)
                controller.prsurf(end+1)=controller.surface(end)+controller.sdotp(end)*settings.period*controller.DutyC(end)+controller.sdotm(end)*settings.period*(1-controller.DutyC(end));
                controller.int_surf(end+1)=sum(controller.surface(end-settings.period/settings.tstep:end))*settings.tstep/settings.period;
            end
        elseif strcmp(controller.choice, 'MPC')
            %% Case MPC
            [controller.DutyC(end+1), controller.J(end+1)]=MAIN_ctrl.decide_ev( zout(end,5), zout(end,6),...
                                                    zout(end,3), zout(end,4), zout(end,1), zout(end,2), settings.gain,1,1);
%            controller.DutyC(end+1)=dc_tc(mod(floor(curr_tp/settings.period),(controller.Ts/settings.period))+1);                               
        elseif strcmp(controller.choice, 'SquareWave')
        %% Case Open Loop Square Wave
            OLSquareWaveScript;
        else
        %% Case PI (to check)
            if mod(curr_tp, settings.period)==0
                elaps_periods=curr_tp/settings.period;
                pvec=linspace(0, elaps_periods*settings.period, 1+elaps_periods);
                inputs.PIiptg(end+1)=LacI_ctrl.decide(PM.LacI(end),pvec)*inputs.IPTG_mult;
                inputs.PIatc(end+1)=TetR_ctrl.decide(PM.TetR(end),pvec)*inputs.aTc_mult;
                controller.DutyCL(end+1)=inputs.PIiptg(end)/inputs.IPTG_amp;
                controller.DutyCT(end+1)=inputs.PIatc(end)/inputs.aTc_amp;
            end
                inputs.iptg(end+1)=LacI_PWM.decide(controller.DutyCL(end), inputs.IPTG_amp)*inputs.IPTG_mult;
                inputs.atc(end+1)=TetR_PWM.decide(controller.DutyCT(end), inputs.aTc_amp/100)*inputs.aTc_mult;
        end
        
        zz0 = zout(end,:).';
        
        %% Execute control cycle using the info about duty-cycle D
        disp( ['Avvio ciclo di controllo ', num2str(k), ' di ',num2str(N_cycles)] )
        tspan = linspace(tvec(end),tvec(end)+settings.period,nSample+1);
        [t,z] = runControl_events(tspan,zz0,controller.DutyC(end),inputs,settings,qSS);

        % Concatena stato e asse tempi
        tvec = [tvec; t(2:end)];
        zout = [zout; z(2:end,:)];

    end
    %% Interface recostruction
    TargetCell.LacI=zout(:,5);
    TargetCell.TetR=zout(:,6);
    TargetCell.LacImRNA=zout(:,3);
    TargetCell.TetRmRNA=zout(:,4);
    TargetCell.atc_del=zout(:,1);
    TargetCell.iptg_del=zout(:,2);
    othercells=[];
    variance=[];
    meanv=[];
    J=[];
    %% Recostruct the inputs given to the system
    sq = zeros(length(tvec),1);
    for k = 1:length(tvec)-1
        j=floor(tvec(k)/settings.period);
        sq(k) = u_control(tvec(k),zout(k,:),[settings.period,controller.DutyC(j+1)]); 
    end
    inputs.atc= inputs.aTc_amp * sq;
    inputs.iptg= inputs.IPTG_amp * (1-sq);
    
end
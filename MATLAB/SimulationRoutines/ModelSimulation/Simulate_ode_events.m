function [tvec, TargetCell, controller, inputs, othercells] = Simulate_ode_events(P, settings, inputs, controller, Control_obj)
%Simulate computes the simulation of the selected control strategy
%Event-driven Deterministic Simulation Algorithm

%% Set simulation parameters
tstart = 0; %initial time
nSample = 100; % time samples per period
qSS=0; %flag to work with the avg model (0 no, 1 yes)


%% Set initial condition of the toggle-switch
z0 = [ 0; 0; 11.2069401104877; 0.893251542605729;...
        660.570425712825; 63.3261279179171]; %Initial conditions
tvec = tstart; %array that stores the time values
zout = z0.'; %array that stores the state values

    for k = 1:settings.nperiod
    %% Control Evaluation
        if strcmp(controller.choice, 'PIPWM')
        %% Case PIPWM Controller
            [controller.DutyC(end+1)] = Control_obj.decision_ev(P,...
              tvec(end), zout(:,5), zout(:,6), settings, controller.Curve);
        elseif strcmp(controller.choice, 'MPC')
        %% Case MPC
        [controller.DutyC(end+1)]=Control_obj.decision_ev(...
            zout(end,5), zout(end,6), zout(end,3), zout(end,4),...
            zout(end,1), zout(end,2), 1,1);
        else
        %% Case Open Loop Square Wave
            OLSquareWaveScript;
        end
        zz0 = zout(end,:).';
        
        %% Execute control cycle using the info about duty-cycle D
        disp( ['Starting Control Cycle ', num2str(k), ' of ',num2str(settings.nperiod)] )
        tspan = linspace(tvec(end),tvec(end)+settings.period,nSample+1);
        [t,z] = runControl_events(tspan,zz0,controller.DutyC(end),inputs,settings,qSS);

        % Cat state and temporal axes
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
    %% Recostruct the inputs given to the system
    sq = zeros(length(tvec),1);
    for k = 1:length(tvec)-1
        j=floor(tvec(k)/settings.period);
        sq(k) = u_control(tvec(k),zout(k,:),[settings.period,controller.DutyC(j+1)]); 
    end
    inputs.atc= inputs.aTc_amp * sq;
    inputs.iptg= inputs.IPTG_amp * (1-sq);
    
end
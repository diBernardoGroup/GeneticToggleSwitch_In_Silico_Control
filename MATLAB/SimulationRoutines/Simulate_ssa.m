function [tvec, TargetCell, controller, inputs, othercells] = Simulate_ssa(P, settings, inputs, controller, LacI_obj, TetR_obj, Control_obj)
%Simulate_ssa computes the stochastic simulation of the selected control strategy

    %% Time variables (minutes)
    t_index = 0;    %Current Time Instant
    tvec = 0:settings.tstep:settings.duration;       %Time Vector
    %% Initialize output variables
    othercells = [];
    %% Parameter Variation
    if settings.var_param==1
            disp(['Generating variations on parameters.'])
            P_mat=cell2mat(struct2cell(P));
            for i=1:settings.numcells
                for j=1:length(P_mat)
                    P_mat(j,i+1)=normrnd(P_mat(j,1), P_mat(j,1)/5 );
                end
            end
            TP_array=cell2mat(struct2cell(P));
            for index_m = 1:length(TP_array)
                TP_array(index_m)=normrnd(TP_array(index_m),TP_array(index_m)/5);
            end
            Target_Param=generate_parameers(TP_array);
            P_mat(:,1)=TP_array;
    else
            P_mat=cell2mat(struct2cell(P));
            for i=1:settings.numcells
                P_mat(:,i+1)=P_mat(:,1);
            end
            Target_Param=P;
    end
    Target_Param=generate_parameters(P_mat(:,1));
    
    %% Launch the control loop
    Y0 = startingpoint_ode(P, [inputs.atc inputs.iptg]);
    SimInitialization;   %Initial Point of the Simulation
    
    while(t_index<settings.duration)
        if strcmp(controller.choice, 'PIPWM')
        %% Case PIPWM Controller
            [controller.DutyC(end+1)] = Control_obj.decision(P, t_index, ...
                                   LacI, TetR, settings, controller.Curve);
            inputs.iptg(end+1) = TetR_obj.decision(controller.DutyC(end), inputs.IPTG_amp);
            inputs.atc(end+1) = LacI_obj.decision(controller.DutyC(end), inputs.aTc_amp);
       elseif strcmp(controller.choice, 'MPC')
            %% Case MPC
            [controller.DutyC(end+1)]=Control_obj.decision_ev( LacI(numel(LacI)), TetR(numel(TetR)),...
                                                    LacImRNA(numel(LacImRNA)), TetRmRNA(numel(TetRmRNA)),...
                                                    atc_del(numel(atc_del)), iptg_del(numel(iptg_del)),...
                                                    t_index, controller.Ts);
            inputs.iptg(end+1) = TetR_obj.decision(controller.DutyC(end), inputs.IPTG_amp)*inputs.IPTG_mult;
            inputs.atc(end+1) = LacI_obj.decision(controller.DutyC(end), inputs.aTc_amp/100)*inputs.aTc_mult;                                 
        else strcmp(controller.choice, 'SquareWave')
        %% Case Open Loop Square Wave
            OLSquareWaveScript;
        end
        %% Simulate a step of evolution 
        [LmRNA,TmRNA,L,T,I,A] = simulate_a_step(Target_Param,...
                                            [LacImRNA(1,end),TetRmRNA(1,end),...
                                            LacI(1,end),TetR(1,end),...
                                            iptg_del(1,end),atc_del(1,end)],...
                                            [0 settings.tstep],...
                                            [inputs.atc(end) inputs.iptg(end) 0]);
        
        %% Update Values
        CellUpdate;
        t_index = t_index+settings.tstep;
        if settings.showprogress
            disp(strcat(num2str(round(t_index/settings.duration*100,1)),'%'))
        end
    end
    disp('[Target Cell] Simulation terminated.')
    %% Simulate other cells:
        disp(['[Other Cells] Starting simulation of ' num2str(settings.numcells) ' cells.'])
        parfor (othIndex=1:settings.numcells, 6)
            P_var=generate_parameters(P_mat(:,othIndex+1));
            [othercells(othIndex).LacImRNA,...
             othercells(othIndex).TetRmRNA,...
             othercells(othIndex).LacI,...
             othercells(othIndex).TetR,...
             othercells(othIndex).iptg_del,...
             othercells(othIndex).atc_del,...    
             ] = simulate_a_step(P_var,Y0,tvec,...
                    [inputs.atc(2:end)' inputs.iptg(2:end)' tvec(2:end)']);

            disp(['[Other Cells] Cell ' num2str(othIndex) ' of ' num2str(settings.numcells) ' terminated.'])
        end
    
    %% Update the structure fields    
    TargetCell.LacI =LacI;
    TargetCell.TetR = TetR;
    TargetCell.LacImRNA = LacImRNA;
    TargetCell.TetRmRNA = TetRmRNA;
    TargetCell.atc_del = atc_del;
    TargetCell.iptg_del = iptg_del;
    clear LacI TetR LacImRNA TetRmRNA atc_del iptg_del

    disp('Simulation Routine terminated.');
end


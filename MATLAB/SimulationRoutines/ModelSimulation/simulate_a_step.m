function [ LacImRNA, TetRmRNA, LacI, TetR, iptg, atc ] = simulate_a_step(p,Y0,tspan,inputs, varargin)
%simulate_a_step - Main Toggle Switch simulation function, for SSA
%This function simulates the toggle switch stochastic model described by 
%toggle_switch_ssa with the parameters p over the timepoints given 
%in the variable tspan.
%
% [ LacImRNA, TetRmRNA, LacI, TetR , iptg, atc] = simulate_a_step(p,Y0,tspan,inputs)
%
%Adapted from Lugagne et al - NatCom 2017



    %% Parsing inputs
    ip = inputParser;
    addRequired(ip,'p',@isstruct);
    addRequired(ip,'Y0',@isvector);
    addRequired(ip,'tspan',@isvector);
    addRequired(ip,'inputs',@ismatrix);
    parse(ip,p,Y0,tspan,inputs,varargin{:});
    events = inputs;
    [stoich_matrix, propensities, reactions, species_names] = toggle_switch_ssa();
    iptgbefore = Y0(5);
    atcbefore = Y0(6);
    
    
    %% Simulating:
    Y = [];
    for ind1 = 1:size(events,1)
        % Recompute time-spans
        tspan_beg = find(tspan >= events(ind1,3),1,'first');
        if isempty(tspan_beg)
            break;
        end
        if ind1 < size(events,1) && events(ind1+1,3) < tspan(end)
            tspan_end = find(tspan < events(ind1+1,3),1,'last');
            last_element = events(ind1+1,3); % Will be used for Y0
        else
            tspan_end = numel(tspan);
            last_element = tspan(end)+1; % Just a small time horizon to run the simulation for the last event
        end
        tspan_short = [tspan(tspan_beg:tspan_end) last_element]-events(ind1,3);
        
        [time_iptg, iptgdelayed] = iptgdelayfcn(events(ind1,2),tspan_short, p, iptgbefore);
        [time_atc, atcdelayed] = atcdelayfcn(events(ind1,1),tspan_short, p, atcbefore);

        rate_params.pre_comp_iptg_v = iptgdelayed;
        rate_params.pre_comp_iptg_t = time_iptg;
        rate_params.pre_comp_atc_v = atcdelayed;
        rate_params.pre_comp_atc_t = time_atc;
        rate_params.reactions = reactions;
        rate_params.species_names = species_names;
        rate_params.p = p;               
        % Run Gillespie's SSA
        [~, Y_short] = firstReactionMethod( stoich_matrix, propensities, tspan_short, round(Y0(1:(end-2))),...
                                 rate_params);                                     


        Y_short(:,5) = interp1(time_iptg,iptgdelayed,tspan_short,'linear','extrap');
        iptgbefore = iptgdelayed(end);
        Y_short(:,6) = interp1(time_atc,atcdelayed,tspan_short,'linear','extrap');
        atcbefore = atcdelayed(end);


        Y = cat(1,Y,Y_short(1:(end-1),:));   
        Y0 = Y_short(end,:);
    end

    
    LacImRNA=Y(:,1);
    TetRmRNA=Y(:,2);
    LacI=Y(:,3); 
    TetR=Y(:,4); 
    iptg=Y(:,5);
    atc=Y(:,6);
end

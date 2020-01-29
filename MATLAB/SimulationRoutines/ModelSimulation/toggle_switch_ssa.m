function [stoich_matrix, propensities, reactions, species_names] = toggle_switch_ssa()
% Adapted from Lugagne et al. - NatCom 2017

%% Stochastic Model of the Toggle Switch
% Declare species names:
species_names = {'LacImRNA', 'TetRmRNA', 'LacI', 'TetR'};

%% Declare the equations & stoichiometry: 
% "pTet" transcription of laci mrna
reactions.lacim_trscr.stoich = {'LacImRNA',+1};
reactions.lacim_trscr.prop = @(spcs,ipts,p) ...
            p.km0l ...
            + p.kml .* hill_func(   spcs.TetR .* hill_func( ipts.atc, ...
                                                            p.thetaaTc, ...
                                                            p.etaaTc), ...
                                    p.thetatetr, ...
                                    p.etaTetR);
                                
% "pLac" transcription of tetr mrna
reactions.tetrm_trscr.stoich = {'TetRmRNA',+1};
reactions.tetrm_trscr.prop = @(spcs,ipts,p) ...
            p.km0t ...
            + p.kmt .* hill_func(   spcs.LacI .* hill_func( ipts.iptg, ...
                                                            p.thetaIPTG, ...
                                                            p.etaIPTG), ...
                                    p.thetalaci, ...
                                    p.etaLacI);
                                
% Translation of LacI protein
reactions.LacIp_trsl.stoich = {'LacI',+1};
reactions.LacIp_trsl.prop = @(spcs,ipts,p) p.kpl.*spcs.LacImRNA;

% Translation of TetR protein
reactions.TetRp_trsl.stoich = {'TetR',+1};
reactions.TetRp_trsl.prop = @(spcs,ipts,p) p.kpt.*spcs.TetRmRNA;

% Degradation of laci mRNA
reactions.lacim_deg.stoich = {'LacImRNA',-1};
reactions.lacim_deg.prop = @(spcs,ipts,p) p.gml.*spcs.LacImRNA;

% Degradation of tetr mRNA
reactions.tetrm_deg.stoich = {'TetRmRNA',-1};
reactions.tetrm_deg.prop = @(spcs,ipts,p) p.gmt.*spcs.TetRmRNA;

% Dilution of LacI proteins
reactions.LacIp_dil.stoich = {'LacI',-1};
reactions.LacIp_dil.prop = @(spcs,ipts,p) p.gpl.*spcs.LacI;

% Dilution of TetR proteins
reactions.TetRp_dil.stoich = {'TetR',-1};
reactions.TetRp_dil.prop = @(spcs,ipts,p) p.gpt.*spcs.TetR;

%% The output variables that will be used by the SSA function:
stoich_matrix = processStoichiometry(reactions,species_names);
propensities = @propensites_computation;



function stoich_matrix = processStoichiometry(reactions,spcsn)
% From the reactions defined in the main function above, create the
% stoichiometry matrix for the stochastic simulation algorithm:

% Initialize:
rctn_names = fieldnames(reactions);
stoich_matrix = [];

% Loop through all reactions:
for ind1 = 1:numel(rctn_names)
    stoich_cel = reactions.(rctn_names{ind1}).stoich;
    stoich_vec = zeros(1,numel(spcsn));
   % Loop through all species involved:
    for ind2 = 1:size(stoich_cel,1)
        stoich_vec(strcmp(stoich_cel{ind2,1},spcsn)) = stoich_cel{ind2,2}; % The vector for this specifiec reaction
    end    
    % The actual matrix:
    stoich_matrix = cat(1,stoich_matrix,stoich_vec);
end




function props = propensites_computation(spcs_vec,entire_params,t)
% This is the function that will be called by the gillespie simulation to
% compute propensities:

% Initialize:
reactions = entire_params.reactions;
spcs = reconstructspcs(spcs_vec,entire_params.species_names);
rctn_names = fieldnames(reactions);

% Inducer levels:
ipts.iptg = interp1(entire_params.pre_comp_iptg_t,entire_params.pre_comp_iptg_v,t,'linear','extrap');
ipts.atc = interp1(entire_params.pre_comp_atc_t,entire_params.pre_comp_atc_v,t,'linear','extrap');

% Compute propensities:
for ind1 = 1:numel(rctn_names)
    props(ind1,1) = real(reactions.(rctn_names{ind1}).prop(spcs,ipts,entire_params.p));
end



%% Utilities:
function spcs = reconstructspcs(spcs_vec,spcsn)
for ind1 = 1:numel(spcsn)
    spcs.(spcsn{ind1}) = spcs_vec(ind1);
end

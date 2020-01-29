function [tout,zout] = runControl_events(tspan,Z0,D_vec,inputs,settings,qSS)
% Input Z0=[aTc, IPTG,mRNALacI, mRNATetR, LacI, TetR] and
% the array of duty-cycle D_vec = [D1,
% D2, ..., DTc] to be used in the control horizon.
% Output the evolution of the system [t,z]

Tc = length(D_vec);
 
% Set simulation time and tspan 
tstart = tspan(1);
tfinal = tspan(end);

% Set variables and option for odesolver
options = odeset('Events',@cellEvents,'RelTol',1e-4); 

z0 = Z0;

tout = tstart;
zout = z0.';
teout = [];
zeout = [];
ieout = [];
    for k = 1:Tc
        D = D_vec(k);
        % Solve until the first terminal event.
        [t,z,te,ze,ie] = ode15s(@f,tspan,z0,options,[inputs.aTc_amp,inputs.IPTG_amp,settings.period,D,qSS]);

        % Accumulate output.  This could be passed out as output arguments.
        nt = length(t);
        tout = [tout; t(2:nt)];
        zout = [zout; z(2:nt,:)];
        teout = [teout; te];          % Events at tstart are never reported.
        zeout = [zeout; ze];
        ieout = [ieout; ie];  

        % % Set the new initial condition 
        z0 = z(end,:).';       

        % % If the following condition is true, then simulation ends
        if t(end) == tfinal
            break;
        end

        % % Update solver options
        options = odeset(options,'InitialStep',t(nt)-t(nt-1)); 

        % % Set new tspan
        tspan = [t(end),tspan(tspan>t(end))];
    end


end

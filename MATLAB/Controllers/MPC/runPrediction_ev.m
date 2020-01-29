function [J, x, y ,tout] = runPrediction_ev(D_vec,Z0,p,setpoint)
% This function computes the prediction of the evolution
%of the Toggle Switch for the MPC optimization problem
% % %

Tp = length(D_vec);

U_atc = p(1);
U_iptg = p(2);
T = p(3); 
qSS = p(4);

% Set simulation time and tspan 
tstart = 0;
tfinal = T * Tp;
tspan = [tstart,tfinal];

% Set variables and option for odesolver
options = odeset('Events',@cellEvents,'RelTol',1e-4); 
% Initialization
z0 = Z0;
tout = tstart;
zout = z0.';
teout = [];
zeout = [];
ieout = [];

for k = 1:Tp
    D = D_vec(k);
    % Solve until the first terminal event.
    [t,z,te,ze,ie] = ode15s(@f,tspan,z0,options,[U_atc,U_iptg,T,D,qSS]);
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

Zout = zout(:,end-1:end);
J = evalCost(tout,Zout,setpoint(1),setpoint(2));
end

function [J] = evalCost(t,z,LacIref, TetRref)
x = z(:,1);
y = z(:,2);
Jt = ( (x-LacIref)/LacIref ).^2 + 4*( (y-TetRref)/TetRref ).^2;
J = trapz(t,Jt); 
end

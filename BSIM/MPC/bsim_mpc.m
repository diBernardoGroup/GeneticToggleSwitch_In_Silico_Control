function DC = bsim_mpc(input) %obj, LacI, TetR, LacImRNA, TetRmRNA, atc_del, iptg_del, kt, curr_tp, Ts)   
    %%Parsing Inputs
    LacI=input(1);
    TetR=input(2);
    LacImRNA=input(3);
    TetRmRNA=input(4);
    atc_del=input(5);
    iptg_del=input(6);
    %%Genetic Algotihms Options
    opts=optimoptions('ga','MaxGenerations',150,'InitialPopulationRange',...
        [0; 0.4],'PopulationSize',50,'Display', 'iter',...
        'UseParallel', true, 'MaxStallGenerations',30);
    
    DC=ga(@(x)runPrediction_ev(x,...
                        [atc_del iptg_del LacImRNA TetRmRNA LacI TetR].',...
                        [35 0.35 240 1],4),3,...
                        [],[],[],[],zeros(3,1),...
                        ones(3,1),[],opts);
    
end 

function [J, x, y ,tout] = runPrediction_ev(D_vec,Z0,p,kt)

    Tp = length(D_vec);
    U_atc = p(1);
    U_iptg = p(2);
    T = p(3); 
    qSS = p(4);

    tstart = 0;
    tfinal = T * Tp;
    tspan = [tstart,tfinal];

    % Set variables and option for odesolver
    options = odeset('Events',@cellEvents,'RelTol',1e-4); 

    z0 = Z0;
    tout = tstart;
    zout = z0.';
    teout = [];
    zeout = [];
    ieout = [];
        for k = 1:Tp
            D = D_vec(k);
            [t,z,te,ze,ie] = ode15s(@f,tspan,z0,options,[U_atc,U_iptg,T,D,qSS]);
            nt = length(t);
            tout = [tout; t(2:nt)];
            zout = [zout; z(2:nt,:)];
            teout = [teout; te];          % Events at tstart are never reported.
            zeout = [zeout; ze];
            ieout = [ieout; ie];  
            z0 = z(end,:).';    
            if t(end) == tfinal
                break;
            end
            options = odeset(options,'InitialStep',t(nt)-t(nt-1)); 
            tspan = [t(end),tspan(tspan>t(end))];
        end
    Zout = zout(:,end-1:end);
    J = evalCost(tout,Zout,kt);

end

function [J] = evalCost(t,z,kt)

x = z(:,1);
y = z(:,2);

LacIref = 750;
TetRref = 300;
Tp=5;
T=240;
K=1;
Jt = ( (x-LacIref)/LacIref ).^2 + kt*( (y-TetRref)/TetRref ).^2;


J = trapz(t,Jt);

end
function dzdt = f(t,z,p)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Parsing parameters
U_atc = p(1);
U_iptg = p(2);
T = p(3);
D = p(4);
qSS = p(5);

% Parsing state
aTc = z(1);
IPTG = z(2);
mRNALacI = z(3);
mRNATetR = z(4);
LacI = z(5);
TetR = z(6);

% Lugnagne's parameters
kiptgIn = 2.75 *10^-2;
kiptgOut = 1.11 * 10^-1;
katcIn = 1.62 * 10^-1;
katcOut = 2 * 10^-2;

thetaAtc = 11.65;
thetaIptg = 9.06 * 10^-2;

kLm0 = 3.20 * 10^-2;
kLm = 8.30;
thetaLacI = 31.94;
gLm = 1.386*10^-1;
kLp = 9.726*10^-1;
gLp = 1.65*10^-2;

kTm0 = 1.19 * 10^-1;
kTm = 2.06;
thetaTetR = 30;
gTm = 1.386*10^-1;
kTp = 1.170;
gTp = 1.65*10^-2;

% Evaluate control input u at time t
sq = u_control(t,z,[T D]);
u_atc = U_atc*sq;
u_iptg = U_iptg*(1-sq);

% Evaluate vector fields
dzdt = zeros(6,1);

if true 
    % Asymmetrical diffusion dynamics across cell membrane
    % % aTc    
    dzdt(1) = katcIn * max( u_atc - aTc, 0) - katcOut * max( aTc - u_atc, 0);
    % % IPTG    
    dzdt(2) = kiptgIn * max( u_iptg - IPTG, 0) - kiptgOut * max( IPTG - u_iptg, 0);
else
    % Instantaneous diffusion
    dzdt(1) = 0;
    dzdt(2) = 0;
    aTc = u_atc;
    IPTG = u_iptg;
end

w_atc = 1 / ( 1 + ( aTc/thetaAtc )^2 );
w_iptg = 1 / ( 1 + ( IPTG/thetaIptg )^2 );

% Set false for quasi steady-state model, true for complete model (with
% mRNA dynamics
if ~qSS
    % % Complete 4D model
    % mRNA LacI
    dzdt(3) = kLm0 + kLm *  1/( 1 + ( TetR/thetaTetR * w_atc  )^2  )  - gLm * mRNALacI;
    % mRNA TetR
    dzdt(4) = kTm0 + kTm *  1/( 1 + ( LacI/thetaLacI * w_iptg  )^2  )  - gTm * mRNATetR;
else
    % % QuasiSS model
    dzdt(3) = 0;
    dzdt(4) = 0;
    % mRNA LacI
    mRNALacI = ( kLm0 + kLm *  1/( 1 + ( TetR/thetaTetR * w_atc  )^2  ) )  / gLm;
    % mRNA TetR
    mRNATetR = ( kTm0 + kTm *  1/( 1 + ( LacI/thetaLacI * w_iptg  )^2  ) ) / gTm;
end

% LacI
dzdt(5) = kLp * mRNALacI - gLp * LacI;
% TetR
dzdt(6) = kTp * mRNATetR - gTp * TetR;
end
function [u] = u_control(t,z,p)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
closedloop = false;
    if ~closedloop
        % OPEN LOOP algorithm

        % PWM: period T, duty cycle D, delay t_delay
        Tu = p(1);  
        Du = p(2);
        t_delay = 0; % è necessario un delay perché il solver ignora il primo evento u=1 se parte a t=0

        if mod(t-t_delay,Tu) < Du*Tu
            u = 1;
        else
            u = 0;
        end
    else
        % CLOSED LOOP algorithm
        % persistent int_state; % internal state of the control algorithm persistent for every calls   
    end
end
function [value,isterminal,direction] = cellEvents(t,z,p)

T = p(3);
D = p(4);

u = u_control(t,z,[T, D]);

% Detect event: control input u == 1
value(1) = u-1;
isterminal(1) = 1;
direction(1) = 1;

% Detect event: control input u == 0
value(2) = u;
isterminal(2) = 0;
direction(2) = -1;

end



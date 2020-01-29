function dzdt = f(t,z,p)
%Model for the event driven simulations

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




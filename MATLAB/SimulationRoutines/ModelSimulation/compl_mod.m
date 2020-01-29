function dx = compl_mod(P, x, u)
%UNTITLED Complete Deterministic Model
%   x(1) mRNALacI
%   x(2) mRNATetR
%   x(3) LacI
%   x(4) TetR
%   x(5) aTc
%   x(6) IPTG
%   u(1) uaTc
%   u(2) uIPTG
dx(1) = P.km0l-P.gml*x(1)+P.kml/(1+((x(4)/P.thetatetr)*(hill_func(x(5),P.thetaaTc,P.etaaTc)))^P.etaTetR);
dx(2) = P.km0t-P.gmt*x(2)+P.kmt/(1+((x(3)/P.thetalaci)*(hill_func(x(6),P.thetaIPTG,P.etaIPTG)))^P.etaLacI);
dx(3) = P.kpl*x(1)-P.gpl*x(3);
dx(4) = P.kpt*x(2)-P.gpt*x(4);
dx(5) = max((u(1) - x(5))/(P.atcdelay1/60),0)-max((x(5)-u(1))/(P.atcdelay2/60),0);
dx(6) = max((u(2) - x(6))/(P.iptgdelay1/60),0)-max((x(6)-u(2))/(P.iptgdelay2/60),0);

end


function [dydt] = LugagneModel(y,u)
%Equations of the ODE model in Lugagne NatComm

    load('Parameters');
    p=P;
    dydt= zeros(6,1);
    atc_ext = u(1);
    iptg_ext = u(2);
    dydt(1) = p.km0l + p.kml * hill_func(y(4) * hill_func(y(6),p.thetaaTc,p.etaaTc),p.thetatetr,p.etaTetR) - p.gml*y(1);
    dydt(2) = p.km0t + p.kmt * hill_func(y(3) * hill_func(y(5),p.thetaIPTG,p.etaIPTG),p.thetalaci,p.etaLacI) - p.gmt*y(2);
    dydt(3) = p.kpl*y(1) - p.gpl*y(3);
    dydt(4) = p.kpt*y(2) - p.gpt*y(4);
    dydt(5) = max((iptg_ext - y(5))/(p.iptgdelay1/60),0)-max((y(5)-iptg_ext)/(p.iptgdelay2/60),0);
    dydt(6) = max((atc_ext - y(6))/(p.atcdelay1/60),0)-max((y(6)-atc_ext)/(p.atcdelay2/60),0);
end


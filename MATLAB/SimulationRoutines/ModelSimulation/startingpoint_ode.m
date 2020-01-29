function [Y] = startingpoint_ode( p ,inputsbefore)
%STARTING POINT compute the concentrations of mrna and proteins after a
%night for =/= inducer concentrations. the format of the inducer is
%[ATC;IPTG] it should contain only 1 value for each inducer.

    opts = odeset('NonNegative',1:5);
    Y0= startingpoint_value(p, inputsbefore);
    funname= @toggle_switch_det;
    [~,Y] = ode15s(funname,[0 4800],Y0,opts,inputsbefore',p);
    Y=Y(end,:);
end
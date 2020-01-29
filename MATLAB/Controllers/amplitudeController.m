function [Curve, IPTG_amp, aTc_amp] = amplitudeController(objective, p)
%Amplitude Controller
%   This function decides the amplitude of the square wave inputs given the
%   position of the setpoint. 
%   Input: Setpoint for the control loop, parameters of the model
%   Output: Curve of Equilibria, IPTG amplitude and aTc ampltitude values

%%Load Curves Database
load('DatabaseCurves.mat') %%load the database of the curves

%%Check the distance of the setpoint from all the curves in the database
distances=zeros(indexcurve-1,1);
for indexdist=1:indexcurve-1
    curvep=squeeze(curves(indexdist,:,:)); %%select the curve to evaluate the distance from
    [proj, ~]=Projection(curvep,...
            [objective(1)/C.thetalaci objective(2)/C.thetatetr],...
                [0,0]);   %project the setpoint onto the curve
    %%Evaluation of the distance of the setpoint prom its projection
    distances(indexdist)=norm([objective(1)/C.thetalaci objective(2)/C.thetatetr]-proj);
end

%%Select the curve with minimum distance
[~, chosen] = min(abs(distances));
%%Traduction of the results in terms of amplitudes

if chosen<=20  %%First 20 curves in the database are IPTG variable aTc=100
    IPTG_amp=0.05+mod(chosen-1, 20)*0.05;
    aTc_amp=100;
elseif chosen <=40 %%Second 20 curves in the db are aTc variable IPTG=1
    IPTG_amp=1;
    aTc_amp=100*(0.05+mod(chosen-1,20)*0.05);
else %%Last 20 curves in the database are IPTG/aTc constant
    IPTG_amp=0.05+mod(chosen-1,20)*0.05;
    aTc_amp=100*(0.05+mod(chosen-1,20)*0.05);
end
%% Recostruction of the curve using the avg model
Curve=dCurve(aTc_amp,IPTG_amp, p);
end


classdef PIPWMControl < handle
    %PIPWMControl define the behaviour of a PWM based control
    %   Detailed explanation goes here
    
    properties
        kp = 0; %Proportional Gain
        ki = 0; %Integral Gain
        setp = 0; %Setpoint of the Controller
        period = 0; %Period of the PWM
        olperiods = 0; %Number of Open loop Periods befor the activation
        Dref = 0; %Store the Value of the Dref
        err = 0; %Control Error
        interr = 0 ; %Integral of Control Error
        DutyC = 0; %Store the last value of the DutyCycle
        Xav = [0;0];
    end
    
    methods
        function obj = PIPWMControl(varargin)
            if nargin >= 1
                obj.kp = varargin{1};
            end
            if nargin >= 2
                obj.ki = varargin{2};
            end
            if nargin >= 3
                obj.setp = varargin{3};
            end
            if nargin >= 4
                obj.period = varargin{4};
            end
            if nargin >=5
                obj.olperiods = varargin{5};
            end
            if nargin >=6
                obj.Dref = varargin{6};
            end
        end
        
        function [DC] = decision(obj, P, curr_tp, LacI, TetR, settings, Curve)
            if(mod(curr_tp,obj.period)==0) %use the last value of dc if not the correct time
                if(curr_tp<obj.olperiods*obj.period)%for initial open loop periods
                   obj.DutyC=obj.Dref;
                else %evaluate the control input
                   %%AVG system state evaluation 
                   obj.Xav(1)=sum(LacI(end-obj.period/settings.tstep:end))*settings.tstep/obj.period/P.thetalaci;
                   obj.Xav(2)=sum(TetR(end-obj.period/settings.tstep:end))*settings.tstep/obj.period/P.thetatetr;
                   [~, obj.err]=Projection(Curve, obj.Xav, obj.setp);
                   kpg=0.5050;
                   kpi=1.231297e-4;
                   %%Anti Wind-up code
                   if abs(obj.ki*kpi*(obj.interr+obj.err*settings.period))<1
                       obj.interr=obj.interr+obj.err*settings.period;
                   end
                   deltaD = obj.kp*kpg*obj.err + obj.ki*kpi*obj.interr;
                   obj.DutyC=obj.Dref+deltaD;
                   obj.DutyC=min(1,obj.DutyC);
                   obj.DutyC=max(0,obj.DutyC);
                end
            end
            DC = obj.DutyC;              
        end
        function [DC] = decision_ev(obj, P, curr_tp, LacI, TetR, settings, Curve)
            if(mod(curr_tp,obj.period)==0)
                if(curr_tp<obj.olperiods*obj.period)
                   obj.DutyC=obj.Dref;
                else 
                   obj.Xav(1)=sum(LacI(end-obj.period/settings.tstep:end))*settings.tstep/obj.period/P.thetalaci;
                   obj.Xav(2)=sum(TetR(end-obj.period/settings.tstep:end))*settings.tstep/obj.period/P.thetatetr;
                   [~, obj.err]=Projection(Curve, obj.Xav, obj.setp);
                   kpg=0.5050;
                   kpi=1.231297e-4;

                   %%Anti Wind-up code
                   if abs(obj.ki*kpi*(obj.interr+obj.err*settings.tstep))<1
                       obj.interr=obj.interr+obj.err*settings.tstep;
                   end
                   deltaD = obj.kp*kpg*obj.err + obj.ki*96*kpi*obj.interr;
                   obj.DutyC=obj.Dref+deltaD;
                   obj.DutyC=min(1,obj.DutyC);
                   obj.DutyC=max(0,obj.DutyC);
                end
            end
            DC = obj.DutyC;              
        end
    end
end


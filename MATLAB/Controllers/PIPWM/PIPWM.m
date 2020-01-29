function [atc, iptg, projerr, projerrint, DutyC, Xav] = PIPWM(kp, ki, settings, curr_tp, Dref, DutyC, LacI,...
                                         TetR, Curve, Xref, Xav, projerr, projerrint, inputs, TetR_ctrl, LacI_ctrl, P)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
      if(mod(curr_tp,settings.period)==0)
        if(curr_tp<settings.olperiods*settings.period)
           DutyC(end+1)=Dref;
           projerr=0;
           projerrint=0;
           Xav=Xav;
        else
           Xav(1,end+1)=sum(LacI(end-settings.period/settings.tstep:end))*settings.tstep/settings.period/P.thetalaci;
           Xav(2,end)=sum(TetR(end-settings.period/settings.tstep:end))*settings.tstep/settings.period/P.thetatetr;
           [~, projerr]=Projection(Curve, Xav(:,end), Xref);
           %%Anti Wind-up code
           if abs(ki*(projerrint(end)+projerr(end)*settings.tstep))<1
               projerrint(end+1)=projerrint(end)+projerr(end)*settings.tstep;
           else
               projerrint(end+1)=projerrint(end);
           end
           deltaD(end+1)=kp*projerr(end)+ki*projerrint(end);
           DutyC(end+1)=Dref+deltaD(end);
           DutyC(end)=min(1,DutyC(end));
           DutyC(end)=max(0,DutyC(end));
        end
        else
            projerr=projerr;
            projerrint=projerrint;
            Xav=Xav;
        end
        if settings.population_avg ==0 
          if and(curr_tp/settings.duration>0.85, settings.rel_control==1)
            iptg = 15*inputs.iptg_mult;
            atc = 15*inputs.atc_mult;
          else
            iptg = TetR_ctrl.decide(DutyC(end), inputs.IPTG_amp)*inputs.iptg_mult;
            atc = LacI_ctrl.decide(DutyC(end), inputs.aTc_amp/100)*inputs.atc_mult;
          end
        else
         if and(curr_tp/settings.duration>0.85, settings.rel_control==1)
          iptg = 15*inputs.iptg_mult;
          atc = 15*inputs.atc_mult;
         else
          iptg = TetR_ctrl.decide(DutyC(end), inputs.IPTG_amp)*inputs.iptg_mult;
          atc = LacI_ctrl.decide(DutyC(end), inputs.aTc_amp/100)*inputs.atc_mult;
         end
        end
end


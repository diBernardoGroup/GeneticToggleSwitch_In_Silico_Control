function Curve = dCurve( aTc_amp, IPTG_amp, p)
%Evaluate inputs of the average model
w1=w_function(aTc_amp, p.thetaaTc, p.etaaTc, p.etaTetR);
w2=w_function(IPTG_amp, p.thetaIPTG, p.etaIPTG, p.etaLacI);
%Initialization
eps=1;
Curve=zeros(3,1);
exitflag=1;
foptions = optimoptions('fsolve','Display','none');
for d=0.05:0.05:1
    if(exitflag==1)
        X=@(x)[eps*(p.kav01+p.kav1*(d/(1+x(2).^2)+(1-d)/(1+(x(2).^2)*w1))-x(1));
        eps*(p.kav02+p.kav2*(d/(1+(x(1).^2)*w2)+(1-d)/(1+x(1).^2))-x(2))];
        [Curve(1:2,end+1), ~, exitflag]=fsolve(X, Curve(1:2,end), foptions);
        Curve(3,end)=1.05-d;
    end
end

Curve=Curve(:,2:end);

end


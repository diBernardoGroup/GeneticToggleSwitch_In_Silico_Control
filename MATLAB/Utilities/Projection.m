function [ proj, len ] = Projection ( cpoints, extpoint, finpoint )
%This function evaluates the distance of the projections of two points on a
%curve
%Inputs: points of the curve, external point (state of the avg system),
%internal point, setpoint (supposed to be on the curve)

coeff=polyfit(cpoints(1,:),cpoints(2,:), 3); %Fit from data
eq = @(x) coeff(1)*x.^3+coeff(2)*x.^2+coeff(3)*x+coeff(4); %equation of the curve
proj=ProjectionOnACurve(eq, extpoint); %Evaluate the projection of an external point on the curve
deqdx=@(x) sqrt(1+(3*coeff(1)*x.^2+2*coeff(2)*x+coeff(3)).^2);
len= integral(deqdx, proj(1), finpoint(1)); %Measure of the length of the arch

end


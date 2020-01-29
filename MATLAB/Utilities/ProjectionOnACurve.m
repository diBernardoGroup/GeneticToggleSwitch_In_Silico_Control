function [ projection ] = ProjectionOnACurve( equation, point)
%ProjectionOnACurve evaluates the projection of an external point onto a
%given courve
%   equation = equation of the curve onto which the point must be projected
%   point = external point that has to be projected

%%This implementation can be different
x=0:0.01:150; %define a range over which the equation is computed
y=feval(equation, x); %compute the equation = point of the curve
distances=zeros(1,length(y)); %initialize a vector that contains distances

%Evaluate the distance of the external point from all the point of the
%curve
for(index=1:length(y))
    distances(index)=norm([x(index);y(index)]-point);
end

[~, ind]=min(distances); %Find the minimum distance = find the projection

projection=[x(ind), y(ind)]; %Return the value
end


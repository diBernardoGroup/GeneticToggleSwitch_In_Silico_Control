function [value,isterminal,direction] = cellEvents(t,z,p)

T = p(3);
D = p(4);

u = u_control(t,z,[T, D]);

% Detect event: control input u == 1
value(1) = u-1;
isterminal(1) = 1;
direction(1) = 1;

% Detect event: control input u == 0
value(2) = u;
isterminal(2) = 0;
direction(2) = -1;

end
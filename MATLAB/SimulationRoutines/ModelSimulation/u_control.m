function [u] = u_control(t,z,p)
    % PWM: period T, duty cycle D, delay t_delay
    Tu = p(1);  
    Du = p(2);
    t_delay = 0; %delay is necessary because the solver ignores the first event u=1 if it starts at t=0

    if mod(t-t_delay,Tu) < Du*Tu
        u = 1;
    else
        u = 0;
    end
end

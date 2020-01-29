function y=w_function(x, theta_inducer, eta_inducer, eta_protein )
%w_function evaluates the value of the w function for the average model
%   x is the concentration of the inducer
%   theta_inducer, eta_inducer and eta_protein could be:
%   theta_atc eta_atc eta_tetr 
%   or
%   theta_iptg eta_iptg eta_laci
    theta=1/theta_inducer;
    y=1./(1+(theta.*x).^eta_inducer).^eta_protein;
end
function [ output_args ] = hill_func(x,k,n) 
output_args = 1./(1+(x./k).^n);
end


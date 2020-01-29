classdef MPCControlGA < handle
    %MPCControl define the behaviour of the MPC controller
    %   Detailed explanation goes here
    
    properties
        Tp = 0;     %Prediction Horizon
        Tc = 0;     %Control Horizon
        setp = 0;   %Setpoint of the Controller
        period = 0; %Period of the PWM
        costf = 0;  %Cost Function
        DutyC = 0;  %Store the last value of the DutyCycle
        Dref = 0;   %Dref
        opts=[];    %solver options
        MG=0;       %max number of generations
        popsize=1;  %population size
        maxstall=0; %max number of stall generations
        iptgamp=0;  %amplitude of the iptg wave
        atcamp=0;   %amplitude of the atc wave
    end
    
    methods
        function obj = MPCControlGA(varargin)
            if nargin >= 1
                obj.Tp = varargin{1};
            end
            if nargin >= 2
                obj.Tc = varargin{2};
            end
            if nargin >= 3
                obj.setp = varargin{3};
            end
            if nargin >= 4
                obj.Dref = varargin{4};
            end
            if nargin >= 5
                obj.MG = varargin{5};
            end
            if nargin >= 6
                obj.popsize = varargin{6};
            end
            if nargin >= 7
                obj.maxstall = varargin{7};
                obj.opts=optimoptions('ga','MaxGenerations',obj.MG,'InitialPopulationRange',...
                        [0; obj.Dref],'PopulationSize',obj.popsize,'Display', 'iter',...
                        'UseParallel', true, 'MaxStallGenerations',obj.maxstall);                
            end
            if nargin >= 9
                obj.atcamp = varargin{8};
                obj.iptgamp = varargin{9};
            end
            if nargin >= 10
                obj.period = varargin{10};
            end
        end
        
      function [DC] = decision_ev(obj, LacI, TetR, LacImRNA, TetRmRNA, atc_del, iptg_del, curr_tp, Ts)   
            if mod(curr_tp,Ts)==0
            disp('Running Optimization');
            [DCopt]=ga(@(x)runPrediction_ev(x,...
                                [atc_del iptg_del LacImRNA TetRmRNA LacI TetR].',...
                                [obj.atcamp obj.iptgamp obj.period 1],obj.setp),obj.Tp,...
                                [],[],[],[],zeros(obj.Tp,1),...
                                ones(obj.Tp,1),[],obj.opts);
            obj.DutyC=DCopt(1:obj.Tc);
            end
            DC=obj.DutyC(1);
        end  
    end
end


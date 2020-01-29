classdef SquareWave < handle
    properties
        tstep = 1;
        T = 100;
        idelay = 0; % In minutes
        mode = 'Direct';
        time = 0;
        
    end
    
    methods
        function obj = SquareWave(varargin)
            if nargin >= 1
                obj.tstep = varargin{1};
            end
            if nargin >= 2
                obj.T = varargin{2};
            end
            if nargin >= 3
                obj.idelay = varargin{3};
            end
            if nargin >= 4
                obj.mode = varargin{4};
            end
        end
        
        function decision_input = decision(obj, D, amplitude)
            if obj.time< D * obj.T 
                if strcmp(obj.mode, 'Direct')
                    decision_input = amplitude;
                else
                    decision_input = 0;
                end
                
            else
                if strcmp(obj.mode, 'Reverse') 
                    decision_input = amplitude;
                else
                    decision_input = 0;
                end
            end
            obj.time = obj.time + obj.tstep;
            obj.time = mod(obj.time,obj.T);
        end
        
    end
    
end
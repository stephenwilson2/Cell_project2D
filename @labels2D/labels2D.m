classdef labels2D    
    %LABELS2D Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess=private)
        pts
        flpts
    end
    
    methods
        function obj = labels2D(cell,varargin)
	    c=varargin;
            if isa(c,'labels2D')
                obj.flpts=c.flpts;
            else
                obj.pts=cell.pts;
                obj=onetoone(obj);
            end
        end %constructor
        
        function obj = onetoone(obj)
            obj.flpts=obj.pts;
        end
    end
    
end


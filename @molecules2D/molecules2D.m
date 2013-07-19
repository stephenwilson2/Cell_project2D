classdef molecules2D
    %MOLECULES2D Constructs molecules for the onecell class
    %   Takes the onecell object and one of these:
	%      - An old molecules object
	%      - Number of molecules to add

    
    properties (SetAccess=private)
        numofmol=1 %Number of molecules
        x %X-coordinates of the molecules
        y %Y-coordinates of the molecules
    end %properties
    
    
    methods
       function obj = molecules2D(cell,c)
           %Constructs molecules for the onecell class
            if isa(c,'molecules2D')
                obj.x=c.x;
                obj.y=c.y;
            else
                obj.numofmol=c;
                obj.x=zeros(obj.numofmol,1);
                obj.y=zeros(obj.numofmol,1);
                obj=obj.addmolecules(cell);
            end
       end %constructor
       
       function obj = addmolecules(obj,cel)
           %Calculates random origins for the molecules
           a=1;
           b=cel.l*2;
           c=cel.r*2;
           obj.x=zeros(obj.numofmol,1);
           obj.y=zeros(obj.numofmol,1);
           for i=1:obj.numofmol
               obj.x(i)=a + (b-a).*rand(1);
               obj.y(i)=a + (c-a).*rand(1);
               
               while ~cel.incell(obj.x(i),obj.y(i))
                   obj.x(i)=a + (b-a).*rand(1);
                   obj.y(i)=a + (c-a).*rand(1);
               end
               if strcmp(cel.algo,'sc')
                   obj.x(i)=obj.x(i)-cel.ori(2);
                   obj.y(i)=obj.y(i)-cel.ori(1);
               else
                   obj.x(i)=obj.x(i)+cel.ori(2)-cel.l;
                   obj.y(i)=obj.y(i)+cel.ori(1)-cel.r;
               end
               
           end
       end  %addmolecules
    end %methods
    
end %classdef


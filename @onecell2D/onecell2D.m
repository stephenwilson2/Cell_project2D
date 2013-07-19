classdef onecell2D
    %onecell2D Creates one cell that can be manipulated.
    %Constructor:
    %Takes input for any of the following variables:
    %    - numofmol: the number of molecules to be added to the cell
    %    - r: The radius of the cell
    %    - l: The length of the cell (this is half the actual length)
    %    - algo: Selects for the type of cell to be used. Inputs are:
    %        - 'c': circle
    %        - 's': square (or rectangle)
    %        - 'sc': spherocylinder
    %    - pixelsize: Gives the size in nm^2 of the camerapixel
    %    - ori: States the origin of the cell in nm. 
    %        - 's' and 'c' cells are set to [r,l] by default
    %        - 'sc' cells are set to [0,0] by default
    %    - gopsf: If set to 1, the PSF is applied to the fluorophores. If set to 0, the PSF is not set
    %    - angle: Gives the angle to rotate the cell in degrees
    %
    %Variables:
    %User changeable variables are the same as those in the constructor and can be changed in the following manner:
    %    c=onecell2D();
    %    c.r=20;
    %The radius would then be 20 nm.
    %
    %The following variables are accessible to the user but cannot be directly changed:
    %    - mol: This stores the molecules object. There should be functions in onecell to manipulate the molecules object.
    %    - img: Stores the image matrix
    %    - pts: Stores the locations of the molecules as pairs of points
    %    - fl: Stores the locations of the fluorophores as pairs of points
    %    - cellmask: Stores an image of the cell's mask. Must be constructed with the cell_mask function
    %    - current: If 1, then the img, pts, and fl variables are up-to-date. If 0,  one of onecell's refresh functions need to be used
    %
    %Functions:
    %addMolecules (int): Adds a given integer number molecules to the cell
    %applyPSF ():  Applies the PSF and creates onecell's img
    %cell_mask(): Creates a cell mask stored under onecell as cellmask
    %imagesc(onecell): Specifies the way that imagesc displays the onecell object. Uses a color bar and labels
    %imshow(onecell): Specifies the way that imshow displays the onecell object
    %incell(double x, double y):  Checks to see if point [x,y] is in the cell
    %label(): Labels the molecules with flurophores
    %Onecell(varargin): onecell's constructor 
    %plot(onecell): Specifies the way that plot displays the onecell object. When plotted the fluorophores are 
    %             plotted so that they could be overlaid onto a cell
    %refresh_all(): Refreshes the entire cell; Used if the molecules or fluorophores were changed
    %refresh_cell(): Refreshes everything but does not get new positions for the molecules or change the 
    %                number of molecules. Used if anything but the molecules was changed
    %rotate(): Rotates the cell according to onecell's angle

    properties
        r=250; % The radius of the cell
        l=1000; % The length of the cell (this is half the actual length)
        numofmol=10; %The number of molecules to be added to the cell
        angle=0; %Gives the angle to rotate the cell in degrees
        algo='sc'; %Selects for the type of cell to be used. Inputs are: - 'c': circle - 's': square (or rectangle)- 'sc': spherocylinder
        ori %States the origin of the cell in nm. - 's' and 'c' cells are set to [r,l] by default - 'sc' cells are set to [0,0] by default
        pixelsize=64;%Gives the size in nm^2 of the camerapixel
        gopsf=1;%If set to 1, the PSF is applied to the fluorophores. If set to 0, the PSF is not set
    end
    
    properties (SetAccess=private)
        mol %This stores the molecules object. There should be functions in onecell to manipulate the molecules object.
        img=[]; %Stores the image matrix
        pts=[]; %Stores the locations of the molecules as pairs of points
        fl=[]; %Stores the locations of the fluorophores as pairs of points
        cellmask=[]; %Stores an image of the cell's mask. Must be constructed with the cell_mask function
        current=1; %If 1, then the img, pts, and fl variables are up-to-date. If 0,  one of onecell's refresh functions need to be used
    end
    
    properties(SetAccess=private,GetAccess=private)
       oldr
       oldl
       oldpixelsize
       oldori
    end
    
    % Class methods
    methods
        function obj = onecell2D(varargin)
            % Sets defaults for optional inputs in order: numofmol,r,l,algo,pixelsize,ori,gopsf,angle
            optargs = {obj.numofmol,obj.r,obj.l,obj.algo,obj.pixelsize,obj.ori,obj.gopsf,obj.angle};
            
            % Checks to ensure 8 optional inputs at most
            numvarargs = length(varargin);
            if numvarargs > 8
                error('Takes at most 8 optional inputs');
            end
            
            % Overwrites defaults if optional input exists
            optargs(1:numvarargs) = varargin;
            obj.numofmol= cell2mat(optargs(1));
            obj.r = cell2mat(optargs(2));
            obj.l = cell2mat(optargs(3));
            obj.algo = cell2mat(optargs(4));
            obj.pixelsize = cell2mat(optargs(5));
            if isempty(cell2mat(optargs(6)))
                obj.ori = [obj.r,obj.l];
            else
                obj.ori = cell2mat(optargs(6));
            end
            obj.gopsf = cell2mat(optargs(7));
            obj.angle = cell2mat(optargs(8));
            
            % Construct a onccell object
            if obj.algo=='c'
                obj.l=obj.r;
            elseif strcmp(obj.algo,'sc')
                obj.ori=obj.ori-[obj.r,obj.l];
                obj.l=obj.l*2;
                
            end
            
            if strcmp(obj.algo,'sc') && obj.l<obj.r*3
                error('Spherocylinders need to be long... Increase the length of the cell to at least 3 times the length.');
            end
            obj=obj.addMolecules(obj.numofmol);
            obj=refresh_all(obj);
        end %onecell
        
        function obj=refresh_all(obj)
            %refresh_all Refreshes the entire cell; Used if the molecules
            %were changed. Not automated because refreshing takes a
            %significant amount of time
            obj=label(obj);
            if obj.gopsf==1
                if strcmp(obj.algo,'sc')
                    obj.l=obj.l/2;
                    obj=applyPSF(obj);
                    obj.l=obj.l*2;
                else
                    obj=applyPSF(obj);
                end                
            end
            obj=rotate(obj);
            obj.oldr=obj.r;
            obj.oldl=obj.l;
            obj.oldori=obj.ori;
            obj.current=1;
        end %refresh_all
        
        function obj=refresh_cell(obj)
            %refresh_all Refreshes everything but does not get new positions for the molecules or change the 
            %number of molecules. Used if anything but the molecules was
            %changed. Not automated because refreshing takes a
            %significant amount of time
            f1=(obj.r-obj.oldr)+(obj.ori(1)-obj.oldori(1));
            f2=(obj.l-obj.oldl)+(obj.ori(2)-obj.oldori(2));
            obj.pts(:,1)=obj.pts(:,1)+f1;
            obj.pts(:,2)=obj.pts(:,2)+f2;
            obj=label(obj);
            if obj.gopsf==1
                if strcmp(obj.algo,'sc')
                    obj.l=obj.l/2;
                    obj=applyPSF(obj);
                    obj.l=obj.l*2;
                else
                    obj=applyPSF(obj);
                end                
            end
            obj=rotate(obj);
            obj.oldr=obj.r;
            obj.oldl=obj.l;
            obj.oldori=obj.ori;
            obj.current=1;
        end %refresh_cell
        
        %set information about the cell
        function obj = set.ori(obj,val)
            obj.oldori=obj.ori;
            if ~isa(val,'double')
                error('Origin must be of class double')
            end
            obj.ori(1)=val(1);
            obj.ori(2)=val(2);
            obj.current=0; %#ok<*MCSUP>
           
        end % set.ori
        function obj = set.r(obj,val)
            obj.oldr=obj.r;
            if ~isa(val,'double')
                error('Radius must be of class double')
            end
            obj.r = val;
            obj.current=0;

        end % set.r
        function obj = set.pixelsize(obj,val)
            obj.oldpixelsize=obj.pixelsize;
            if ~isa(val,'double')
                error('pixelsize must be of class double')
            end
            obj.pixelsize = val;
            obj.current=0;
        end % set.pixelsize
        function obj = set.numofmol(obj,val)
            if ~isa(val,'double')
                error('numofmol must be of class double')
            end
            obj.numofmol = val;
            obj.current=0;
        end % set.numofmol
        function obj = set.l(obj,val)
            obj.oldl=obj.l;
            if ~isa(val,'double')
                error('Length must be of class double')
            end
            obj.l = val;
            obj.current=0;
        end % set.l
        function obj = set.angle(obj,val)
            if ~isa(val,'double')
                error('Angle must be of class double')
            end
            obj.angle = val;
            obj.current=0;
        end % set.angle
                
        function obj = check(obj)
            % check Checks to see if the cell needs to be refreshed
            if obj.current==0;
                reply = input('Cell not current, refresh cell? Y/N [Y]: ', 's');
                if isempty(reply)
                    reply = 'Y';
                end
                if strcmpi(reply,'Y')
                    obj=obj.refresh_cell();
                    obj.current
                end
            end
        end
        
        %get information about the cell
        function val = get.l(obj)
            val=obj.l;
        end % get.l
        function val = get.r(obj)
            val=obj.r;
        end % get.r
        function val = get.angle(obj)
            val=obj.angle;
        end % get.angle
        function val = get.ori(obj)
            val=obj.ori;
        end % get.ori
        
        function val = incell(obj,x,y)
            %INCELL Checks to see if point [x,y] is in the cell
            %the cell or not.
            %It returns a 0 if it is not and a 1 if it is.
            if strcmp(obj.algo,'s')
                X=asin((x)/obj.r);
                Y=acos((y)/obj.l);
                if isreal(X) || isreal(Y)
                    val=1;
                else
                    val=0;
                end
            elseif strcmp(obj.algo,'c')
                 X=asin((abs(x-obj.r)^2+abs(y-obj.r)^2)^0.5/obj.r);
                 if isreal(X)
                    val=1;
                else
                    val=0;
                 end
            elseif strcmp(obj.algo,'sc')
                X=asin((abs(x-obj.r)^2+abs(y-obj.r)^2)^0.5/obj.r);%the circle closer at r
                Y=asin((abs(x-obj.l+obj.r)^2+abs(y-obj.r)^2)^0.5/obj.r);%the cirlce l-r
                X1=(asin((x-obj.r)/(obj.l-obj.r*2)))^0.5;
                Y2=(acos((y-obj.l-obj.r)/(2*obj.r))^0.5);
                if (isreal(X) || isreal(Y))||(isreal(X1) || isreal(Y2))
                    val=1;
                else
                    val=0;
                end
            end
            
        end %incell(x,y)
        
        %Adjusts or adds to the cell
        function obj = addMolecules(obj,val)
            %addMolecules Adds a given integer number molecules to the cell
            obj.numofmol=val;
            obj.mol=molecules2D(obj,val);
            obj.pts=[obj.mol.x obj.mol.y];
            obj=refresh_all(obj);
        end
        function obj = label(obj)
            % label Labels the molecules with flurophores
            tmp=labels2D(obj,obj.mol);
            obj.fl=tmp.flpts;
            obj.current=0;
        end
        function obj = applyPSF(obj)
            %applyPSF Applies the PSF and creates onecell's img
            obj.img=psf2D(obj,obj.pixelsize).img;
            obj.current=0;
%             obj.img
        end
        function obj = rotate(obj)
            if ~isempty(obj.img)
                obj.img=imrotate(obj.img, obj.angle);
            else
                disp('Not rotating, because there is no image to rotate')
            end
            
        end
        function obj = cell_mask(obj)
            %cell_mask Creates a cell mask stored under onecell as cellmask
            if strcmp(obj.algo,'sc')
                obj.cellmask=zeros(round(obj.l/obj.pixelsize),round(obj.r*2/obj.pixelsize)/2);
                tmpl=obj.l/2;
                
            else
                error('Only Spherocylinders currently supported')
            end
            pt=[];
            for x=1:1:obj.r
                for y=1:1:obj.r
                    X=asin((abs(x-obj.r)^2+abs(y-obj.r)^2)^0.5/obj.r);%the circle closer at r
                    Y=asin((abs(x-obj.l+obj.r)^2+abs(y-obj.r)^2)^0.5/obj.r);%the cirlce at l-r
                    X1=(asin((x-obj.r)/(obj.l-obj.r*2)))^0.5;
                    Y2=(acos((y-obj.l-obj.r)/(2*obj.r))^0.5);
                    if (isreal(X) || isreal(Y))||(isreal(X1) || isreal(Y2))
                        pt=[pt;[x y]];
                    end
                end
            end
            x=pt(:,1);y=pt(:,2);
            mx=obj.r+1:obj.l-obj.r;
            x=[x;(x+obj.l-obj.r);mx';mx'];
            my=zeros(obj.l-2*obj.r,1);
            my(:)=obj.r;
            my2=ones(obj.l-2*obj.r,1);

            y=[y;flipud(y);my2;my];
            
            for i=1:length(x)
                obj.cellmask(ceil(x(i)/obj.pixelsize),ceil(y(i)/obj.pixelsize))=1;
            end
            tmp=obj.cellmask;
            
            obj.cellmask=zeros(round(obj.l/obj.pixelsize),round(obj.r*2/obj.pixelsize));
            obj.cellmask(1:size(tmp,1),1:size(tmp,2))=tmp;
            obj.cellmask(1:size(tmp,1),size(tmp,2)+1:2*size(tmp,2))=fliplr(tmp);
            obj.cellmask=imfill(obj.cellmask,8,'holes');
            
        end

        %Show the cell
        function obj=imshow(obj)
            % IMSHOW Specifies the way that imshow displays the onecell object
            obj=check(obj);
            if isempty(obj.img)
                plot(obj.fl(:,1),obj.fl(:,2),'o');axis equal;axis tight;
            else
               imshow(mat2gray(flipud(obj.img')));axis equal;axis tight;
               if obj.current==1
                   r=obj.r; %#ok<*PROP>
                   l=obj.l;
                   px=obj.pixelsize;
               else
                   px=obj.oldpixelsize;
                   r=obj.oldr;
                   l=obj.oldl;
               end
               title(sprintf('%i molecules in a %i nm by %i nm \nResolution: %i nm^2 / pixel',obj.numofmol,r*2,l,px),'FontWeight','bold');
            end
        end %imshow
        function obj=imagesc(obj)
            % IMAGESC Specifies the way that imagesc displays the onecell object. Uses a color bar and labels
            obj=check(obj);
            if isempty(obj.img)
                plot(obj.fl(:,1),obj.fl(:,2),'o');
            else
               imagesc(obj.img');colormap('gray');colorbar; axis equal;axis tight;
               if obj.current==1
                   r=obj.r; %#ok<*PROP>
                   l=obj.l;
                   px=obj.pixelsize;
               else
                   px=obj.oldpixelsize;
                   r=obj.oldr;
                   l=obj.oldl;
               end
%                xlabel(sprintf('One pixel = %i^2 nm',px));
%                ylabel(sprintf('One pixel = %i^2 nm',px));
               title(sprintf('%i molecules in a %i nm by %i nm cell \nResolution: %i nm^2 / pixel',obj.numofmol,r*2,l,px),'FontWeight','bold');
            end
        end %imagesc
        function obj=plot(obj)
            % PLOT  Specifies the way that plot displays the onecell object. When plotted the fluorophores are plotted so that they could be overlaid onto a cell
 
            %             (obj.fl(:,1)-obj.ori(1))-(1-cos(obj.angle*pi/180))
            obj=check(obj);
            if obj.current==1
                r=obj.r; %#ok<*PROP>
                l=obj.l;
                px=obj.pixelsize;
            else
                px=obj.oldpixelsize;
                r=obj.oldr;
                l=obj.oldl;
            end
            if isempty(obj.img)
                if strcmp(obj.algo,'sc')
                    plot(obj.fl(:,1)/px,obj.fl(:,2)/px,'o');axis equal;axis tight;
                else
                    plot(obj.fl(:,1)/px,obj.fl(:,2)/px,'o');axis equal;axis tight;
                end
            else
                if strcmp(obj.algo,'sc')
                    plot(obj.fl(:,1)/px+l/2/px*.3,obj.fl(:,2)/px+r/2/px*.3,'o');axis equal;axis tight;
                else
                    plot(obj.fl(:,1)/px+l/px*.3,obj.fl(:,2)/px+r/px*.3,'o');axis equal;axis tight;
                end
            end
        end % plot
        
    end % methods
end % classdef
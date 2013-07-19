classdef psf2D
    %PSF2D Summary of this class goes here
    %   Takes the onecell object and two optional arguments: 
	%     - the pixel size of the camera 
	%     - the wavelength of the emission light

    
    
    properties (SetAccess=private)
        emwave=520; %nm
        sigma
        img=[]
        fl
        pxsz=10;
    end
    
    methods (Static)
        function f = gaussDistribution(x, mu, s)
            p1 = -.5 * ((x - mu)/s) .^ 2;
            p2 = (s * sqrt(2*pi));
            f = exp(p1) ./ p2;
        end
    end %Static methods
    
    methods
        function obj = psf2D(cell,varargin)
            c=varargin;
            if isa(c,'psf2D')
                obj.emwave=c.emwave;
                obj.sigma=c.sigma;
                obj.img=c.img;
                obj.fl=c.fl;
                obj.pxsz=c.pxsz;
            else
                optargs = {obj.pxsz,obj.emwave};
                % Checks to ensure 2 optional inputs at most
                numvarargs = length(c);
                if numvarargs > 2
                    error('Takes at most 2 optional inputs');
                end
                % Overwrites defaults if optional input exists
                optargs(1:numvarargs) = c;
                obj.pxsz= cell2mat(optargs(1));
                obj.emwave= cell2mat(optargs(2));
                
                obj=calcsig(obj);
                obj.fl=cell.fl;
                obj=obj.applyPSF(cell);
            end
        end %constructor
        
        function obj = calcsig(obj)
            n=1.515; %refractive index for immersion oil
            NA=1.4; %numerical apperature
            a=asin(NA/n);
            k=(2*pi/obj.emwave);
            
            num=4-7*power(cos(a),3/2)+3*power(cos(a),7/2);
            de=7*(1-power(cos(a),3/2));
            obj.sigma=1/n/k*power(num/de,-0.5);
        end %calcsig
        
        function obj = applyPSF(obj,cel)
            obj.img=zeros(round(cel.l*2/obj.pxsz*1.3),round(cel.r*2/obj.pxsz*1.3));%creates blank matrix of the camera pixel size
            obj.fl=obj.fl/obj.pxsz; %Scales the pts of fluorescence
            obj.fl(:,1)=obj.fl(:,1)+cel.l/obj.pxsz*.3;
            obj.fl(:,2)=obj.fl(:,2)+cel.r/obj.pxsz*.3;
            for i=1:size(obj.fl,1)
                tmp=zeros(round(cel.l*2/obj.pxsz*1.3),round(cel.r*2/obj.pxsz*1.3));
                mu=obj.fl(i,1);
                y=ceil(obj.fl(i,2));
                if y>size(obj.img,2)
                    y=y-1;
                end
                for x=1:size(obj.img,1)
                    tmp(x,y)=tmp(x,y)+...
                        (gaussDistribution(x,mu,obj.sigma/obj.pxsz));
                end
                for h=1:size(obj.img,1)
                    o=1:size(obj.img,2);
                    obj.img(h,:)=obj.img(h,:)+...
                            (gaussDistribution(o,obj.fl(i,2),obj.sigma/obj.pxsz)*sum(tmp(h,:)));
                end
            end

        end %applyPSF
               
    end %methods
    
end


function processold()
    clear all;
    close all;
    load('TestClumping_64_sc.mat')
    cel=cell(15,1);
    for o=1:15
        cel{o}=zeros(11,42);
    end
    n=0;
    x=size(alldata,2)/5;
    y=size(alldata,1)/3;
    for h=1:3
        for l=1:5
            n=n+1;
            xpts=ceil([x*(l-1),x*l]);
            xpts(xpts==0)=1;
            
            ypts=ceil([y*(h-1),y*h]);
            ypts(ypts==0)=1;
            dat=alldata(ypts(1)+28:ypts(2)-3,xpts(1)+5:xpts(2));
            cel{n}(1:size(dat,1),1:size(dat,2))=dat;
        end
    end

    tmpcel=cell(15,1);
    n=0;
    for o=1:3
        for i=0:4
            n=n+1;
            tmpcel{o+3*i}=cel{n};
        end
    end
    cel=tmpcel;
    num={25,25,25,50,50,50,75,75,75,100,100,100,125,125,125};
    for i=1:length(cel)
            subplot(5,3,i)
            imagesc(cel{i}); axis equal; colormap gray; colorbar;
            axis tight;
%             xlabel(sprintf('One pixel = %i^2 nm',64));
%             ylabel(sprintf('One pixel = %i^2 nm',64));
            title(sprintf('%i molecules in a %i nm by %i nm cell\nResolution: %i nm^2 / pixel',num{i},500,1000,64),'FontWeight','bold');
    end
    saveas(gcf,'test_helices_old.fig')
end
close all;
clear all;
c=onecell(1,250,1000,'sc',64,[250 1000],1,0);
% c.pixelsize=10;
% c=c.refresh_cell();

figure(15);
hold all;
imagesc(c);axis equal; plot(c); axis equal;
% legend(sprintf('One flurophore has an area of: %d',sum(sum(c.img))));
hold off;
c
close all;
clear all;
c=onecell(1,250,1000,'sc',64,[250 1000],1,0);

figure(15);
hold all;
imagesc(c);axis equal; plot(c); axis equal;
legend(sprintf('One flurophore has an area of: %d',sum(sum(c.img))));
hold off;
title('Gaussian Analysis of One Flurophore',...
    'FontWeight','bold')

saveas(gcf,'test_OneFluorophore.fig')
figure(16)
hold all;
plot(c.img(:,round(c.pts(2)/c.pixelsize)));ylabel('Intensity');
x=1:3:size(c.img,1);
mu=c.fl(1)/c.pixelsize+c.l/2/c.pixelsize*.3;
emwave=520;
n=1.515; %refractive index for immersion oil
NA=1.4; %numerical apperature
a=asin(NA/n);
k=(2*pi/emwave);
num=4-7*power(cos(a),3/2)+3*power(cos(a),7/2);
de=7*(1-power(cos(a),3/2));
s=1/n/k*power(num/de,-0.5)/c.pixelsize;

p1 = -.5 * ((x - mu)/s) .^ 2;
p2 = (s * sqrt(2*pi));
f = exp(p1) ./ p2;

plot(x,f.^2,'-r')
legend('Simulation','Theoretical Gaussian')
xlabel('64 nm/1 pixel Resolution'); title('Cross-section of PSF','FontWeight','bold');
hold off;
saveas(gcf,'CrosssectionofPSF.fig')
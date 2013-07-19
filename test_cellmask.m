function test_cellmask()
clear all;
close all;
c=onecell(10,250,1000,'sc',10);
c=c.cell_mask();

figure(1);
subplot(2,1,1)
imagesc(c);
subplot(2,1,2)
tmp=zeros(size(c.img));
[r,cl,v]=find(c.cellmask);
r=round(r+(size(c.img,1)-size(c.cellmask,1))/2);
cl=round(cl+(size(c.img,2)-size(c.cellmask,2))/2);
for i=1:length(v)
    tmp(r(i),cl(i))=v(i);
end
imagesc(tmp');colorbar
end
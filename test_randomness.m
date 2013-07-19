function test_randomness()
    clear all;
    close all;
    if ~isequal(exist('test_randomness.mat','file'),2)
        datapts=200;
        molpcell=100;
        r=250;
        w=1000;
        c=cell(datapts,1);
        x=[];
        y=[];
        for i=1:datapts
            c{i}=onecell(molpcell,r,w,'sc',10,[250 1000],1,0);
            x=[x; c{i}.pts(:,1)/10];
            y=[y; c{i}.pts(:,2)/10];
        end
        c{1}=c{1}.cell_mask();
        save('test_randomness')
    else
        load('test_randomness')
    end
    analyze(x,y,c)
end


function analyze(molx,moly,cells)

bin1=cells{1}.l/10;
bin2=cells{1}.r*2/10;
expect=[];
figure(1);
[f2,x2]=hist(molx,1:1:bin1);
bar(x2*10,f2*10/trapz(x2,f2))
hold on;
molx=sort(molx);
expect=zeros(length(molx),1);

for w=1:length(molx)
    expect(w)=...
        (sum(cells{1}.cellmask(ceil(molx(w)),:)/sum(sum(cells{1}.cellmask))));
end
whos molx;
whos expect;

expect=[molx *10,expect*10];
plot(expect(:,1),expect(:,2),'color','red')
hold off;
title('Distribution of a Large Number of Randomly Chosen X-values',... 
  'FontWeight','bold')
xlabel('X (nm), Resolution 10nm/pixel')
ylabel('Probability')
saveas(gcf, 'testhistmolx.fig')

expect=[];
figure(2);
[f3,x3]=hist(moly,1:1:bin2);
bar(x3*10,f3*10/trapz(x3,f3))
hold on;
moly=sort(moly);
expect=zeros(length(moly),1);

for w=1:length(moly)
    expect(w)=(sum(cells{1}.cellmask(:,ceil(moly(w)))/sum(sum(cells{1}.cellmask))));
end

expect=[moly *10,expect*10];
plot(expect(:,1),expect(:,2),'color','red')
hold off;
title('Distribution of a Large Number of Randomly Chosen Y-values',... 
  'FontWeight','bold')
xlabel('Y (nm), Resolution 10nm/pixel')
ylabel('Probability')
saveas(gcf, 'testhistmoly.fig')


end
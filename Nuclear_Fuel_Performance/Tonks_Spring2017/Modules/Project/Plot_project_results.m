%This file plots the various project results
clear
close all
clrs = colormap('lines');

%Case 1
fname_1p5d = '1.5D/1p5D_case1.csv';
fname_2dsm = '2Dsmeared/2Dsmeared_case1.csv';
fname_2dd = 'case1_out.csv';

M1p5d = csvread(fname_1p5d);
plot(M1p5d(1,:)/3600,M1p5d(2,:),'linewidth',1.5)
hold on

M2dsm = csvread(fname_2dsm);
plot(M2dsm(1,:)/3600,M2dsm(2,:),'linewidth',1.5)

dmp = importdata(fname_2dd);
M2dd = dmp.data(:,1:2)';
plot(M2dd(1,:)/3600,M2dd(2,:),'linewidth',1.5)

T0 = 1.5624e+03;
plot([0 4],[T0 T0],'k--','linewidth',1.5)
set(gca,'fontsize',18)
xlabel('time (hrs)')
ylabel('Max temperature (K)')
legend('1.5D','2D smeared','2D discrete','Analytical','location','southeast')
legend boxoff


%Case 2
fname_1p5d = '1.5D/1p5D_case2.csv';
fname_2dsm = '2Dsmeared/2Dsmeared_case2.csv';
fname_2dd = 'case_2_marina.csv';

figure
M1p5d = csvread(fname_1p5d);
p1=plot(M1p5d(1,:)/3600,M1p5d(2,:),M1p5d(1,:)/3600,M1p5d(3,:),'--','linewidth',1.5,'color',clrs(1,:));
hold on

M2dsm = csvread(fname_2dsm);
p2=plot(M2dsm(1,:)/3600,M2dsm(2,:),M2dsm(1,:)/3600,M2dsm(3,:),'--','linewidth',1.5,'color',clrs(2,:));

%dmp = importdata(fname_2dd);
dmp = csvread(fname_2dd);
%M2dd = dmp(:,1:3)';
M2dd = dmp(:,[1,5,6])';
p3=plot(M2dd(1,:)/3600,M2dd(2,:),M2dd(1,:)/3600,M2dd(3,:),'--','linewidth',1.5,'color',clrs(3,:));

set(gca,'fontsize',18)
xlabel('time (hrs)')
ylabel('Temperature (K)')
legend([p1(1),p2(1),p3(1)],'1.5D','2D smeared','2D discrete','location','east')
legend boxoff
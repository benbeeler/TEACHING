%Nuclear Engineer jobs
clear;
close all;

salaryBS = 70000;
salaryMS = 82000;
salaryPhD = 92000;

raise = 1.03;
yrs = 0:30;
raises = raise.^yrs;

earningsBS = salaryBS*cumsum(raises);
earningsMS = [0,0,salaryMS*cumsum(raises(1:end-2))];
earningsPhD = [0,0,0,0,salaryPhD*cumsum(raises(1:end-4))];

plot(yrs,[earningsBS;earningsMS;earningsPhD],'linewidth',1.5)
set(gcf,'units','inches','position',[1,1,6,4])
set(gca,'fontsize',18)
xlabel('Time (years)')
ylabel('Total earnings ($)')
grid on
legend('B.S.','M.S.','Ph.D.','location','northwest')
legend boxoff
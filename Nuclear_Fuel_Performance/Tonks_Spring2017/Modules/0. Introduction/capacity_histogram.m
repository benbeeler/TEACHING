clear
close all

fname = 'nameplate_capacity_US_reactors.csv'; 

capacity = csvread(fname); %In MWe

histogram(capacity,8)
set(gcf,'units','inches','position',[1,1,6,4])
set(gca,'fontsize',18)
xlabel('US reactor capacity (MWe)')
ylabel('Number of reactors')
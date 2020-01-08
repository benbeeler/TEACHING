
clear;
close all;

Tcoolin = 570;
LHR0 = 150;
hcool = 2.5;
Rf = 0.5;
dc = 0.06;
dg = 30e-4;
kc = 0.17;
k = 0.03;
Z0 = 150;
z = 1:2*Z0;
gamma = 1.3;
mdot = 0.25;% kg/s-rod; 
Cpw = 4200;% J/kg-K 


LHR = LHR0*cos(pi/(2*gamma)*(z/Z0-1));
figure(1)
set(gcf,'units','inches','position',[1,1,6,2])
plot(z,LHR,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('z (cm)')
ylabel('LHR (W/cm)')

Tcool = Tcoolin + 2*gamma/pi*Z0*LHR0/(mdot*Cpw)*(sin(pi/(2*gamma))+sin(pi/(2*gamma)*(z/Z0-1)));
figure(2)
set(gcf,'units','inches','position',[1,1,6,2])
plot(z,Tcool,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('z (cm)')
ylabel('T_{cool} (K)')
axis tight

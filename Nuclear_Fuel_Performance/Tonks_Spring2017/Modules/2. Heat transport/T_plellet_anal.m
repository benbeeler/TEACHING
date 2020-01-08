%Temperature profile in the fuel
clear
close all

Tcool = 580;
LHR = 200;
hcool = 2.5;
Rf = 0.5;
dc = 0.06;
dg = 30e-4;
kc = 0.17;
k = 0.03;

TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
hgap = kHe/dg;
Ts = TCI + LHR/(2*pi*Rf*hgap);
T0 = Ts + LHR/(4*pi*k);

temps = [TCI,TCO,Tcool];

r = (0:10)/10*Rf;
Tf = LHR/(4*pi*k)*(1-r.^2./Rf.^2) + Ts;
temps = [Tf,temps];
r = [r,Rf+dg,Rf+dg+dc,Rf+dg+dc*4];

figure(1)
set(gcf,'units','inches','position',[1,1,6,4])
p(1) = plot(r,temps,'linewidth',2);
axis tight
xlabel('r (cm)')
ylabel('T (k)')
hold on
plot([Rf Rf],[min(temps), max(temps)],'k--')
plot([Rf+dg Rf+dg],[min(temps), max(temps)],'k--')
plot([Rf+dg+dc Rf+dg+dc],[min(temps), max(temps)],'k--')
set(gca,'fontsize',18)

kXe = 0.7e-6*TCI^0.79;
y = 0.3;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg
Ts = TCI + LHR/(2*pi*Rf*hgap);
T0 = Ts + LHR/(4*pi*k)
r = (0:10)/10*Rf;
Tf = LHR/(4*pi*k)*(1-r.^2./Rf.^2) + Ts;
r = [r,Rf+dg,Rf+dg+dc,Rf+dg+dc*4];

temps = [Tf,TCI,TCO,Tcool];

p(2) = plot(r,temps,'linewidth',2);
plot([Rf Rf],[min(temps), max(temps)],'k--')
plot([Rf+dg Rf+dg],[min(temps), max(temps)],'k--')
plot([Rf+dg+dc Rf+dg+dc],[min(temps), max(temps)],'k--')
legend(p,'0% Xe in gap','30% Xe in gap','location','southwest')
legend boxoff

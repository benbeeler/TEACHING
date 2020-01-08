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
alphaf = 11.0e-6;
alphac = 7.1e-6;
Tfab = 373;

TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
hgap = kHe/dg;
Ts = TCI + LHR/(2*pi*Rf*hgap);
T0 = Ts + LHR/(4*pi*k);

temps = [TCI,TCO,Tcool];

r = (0:10)/10*Rf;
Tf = LHR/(4*pi*k)*(1-r.^2./Rf.^2) + Ts;
temps_noexp = [Tf,temps];
rpl = [r,Rf+dg,Rf+dg+dc,Rf+dg+dc*4];

%Change in cladding thickness
Ri = Rf+dg;
Ro = Rf+dg+dc;
expC = alphac*mean([Ri,Ro])*(mean([TCI TCO])-Tfab)
ndg = dg;
i = 0;
fprintf(1,'%d, hgap = %f, dg = %g, Ts = %f, and T0 = %f\n',i, hgap, ndg, Ts, T0)
Ddg = 1;
while Ddg > 1e-6
    i = i+1;
    expf = alphaf*Rf*(mean([Ts T0])-Tfab);
    Dgap = expC-expf;
    odg = ndg;
    ndg = dg + Dgap;
    hgap = kHe/ndg;
    Ts = TCI + LHR/(2*pi*(Rf+expf)*hgap);
    T0 = Ts + LHR/(4*pi*k);
    fprintf(1,'%d, hgap = %f, dg = %g, Ts = %f, and T0 = %f\n',i, hgap, ndg, Ts, T0)
    Ddg = abs(odg - ndg)/odg;
end

temps = [TCI,TCO,Tcool];

r = (0:10)/10*Rf;
Tf = LHR/(4*pi*k)*(1-r.^2./Rf.^2) + Ts;
temps_exp = [Tf,temps];

figure(1)
set(gcf,'units','inches','position',[1,1,6,4])
plot(rpl,[temps_noexp; temps_exp],'linewidth',2);
axis tight
xlabel('r (cm)')
ylabel('T (k)')
hold on
plot([Rf Rf],[min(temps), max(temps)],'k--')
plot([Rf+dg Rf+dg],[min(temps), max(temps)],'k--')
plot([Rf+dg+dc Rf+dg+dc],[min(temps), max(temps)],'k--')
set(gca,'fontsize',18)
legend('No thermal expansion', 'Thermal expansion')
legend boxoff

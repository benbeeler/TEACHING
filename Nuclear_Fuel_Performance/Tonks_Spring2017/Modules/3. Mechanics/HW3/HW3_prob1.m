%Temperature profile in the fuel
clear
close all

Tcool = 600;
hcool = 2.5;
Rf = 0.5;
dc = 0.065;
dg = 30e-4;
kc = 0.17;
k = [0.38, 0.03, 0.25, 0.2, 0.23];
flux = 2.8e13;
q = 0.035;
MU = 235*q + 238*(1-q); %g U/mol
dU = [19.04, 9.65, 12.97, 13.52, 11.31];%g U/cm3
Na = 6.022e23; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
y = 0.10;
alpha_c = 7.1e-6;
alpha_f = [13.9, 11.0, 10.5, 7.5, 16]*1e-6;
Tfab = 300;

NU = q*Na*dU/MU; %atoms/cm3;

%Calculate linear heat rate
Q = Ef*NU*flux*crosssection;
LHR = pi*Rf^2*Q;

%Temperature calc
%Coolant
TCO = Tcool + LHR/(2*pi*Rf*hcool);
%Clad
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
%Gap
kHe = 16e-6*TCI.^0.79;
kXe = 0.7e-6*TCI.^0.79;
kgap  = kHe.^(1-y).*kXe.^y;
hgap = kgap/dg;
Ts = TCI + LHR./(2*pi*Rf*hgap);
ch_gap = alpha_c*(Rf+dg+dc/2)*(mean([TCO, TCI]) - Tfab);

%Pellet
T0 = Ts + LHR./(4*pi*k);
Dgap = 0;
%Iterate to close the gap
for i = 1:length(k)
    j = 0; chng = 1;
    fprintf(1,'%d, hgap = %f, dg = %g, Ts = %f, and T0 = %f\n',j, hgap(i), dg, Ts(i), T0(i))
    while chng > 1e-3
        j = j+1;
        ch_fuel = alpha_f(i)*Rf*(mean([Ts(i) T0(i)])-Tfab);
        old_Dgap = Dgap;
        Dgap = ch_gap - ch_fuel;
        ndg = dg + Dgap;
        if ndg < 1e-8
            ndg = 1e-8;
        end
        hgapi = kgap(i)/ndg;
        Ts(i) = TCI(i) + LHR(i)/(2*pi*(Rf+ch_fuel)*hgapi);
        T0(i) = Ts(i) + LHR(i)/(4*pi*k(i));
        fprintf(1,'%d, hgap = %f, dg = %g, Ts = %f, and T0 = %f\n',j, hgapi, ndg, Ts(i), T0(i))
        chng = abs(Dgap - old_Dgap)/abs(old_Dgap);
    end
    new_dg(i) = ndg;
end
r = (0:10)/10*Rf;
for i = 1:length(k)
    Tf(i,:) = LHR(i)./(4*pi*k(i))*(1-r.^2./Rf.^2) + Ts(i);
end
temps = [Tf,TCI',TCO',Tcool*ones(size(TCO'))];
r = [r,Rf+mean(new_dg),Rf+mean(new_dg)+dc,Rf+mean(new_dg)+dc*4];

figure(1)
set(gcf,'units','inches','position',[1,1,6,4])
plot(r,temps,'linewidth',2);
axis tight
xlabel('r (cm)')
ylabel('T (k)')
hold on
plot([Rf Rf],[min(temps(:)), max(temps(:))],'k--')
plot([Rf+dg Rf+dg],[min(temps(:)), max(temps(:))],'k--')
plot([Rf+dg+dc Rf+dg+dc],[min(temps(:)), max(temps(:))],'k--')
set(gca,'fontsize',18)
legend('Metal','UO_2','UC','UN','U_3Si_2');
legend boxoff
title('HW 2, problem 1')

figure
bar(new_dg*10)
set(gca,'fontsize',18,'xticklabel',{'Metal','UO_2','UC','UN','U_3Si_2'})
ylabel('Gap width (mm)')
title('Gap width')


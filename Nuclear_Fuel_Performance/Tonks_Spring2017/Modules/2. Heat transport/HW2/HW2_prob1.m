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
%Pellet
T0 = Ts + LHR./(4*pi*k);
r = (0:10)/10*Rf;
for i = 1:length(k)
Tf(i,:) = LHR(i)./(4*pi*k(i))*(1-r.^2./Rf.^2) + Ts(i);
end
temps = [Tf,TCI',TCO',Tcool*ones(size(TCO'))];
r = [r,Rf+dg,Rf+dg+dc,Rf+dg+dc*4];

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

%Problem 4
melting_temp = [1132 2865 2850 2860 1665]+273;
max_temp = melting_temp*0.7;
T_in = 570;
dT = max_temp - (T0-Tcool+T_in);
figure
bar(dT)
set(gca,'fontsize',18,'xticklabel',{'Metal','UO_2','UC','UN','U_3Si_2'})
ylabel('Max(T_{out} - T_{in})')
title('HW 2, problem 4')


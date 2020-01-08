close all; clc; clear all;
rho_U= [19.04, 9.65, 12.97, 13.52, 11.31];%g U/cm3
Na = 0.6022e24; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
flux = 2.8e13;
q = 0.035;
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*rho_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;
kf = [0.38, 0.03,  0.25, 0.2, 0.23];
Tmelt = [1132 2865 2850 2860 1665]+273;
Tlimit=Tmelt*0.7;

M=20;
Rf=0.5;
dr=Rf/M;
tc=0.065;
tg=30e-4;
kc=0.17;
hcool=2.5;
Tcool=600;
Tin=570;
Tco=Tcool+Q*Rf./(2*hcool);
Tci=Tco+Q*Rf*tc./(2*kc);
khe=16e-6*Tci.^0.79;
kxe=0.7e-6*Tci.^0.79;
y=0.1;
kgap=khe.^(1-y).*kxe.^y;
hgap=kgap/tg;
Ts=Tci+Q*Rf./(2*hgap);
To=Ts+Q*Rf^2./(4*kf);
dT = Tlimit - (To-Tcool+Tin);

figure;
bar(dT)
set(gca,'fontsize',12,'xticklabel',{'Metal','UO_2','UC','UN','U_3Si_2'})
ylabel('{\Delta}T_{max}')

%HW1 problem 1
clear;
close all;

flux = 2.8e13;
q = 0.035;
MU = 235*q + 238*(1-q); %g U/mol
dU = [19.04, 9.65, 12.97, 13.52, 11.31];%g U/cm3
Na = 6.022e23; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2

NU = q*Na*dU/MU; %atoms/cm3;

Q = Ef*NU*flux*crosssection;

pl=bar(Q);
set(gca,'fontsize',18,'xticklabel',{'Metal','UO_2','UC','UN','U_3Si_2'})
ylabel('Q (W/cm^3)')

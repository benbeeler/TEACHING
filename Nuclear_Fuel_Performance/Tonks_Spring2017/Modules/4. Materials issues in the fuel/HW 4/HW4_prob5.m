%Problem 5 from HW 4
clear;
close all;

Rf = 0.41; %m;
th_gap = 80.0e-4; %m;
th_clad = 0.57e-1; %m
Tk = 1200; %K
Tfab = 300;
Ts = 800;
Tcool = 580;
hcool = 2.5;
flux = 2.75e13; %neutrons/cm2s
q = 0.042;
MU = 238; %g U/mol
dU = 9.65;%g U/cm3
Na = 6.022e23; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
k = 0.03; %W/(cm K)
kc = 0.17;
trmp = 3600*3;
ttot = 24*3600*365*2+trmp;
alpha_f = 11e-6;
alpha_c = 7.1e-6;
rho = 10.97; %g/cm3cm3

tv_rmp = 0:10:trmp;
tv_armp = trmp:200:ttot;
tv = [tv_rmp, tv_armp];

NU = q*Na*dU/MU; %atoms/cm3;
Fdotmax = NU*flux*crosssection;
Fdot = [tv_rmp*Fdotmax/trmp,Fdotmax*ones(size(tv_armp))];
Q = Ef*Fdot;
LHR = Q*pi*Rf^2;

burnup_rmp = q*flux*crosssection/trmp/2*tv_rmp.^2;
burnup_armp = burnup_rmp(end) + q*flux*crosssection*(tv_armp-trmp);
burnup = [burnup_rmp,burnup_armp];
burnup = burnup*950;

Tc = Tk - 273.15;
Rf = 0.5*(1 + tanh((Tc-900)/150));
kpstart = 1./(9.592e-2 + 6.14e-3*burnup - 1.4e-5*burnup.^2 + (2.5e-4 - 1.81e-6*burnup).*Tc);
kpend = 1./(9.592e-2 + 2.6e-3*burnup + (2.5e-4 - 2.7e-7*burnup).*Tc);
kel1 = 1.32e-2*exp(1.88e-3*Tc);

k = (1 - Rf).*kpstart + Rf.*kpend + kel1;

plot(tv/(3600*24),k,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (hours)')
ylabel('Thermal conductivity (W/(m K))')
axis tight

%Part B
Ts = 800;
T0 = Ts + LHR./(4*pi*k*0.01);
figure
plot(tv/(3600*24),T0,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (hours)')
ylabel('Centerline temperature (K)')
axis tight

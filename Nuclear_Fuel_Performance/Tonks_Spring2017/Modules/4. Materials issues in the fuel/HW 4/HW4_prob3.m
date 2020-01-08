%Problem 3 from HW 4
clear;
close all;

%Input parameters
hfp = 11.9e-3; %m
hpl = 6e-3; %m
Rf = 0.41e-2; %m;
th_gap = 80.0e-6; %m;
th_clad = 0.57e-3; %m
n_pellets = 10;
P = 2e6; %Pa
Ti = 273;
Ts = 800;
R = 8.3144598; %J?mol?1?K-1
flux = 2.75e13;
q = 0.042;
MU = 238; %g U/mol
dU = 9.65;%g U/cm3
Na = 6.022e23; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
k = 0.03; %W/(cm K)
a = 10e-4; %grain size in cm


%Part A: Calculate number of moles of gas to get pressure
%Calculate gas volume
V_wpellets = n_pellets*hfp*(pi*(Rf + th_gap)^2 - pi*Rf^2);
V_plenum = hpl*pi*(Rf + th_gap)^2;
V = V_wpellets + V_plenum;

%Calculate number of moles
n = P*V/(R*Ti);

fprintf(1,'Part A: There are %6.2e moles of He in the fabricated rodlet \n',n)

%Part B: Derive an expression for average DT
fprintf(1,'Part B: av(DT) = LHR/(8 k pi)\n')

NU = q*Na*dU/MU; %atoms/cm3;
Fdot = NU*flux*crosssection;
Q = Ef*Fdot;
LHR = Q*pi*(Rf*100)^2;
avDT = LHR/(8*k*pi);
avT = Ts + avDT;
fprintf(1,'Part B: The average DT = %6.1f K and the average T = %6.1f K \n',avDT, avT)

%Part C: 
trmp = 3600*3;
ttot = 24*3600;
y = 0.3;
tv_rmp = 0:10:trmp;
gas_rmp = Fdot*y/trmp/2*tv_rmp.^2;
tv_armp = trmp:10:ttot;
gas_armp = gas_rmp(end) + y*Fdot*(tv_armp-trmp);

tv = [tv_rmp, tv_armp];
gasdens_tot = [gas_rmp, gas_armp]/Na;
vol = (pi*(Rf*100)^2*n_pellets*hfp*100);
gas_tot = gasdens_tot*vol;

figure
plot(tv/3600, gas_tot,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (hours)')
ylabel('Fission gas produced (moles)')

%Part D:
kb = 8.6173324e-5; %eV/K
ttot = 24*3600*365*2;
tv_armp = trmp:200:ttot;
gas_armp = gas_rmp(end) + y*Fdot*(tv_armp-trmp);
tv = [tv_rmp, tv_armp];
gasdens_tot = [gas_rmp, gas_armp]/Na;
gas_tot = gasdens_tot*vol;
D1 = 7.6e-6*exp(-3.03./(kb * avT) );
D2 = 1.41e-18 * exp(-1.19./(kb * avT) ) * sqrt(Fdot);
D3 = 2.e-30 * Fdot;
D = D1+D2+D3; %cm^2/s
frac = 4*sqrt(D*tv/(pi*(a)^2)) - 3/2*D*tv/(pi*(a)^2);
gas_released = gas_tot.*frac;
conc = gas_released./(gas_released + n);

figure
plot(tv/(24*3600), conc,'linewidth',2)
set(gca,'fontsize',18)
xlabel('Time (days)')
ylabel('Concentration of fission gas in gap')



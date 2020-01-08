%EXam 2
clear 
close all

%Problem 2
a = 8e-4;%cm
frate = 2.0e13;%fissions/cm3s
T = 900 + 273.15;%K
kb = 8.6173303e-5;

%part A

D1 = 7.6e-6*exp(-3.03./(kb * T) );
D2 = 1.41e-18 * exp(-1.19./(kb * T) ) * sqrt(frate);
D3 = 2.e-30 * frate;
D = D1+D2+D3;
fprintf(1,'2, part a: D = %5.2e cm^2/s\n',D)

%Part B
t = 2*365*24*3600;%s
y = 0.3017;
gas_produced = t*y*frate;
tau = D*t/a^2;
f = 4*sqrt(D*t/(pi*a^2))-3/2*D*t/a^2;
gas_released = gas_produced*f;
fprintf(1,'2, part b: gas released = %5.2e gas atoms/cm^3\n',gas_released)

%Part c
T = 2000 + 273.15;%K
D1 = 7.6e-6*exp(-3.03./(kb * T) );
D2 = 1.41e-18 * exp(-1.19./(kb * T) ) * sqrt(frate);
D3 = 2.e-30 * frate;
D = D1+D2+D3;
frac = 0.1;
t = pi*a^2*frac^2/(36*D);
gas_released_post = gas_produced*(1-f)*frac;
fprintf(1,'2, part c: t = %5.1f s and gas released = %5.2e gas atoms/cm^3\n',t,gas_released_post)

%Problem 3
T = 600;%K
t = 365;%s
thw = 0.6;%mm

%Part a
dstar = 5.1*exp(-550/T);
tstar = 6.62e-7*exp(11949/T);
KL = 7.48e6*exp(-12500/T);
delta = dstar + KL*(t - tstar);
w = 14.7*delta;
fprintf(1,'3, part a: t = %5.2f mg/dm^2 \n',w)

%part b
thw_new = thw*1e3 - delta/1.56;
fprintf(1,'3, part b: wall thickness = %5.2f microns \n',thw_new)

%part c
f = 0.15;
dens_oxide = 5.68; %g/cm3
dens_zr = 6.5; %g/cm3
fo = 32/(91+32);
MH = 1;
MO = 16;
CH = 2*f*delta*dens_oxide*fo*MH/MO*1e6/((thw*1e3-delta/1.56)*dens_zr);
fprintf(1,'3, part c: Hydrogen concentration = %5.2f wt ppm \n',CH)
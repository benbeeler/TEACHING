%HW 3 problem 1 from NucE 497
%Input parameters
L = 3.00; %m
hs = 0.1; %m
Rf = 0.41e-2; %m;
hfp = 1.2e-2; %m;
th_gap = 80.0e-6; %m;
th_clad = 0.57e-3; %m
h_spr = 10.0e-2; %m;
n_pellets = 200;
P = 2e6; %Pa
Ti = 273;
Ts = 620;
R = 8.3144598; %J?mol?1?K-1
%Part A: Calculate number of moles of gas to get pressure
%Calculate gas volume
V_wpellets = 200*hfp*(pi*(Rf + th_gap)^2 - pi*Rf^2);
V_plenum = (L - 200*hfp-hs)*pi*(Rf + th_gap)^2;
V = V_wpellets + V_plenum;

%Calculate number of moles
n = P*V/(R*Ti)

%Part B: 
P = n*R*Ts/V;
Ro = Rf + th_gap + th_clad;
Ri = Rf + th_gap;
r = Ri:th_clad/9:Ro;
%rr stress
sigma(1,:) = -P*((Ro./r).^2-1)./((Ro/Ri)^2-1);

%tt stress
sigma(2,:) = P*((Ro./r).^2+1)./((Ro/Ri)^2-1);

%zz stress
sigma(3,:) = P/((Ro/Ri)^2 - 1)*ones(size(r));

%Max stress
max(sigma(:))

%Part C
stress_y = 381e6; %Pa
r = Ri;
Py = stress_y/(((Ro./r).^2+1)./((Ro/Ri)^2-1));
n = Py*V/(R*Ts)-n
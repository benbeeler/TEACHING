function HW3_prob3
clear
close all

global density cp Q Tcool k kc hcool dc dg Rf Ts rmp_time

%Material Properties
k = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
kc = 0.17; %W/(cm K), thermal conductivity of cladding
hcool = 2.5;
dc = 0.065;
dg = 30e-4;
density = 10.98; %g/cm3, density of UO2
cp = 0.33; %J/(g K), specific heat of UO2
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number

%Reactor conditions
Tcool = 600; %K, Coolant temperature
rmp_time = 1e4;
flux = 2.8e13;
%flux = 5e13;

%Pellet radius
Rf = 0.5; %cm
N = 100; %number of nodes along radius

%Time
tmax = 2e4; %seconds
M = 21; %number of time steps

% ----------------------------------------------------------
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);

% ----------------------------------------------------------
%Calculate heat generation rate
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*dens_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;

% ----------------------------------------------------------
%Solve problem in clyndrical coordinates (m = 1)
T = pdepe(1,@PDEfunction,@ICfunction,@BCfunction,r,t);

% ----------------------------------------------------------
% A surface plot is often a good way to study a solution.
figure(1)
surf(r, t, T, 'edgecolor','none') 
set(gca,'fontsize',18)
title('Temperature profile across radius with time')
xlabel('Radius (cm)')
ylabel('Time (s)')
zlabel('Temperature (K)')

%Compute analytical temperature
Tm = Q*Rf^2/(4*k) + Ts;
Tan = Tm - Q/(4*k)*r.^2;

% A line plot of the temperature at various times, including cladding and coolant.
figure(2)
plt_ind = [1,2,11,21];
pltT = T(plt_ind,:);
pltt = t(plt_ind);

Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number
flux = (pltt < 10).*2.8e13.*pltt/10 + (pltt >= 10).*2.8e13; %n/(cm2 s), Neutron flux in the fuel

MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*dens_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;
LHR = Q*pi*Rf^2;
TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
pltT = [pltT,[TCI',TCO',Tcool*ones(size(pltt'))]];
rlong = [r,Rf+[dg,dg+dc,dg+3*dc]];
    
plot(rlong, pltT,'linewidth',1.5)
set(gca,'fontsize', 18)

hold on
plot(r, Tan, 'k--','linewidth',1.5)

title('Temperature profile across radius')
xlabel('Radius (cm)')
ylabel('Temperature (K)')
legend('t = 0 s', 't = 0.1e4 s', 't = 1e4 s', 't = 2e4 s', 'Analytical')
legend boxoff

%Compute stresses in the fuel pellet
alpha = 11e-6; %1/K
E = 200; %MPa
nu = 0.345;
Tfab = 273; %K
eta = r/Rf;
sigma_star = alpha*E*(pltT(end,1) - pltT(end,end))/(4*(1-nu));
sigma_rr = -sigma_star*(1 - eta.^2);
sigma_tt = -sigma_star*(1 - 3*eta.^2);
sigma_zz = -2*sigma_star*(1 - 2*eta.^2);
figure;
plot(r, [sigma_rr; sigma_tt; sigma_zz],'-','linewidth',1.5)
set(gca,'fontsize', 18)

title('Stress across radius')
xlabel('Radius (cm)')
ylabel('Stress (GPa)')
legend('\sigma_{rr}', '\sigma_{\theta \theta}', '\sigma_{zz}')
legend boxoff

sigma_f = 0.13;
eta_f = sqrt((1 + sigma_f/sigma_star)/3)
hold on
plot([eta_f eta_f]*Rf, [-3, 3], 'k--','linewidth', 1.5)
plot([0 1]*Rf,[sigma_f, sigma_f],'k:')
end
% --------------------------------------------------------------
function [c,f,s] = PDEfunction(x,t,u,DuDx)
%Properties
global density cp Q

%Assign values
c = density*cp;

%%%%%%%%%T values
tnd = u/1000.;
tnd2 = tnd.^2;
tnd2p5 = tnd.^2.5;

%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
d = 7.5408 + 17.692*tnd + 3.6142*tnd2;
exp1 = exp(-16.35./tnd);
k = (100.0./d + (6400./tnd2p5).*exp1)*0.01; %W/cmK

f = k*DuDx;

Qfrac = Qcfrac(t);

s = Q*Qfrac;
end
% --------------------------------------------------------------
function u0 = ICfunction(x)
global Tcool;
%Initial temperature
T0 = Tcool; %K

%Assign values
u0 = T0*ones(size(x));
end
% --------------------------------------------------------------
function [pl,ql,pr,qr] = BCfunction(xl,ul,xr,ur,t)
%Material properties
global Tcool Q Rf kc hcool dc dg Ts;

Qfrac = Qcfrac(t);
LHR = Qfrac*Q*pi*Rf^2;
TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.0;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
Ts = TCI + LHR/(2*pi*Rf*hgap);

%Assign values
pl = 0; %This gets ignored
ql = 0; %This gets ignored
pr = ur-Ts;
qr = 0;
end

function Qfrac = Qcfrac(t)
global rmp_time;
Qfrac = ones(size(t));
if t < rmp_time;
    Qfrac = t./rmp_time;
end
end

function FinalProject1p5D_case3
clear
close all

global density cp Q Tcool kc hcool dc dg Rf rmp_time

%Material Properties
kcons = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
kc = 0.17; %W/(cm K), thermal conductivity of cladding
hcool = 2.5;
dc = 0.057;
dg = 80e-4;
density = 10.98; %g/cm3, density of UO2
cp = 0.33; %J/(g K), specific heat of UO2
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number
gamma = 1.3;
mdot = 1e-3;
mdot = 2.6e-4;
CPW = 4200;

%Reactor conditions
Tin = 580; %K, Coolant temperature
rmp_time = 0;
flux = 2.8e13;

%Pellet dimensions
Rf = 0.411; %cm
N = 20; %number of nodes along radius
npellets = 10;
hpellet = 1.19; %cm

%Time
tmax = 3600*6; %seconds
M = 101; %number of time steps

%Gap is closed
Rf = Rf + dg;
dg = 0;

% ----------------------------------------------------------
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);
z = linspace(hpellet/2,hpellet/2+npellets*hpellet,npellets);
zmax = max(z) + hpellet/2;

%Calculate heat generation rate
MU = 235*q + 238*(1-q); %g U/mol
NU = Na*dens_U/MU; %atoms/cm3;
Fdotmax = q*NU*flux*crosssection;
Qmax = Ef*Fdotmax;
LHRmax = Qmax*pi*Rf^2;
% ----------------------------------------------------------
%Loop over the ten pellets
for p = 1:npellets
    %Calculate axially varying properties
    zr = z(p)/(zmax/2);
    LHR = LHRmax*cos(pi/(2*gamma)*(zr-1));
    Q = LHR/(pi*Rf^2);
    
    %Calculate Tcool
    Tcool = Tin + (2*gamma/pi)*zmax/2*LHRmax/(mdot*CPW)*(sin(pi/(2*gamma)) + sin(pi/(2*gamma)*(zr-1))); %K
    
    % ----------------------------------------------------------
    %Solve problem in clyndrical coordinates (m = 1)
    Tp = pdepe(1,@PDEfunction,@ICfunction,@BCfunction,r,t);
    T(p,:,:) = Tp';
end
% ----------------------------------------------------------
% A surface plot is often a good way to study a solution.
[Mr,Mz]=meshgrid(r,z);
figure(1)
surf(Mr, Mz, T(:,:,end), 'edgecolor','none')
set(gca,'fontsize',18)
view(2)
axis equal tight
title('Temperature profile throughout rodlet at melting')
xlabel('Radius (cm)')
ylabel('height (cm)')
colorbar

% A line plot of the temperature at various times, including cladding and coolant.
figure(2)
plt_ind = [1,2,11,21];
pltT(:,:) = T(5,:,plt_ind);
pltT = pltT';
pltt = t(plt_ind);

Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number
flux = (pltt < 10).*2.8e13.*pltt/10 + (pltt >= 10).*2.8e13; %n/(cm2 s), Neutron flux in the fuel

%Compute analytical temperature
TCO = Tcool + LHRmax/(2*pi*Rf*hcool);
TCI = TCO + LHRmax*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.0;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
Ts = TCI + LHRmax/(2*pi*Rf*hgap);
Tm = Qmax*Rf^2/(4*kcons) + Ts;
Tan = Tm - Qmax/(4*kcons)*r.^2;

plot(r, pltT,'linewidth',1.5)
set(gca,'fontsize', 18)

title('Temperature profile throughout rodlet at melting')
xlabel('Radius (cm)')
ylabel('Temperature (K)')
legend('t = 0 s', 't = 0.1e4 s', 't = 1e4 s', 't = 2e4 s')
legend boxoff

figure(3)
maxT(:,:) = max(T,[],1);
maxT = max(maxT);
minT(:,:) = min(T,[],1);
minT = min(minT);
plot(t/(3600), minT, '-', t/(3600),maxT,'-','linewidth',1.5);
set(gca,'fontsize', 18)
xlabel('time (hrs)')
ylabel('T (K)')
legend('Minimum T','Maximum T','location','southeast')
legend boxoff
end
% --------------------------------------------------------------
function [c,f,s] = PDEfunction(x,t,u,DuDx)
%Properties
global density cp Q Fdotmax NU

Qfrac = Qcfrac(t);

Fdot = Qfrac*Fdotmax;

%Assign values
c = density*cp;

%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
tmax = 3600*24*365*2;
Bu = Fdotmax*tmax/NU*950;

Tc = u - 273.15;
qf = 0.5*(1 + tanh((Tc-900)/150));
kpstart = 1./(9.592e-2 + 6.14e-3*Bu - 1.4e-5*Bu.^2 + (2.5e-4 - 1.81e-6*Bu).*Tc);
kpend = 1./(9.592e-2 + 2.6e-3*Bu + (2.5e-4 - 2.7e-7*Bu).*Tc);
kel1 = 1.32e-2*exp(1.88e-3*Tc);
k = ((1 - qf).*kpstart + qf.*kpend + kel1)*1e-2;%W/cmK

f = k*DuDx;


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
global Tcool Q Rf kc hcool dc dg;

Tfab = 273;
alpha_c = 7.1e-6;
alpha_f = 11e-6;

Qfrac = Qcfrac(t);
LHR = Qfrac*Q*pi*Rf^2;
TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.0015;
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

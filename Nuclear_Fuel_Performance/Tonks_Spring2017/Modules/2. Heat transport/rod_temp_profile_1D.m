function rod_temp_profile_1D
clear
close all

global density cp Q Ts k

%Material Properties
k = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
density = 10.98; %g/cm3, density of UO2
cp = 0.325; %J/(g K), specific heat of UO2
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number

%Reactor conditions
flux = 2.8e13; %n/(cm2 s), Neutron flux in the fuel
Ts = 685; %K, surface temperature of the pellet

%Pellet radius
Rf = 0.5; %cm
N = 100; %number of nodes along radius

%Time
tmax = 30; %seconds
M = 11; %number of time steps

% ----------------------------------------------------------
%Calculate necessary parameters
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*dens_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;

% ----------------------------------------------------------
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);

% ----------------------------------------------------------
%Solve problem in clyndrical coordinates (m = 1)
T = pdepe(1,@PDEfunction,@ICfunction,@BCfunction,r,t);
max_T = max(T,[],2);
min_T = min(T,[],2);

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

% A line plot of the temperature at various times.
figure(2)
plot(r, T([1,2,5,10],:),'linewidth',1.5)
set(gca,'fontsize', 18)

hold on
plot(r, Tan, 'k--','linewidth',1.5)

title('Temperature profile across radius')
xlabel('Radius (cm)')
ylabel('Temperature (K)')
legend('t = 0 s', 't = 3 s', 't = 12 s', 't = 30 s', 'Analytical')
legend boxoff
end
% --------------------------------------------------------------
function [c,f,s] = PDEfunction(x,t,u,DuDx)
%Properties
global density cp Q k

%Assign values
c = density*cp;
f = k*DuDx;
s = Q;
end
% --------------------------------------------------------------
function u0 = ICfunction(x)
global Ts;
%Initial temperature
T0 = Ts; %K

%Assign values
u0 = T0*ones(size(x));
end
% --------------------------------------------------------------
function [pl,ql,pr,qr] = BCfunction(xl,ul,xr,ur,t)
%Material properties
global Ts;

%Assign values
pl = 0; %This gets ignored
ql = 0; %This gets ignored
pr = ur-Ts;
qr = 0;
end
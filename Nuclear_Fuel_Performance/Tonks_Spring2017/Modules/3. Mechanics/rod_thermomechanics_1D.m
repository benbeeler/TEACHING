function rod_thermomechanics_1D
clear
close all

global density cp Q Ts k C11 C12 Tfab alpha

%Material Properties
k = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
density = 10.98; %g/cm3, density of UO2
cp = 0.325; %J/(g K), specific heat of UO2
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number
E = 200; %GPa, thermal conductivity of UO2 at higher temperature
nu = 0.345; %
alpha = 11e-6; %1/K
Tfab = 273; %K

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
C11 = E*(1-nu)/((1+nu)*(1-2*nu));
C12 = E*nu/((1+nu)*(1-2*nu));

% ----------------------------------------------------------
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);

% ----------------------------------------------------------
%Solve problem in clyndrical coordinates (m = 1)
vars = pdepe(0,@PDEfunction,@ICfunction,@BCfunction,r,t);
T = vars(:,:,1);
ur = vars(:,:,2);

% ----------------------------------------------------------
% A surface plot is often a good way to study a solution.
figure(1)
surf(r, t, T, 'edgecolor','none')
set(gca,'fontsize',18)
title('Temperature profile across radius with time')
xlabel('Radius (cm)')
ylabel('Time (s)')
zlabel('Temperature (K)')

figure(2)
surf(r, t, ur, 'edgecolor','none')
set(gca,'fontsize',18)
title('Displacement profile across radius with time')
xlabel('Radius (cm)')
ylabel('Time (s)')
zlabel('r displacement (cm)')

%Compute strains
strain_rr = [zeros(M,1),(ur(:,2:end) - ur(:,1:end-1))/(r(2)-r(1))];
strain_tt = ur./(ones(M,1)*r);

%Compute stress
stress_rr = strain_rr*C11 + strain_tt*C12;
stress_tt = strain_rr*C12 + strain_tt*C11;

figure(3)
surf(r, t, stress_rr, 'edgecolor','none')
set(gca,'fontsize',18)
title('Sigma_{tt} profile across radius with time')
xlabel('Radius (cm)')
ylabel('Time (s)')
zlabel('Stress (GPa)')

%Compute analytical temperature
Tm = Q*Rf^2/(4*k) + Ts;
Tan = Tm - Q/(4*k)*r.^2;

% A line plot of the temperature at various times.
figure(4)
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
global density cp Q k C11 C12 Tfab alpha

%Assign values for PDEs
c = [density*cp; 0];
f = [k; C11].*DuDx;
s = [Q + k*DuDx(1)/x; C11*DuDx(2)/x + C11*u(2)/x^2 + alpha*(u(1) - Tfab)*(C12 - C11)/x];
end
% --------------------------------------------------------------
function u0 = ICfunction(x)
global Ts;
%Initial temperature
T0 = Ts; %K

%Assign values
u0 = [T0; 0];
end
% --------------------------------------------------------------
function [pl,ql,pr,qr] = BCfunction(xl,ul,xr,ur,t)
%Material properties
global Ts C11;

%Assign values
pl = [0;ur(2)]; %This gets ignored
ql = [1;0]; %This gets ignored
pr = [ur(1) - Ts; ur(2)];
qr = [0; 0];
end
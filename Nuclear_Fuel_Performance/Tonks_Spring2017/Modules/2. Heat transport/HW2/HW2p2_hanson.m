function HW2p2_hanson
%clear
close all
 
global density cp Q Ts k Rf Ef NU crosssection flux
 
%Material Properties
k = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
density = 10.98; %g/cm3, density of UO2
cp = 0.325; %J/(g K), specific heat of UO2
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cmty of U in UO2
dens_U=9.65;
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number
hcool = 2.5; %W/cm2K Cladding
Xe= 0.1; %Xe Percent
Rf = 0.5; %cm
%Time
tmax = 20000; %seconds
M = 20001; %number of time steps
N = 100; %number of nodes along radius
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);
%Reactor conditions
flux = 2.8e13; %n/(cm2 s), Neutron flux in the fuel
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*dens_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;
 
dc = 0.065; %Cladding thickness cm
gap = 30e-4; %Gap width cm
Tcool = 600; %K
tco= ((q*Rf)/(2*hcool))+Tcool;
kc =(100)./((7.5408)+(17.629.*(tco/1000))+(3.6148*(tco/1000)^2))*0.01;%W/cmK
tci= ((q*Rf*dc)/(2*kc))+tco;
khe= (16e-6)*(tci^(0.79));
kxe= (0.7e-6)*(tci^(0.79));
kgap = ((khe^(1-Xe))*(kxe^(Xe)));
hgap=  kgap/gap;
Ts= (Q*Rf)/(2*hgap)+tci;
% ----------------------------------------------------------
%Solve problem in clyndrical coordinates (m = 1)
T = pdepe(1,@PDEfunction,@ICfunction,@BCfunction,r,t);
 
% ----------------------------------------------------------
% A surface plot is often a good way to study a solution.
%figure(1)
%surf(r, t, T, 'edgecolor','none') 
%title('Temperature profile across radius with time')
%xlabel('Radius (cm)')
%ylabel('Time (s)')
%zlabel('Temperature (K)')
 
%Compute analytical temperature
Tm = Q*Rf^2/(4*k) + Ts;
Tan = Tm - Q/(4*k)*r.^2;
 
% A line plot of the temperature at various times.
figure(2)
plot(r, T([1,1000,10000,20000],:),'linewidth',2)
hold on
plot(r, Tan, 'k--','linewidth',2)
 
title('Temperature profile across radius')
xlabel('Radius (cm)')
ylabel('Temperature (K)')
legend('t = 0.0 s', 't = 0.1e4 s', 't = 1.0e4 s', 't = 2.0e4 s', 'Analytical')
legend boxoff
end
% --------------------------------------------------------------
function [c,f,s] = PDEfunction(x,t,u,DuDx)
%Properties
global density cp k
Q = Qfunction(t);
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
function Q = Qfunction(t)
global Ef NU crosssection flux
if t>=1e4
    ffrac = 1;
end
if t<1e4
    ffrac = t/(1e4);
end
fflux = ffrac*flux;
Q = Ef*NU*fflux*crosssection;
end


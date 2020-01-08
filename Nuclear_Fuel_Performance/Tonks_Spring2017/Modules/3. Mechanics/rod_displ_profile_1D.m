function rod_temp_profile_1D
clear
close all

global C11 C12 alpha DT

%Material Properties
E = 200; %GPa, thermal conductivity of UO2 at higher temperature
nu = 0.345; %
alpha = 11e-6; %1/K
Tfab = 273; %K
T = 800;

%Solution parameters
Rf = 0.5; %cm
N = 100;
M = 3;
tmax = 1;

% ----------------------------------------------------------
%Calculate necessary parameters
C11 = E*(1-nu)/((1+nu)*(1-2*nu));
C12 = E*nu/((1+nu)*(1-2*nu));
DT = T - Tfab;

% ----------------------------------------------------------
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);

% ----------------------------------------------------------
%Solve problem in clyndrical coordinates (m = 1)
ur = pdepe(0,@PDEfunction,@ICfunction,@BCfunction,r,t);

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
global C11 C12 alpha DT

%Assign values
c = 0;
f = C11*DuDx;
s = -C11*u + x*C11*DuDx + alpha*DT*(C12 - C11);
end
% --------------------------------------------------------------
function u0 = ICfunction(x)
u0 = zeros(size(x));
end
% --------------------------------------------------------------
function [pl,ql,pr,qr] = BCfunction(xl,ul,xr,ur,t)
%Material properties
global Ts;

%Assign values
pl = ul - 0; %Zero displacements at center axis
ql = 0;
pr = 0;
qr = 0;
end
function pdex11
clear
close all

global density cp Q Tedge
%Properties
k = 0.03; %W/cmK
density = 10.98; %g/cm^3
cp = 0.325; %J/(g K)
Q = 230; %W/cm3
Tedge = 685; %K

%Pellet radius
r = 0.5; %cm

%end time
tmax = 20; %seconds

m = 1; %Symmetry, slab = 0, cyl = 1, sph = 2
nnodes = 100;
ntime_steps = 10;

%%%%%%%%%%%%
x = linspace(0,r,nnodes);
t = linspace(0,tmax, ntime_steps);

%**********
%Solve problem
sol = pdepe(m,@frod_pde,@pdex1ic,@pdex1bc,x,t);

% Extract the first solution component as u.
T = sol(:,:,1);

% A surface plot is often a good way to study a solution.
surf(x,t,T,'edgecolor','none') 
title('Numerical solution computed with 20 mesh points.')
xlabel('Distance x')
ylabel('Time t')
%Analytical temperature plot
Tm = Q*r^2/(4*k) + Tedge;
Tan = Tm - Q/(4*k)*x.^2;
% A solution profile can also be illuminating.
figure
plot(x,T([1,5,10],:))
hold on
plot(x,Tan,'k--')
title('Solution at t = 2')
xlabel('Distance x')
ylabel('u(x,2)')
% --------------------------------------------------------------
function [c,f,s] = frod_pde(x,t,u,DuDx)
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
s = Q;
% --------------------------------------------------------------
function u0 = pdex1ic(x)
global Tedge;
%Initial temperature
T0 = Tedge; %K

%Assign values
u0 = T0*ones(size(x));
% --------------------------------------------------------------
function [pl,ql,pr,qr] = pdex1bc(xl,ul,xr,ur,t)
%Material properties
global Tedge;

%Assign values
pl = 0;
ql = 1;
pr = ur-Tedge;
qr = 0;
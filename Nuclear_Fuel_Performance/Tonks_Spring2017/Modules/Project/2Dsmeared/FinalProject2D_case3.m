function FinalProject2D_case1b
clear
close all

global kcons density cp LHR0 lngth Rf gamma mdot kc hcool dg dc rmp_time
global Fdot0 NU
%Material Properties
kcons = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
density = 10.98; %g/cm3, density of UO2
cp = 0.325; %J/(g K), specific heat of UO2
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number
gamma = 1.3;
mdot = 1e-3; 
mdot = 2.3e-4;
kc = 0.17; %W/(cm K), thermal conductivity of cladding
hcool = 2.5;
dc = 0.057;
dg = 80e-4;

%Reactor conditions
flux = 2.8e13; %n/(cm2 s), Neutron flux in the fuel
Tin = 580; %K, surface temperature of the pellet
rmp_time = 0;

%Rodlet geometry
Rf = 0.411; %cm
npellets = 10;
hpellet = 1.19;
lngth = npellets*hpellet; %cm
hmax = .1; % element size

%Time
tmax = 3600*6; %seconds
M = 301; %number of time steps

%Calculate the heat generation rate
MU = 235*q + 238*(1-q); %g U/mol
NU = Na*dens_U/MU; %atoms/cm3;
Fdot0 = q*NU*flux*crosssection;
Q0 = Ef*Fdot0; %W/cm^3
LHR0 = Q0*pi*Rf^2;

%Define the problem
numberOfPDE = 1;
model = createpde(numberOfPDE);

%Define geometry of the fuel rod
Rf = Rf + dg;
dg = 0;
g = decsg([3 4 0 Rf Rf 0 0 0 lngth lngth]');

% Convert the geometry and append it to the pde model
geometryFromEdges(model,g);

%Plot geometry
brder = 0.1;
figure
p1 = pdegplot(model,'EdgeLabels','on');
set(p1, 'linewidth',1.5)
axis equal
axis ([ -brder Rf+brder -brder lngth+brder])
title 'Geometry With Edge Labels';

% Generate the mesh
generateMesh(model,'Hmax',hmax);

%Plot the mesh
figure;
pdeplot(model);
axis equal
axis ([ -brder Rf+brder -brder lngth+brder])
title 'Triangular Element Mesh'
set(gca,'fontsize',18)

% Specify PDE Coefficients
specifyCoefficients(model,'m',0,'d',@dFunc,'c',@cFunc,'a',0,'f',@fFunc);

%Boundary conditions
bbottom = applyBoundaryCondition(model,'Edge',1,'g',0.0);
bouter = applyBoundaryCondition(model,'Edge',2,'u',@T_BC);
bmid = applyBoundaryCondition(model,'Edge',3,'g',0.0);
bcenter = applyBoundaryCondition(model,'Edge',4,'g',0.0);

%Set initial condition
setInitialConditions(model, Tin);

% Set time behavior
tlist = linspace(0, tmax, M);

%Turn on solver statistics
model.SolverOptions.ReportStatistics = 'on';

%Solve the system
result = solvepde(model,tlist);

u = result.NodalSolution;

%Plot the solution at time t = 20000.
figure;
pdeplot(model,'XYData',u(:,end));
colormap('jet')
axis equal
axis ([ -brder Rf+brder -brder lngth+brder])
title(sprintf('Temperature at t = %g s',tmax));

%Create line plot
p = model.Mesh.Nodes;
top_nodes = find(p(2,:) == 0);
top_radius = p(1,top_nodes);
[top_radius, sort_ind] = sort(top_radius);
top_T = u(top_nodes(sort_ind),[1,3,end]);
max_T = max(u);
min_T = min(u);

%Compute analytical temperature
Tcool = Tin;
TCO = Tcool + LHR0/(2*pi*Rf*hcool);
TCI = TCO + LHR0*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.0;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
Ts = TCI + LHR0/(2*pi*Rf*hgap);
Tm = Q0*Rf^2/(4*kcons) + Ts;
r = [0:.1:Rf];
Tan = Tm - Q0/(4*kcons)*r.^2;

figure;
plot(top_radius, top_T,'*','linewidth',1.5)
hold on
plot(r,Tan,'k--','linewidth',1.5)
set(gca,'fontsize',18)
legend('t = 0 s','t = 9 s','t = 30 s','analytical')
legend boxoff
xlabel('r (cm)')
ylabel('T (K)')

figure;
plot(tlist/3600, max_T,'-',[0,tmax]/3600,[1 1]*max(Tan),'k--','linewidth',1.5)
set(gca,'fontsize', 18)
xlabel('time(hrs)')
ylabel('max T (K)')
legend('Code','Analytical','location','southeast')
legend boxoff
end

function c = cFunc(region, state)
%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
global Fdot0 NU
%Calculate burnup
life_time = 3600*24*365*2;
Bu = Fdot0*life_time/NU*950;

%Calculate T in C
Tc = state.u - 273.15;

%Calculate k
qf = 0.5*(1 + tanh((Tc-900)/150));
kpstart = 1./(9.592e-2 + 6.14e-3*Bu - 1.4e-5*Bu.^2 + (2.5e-4 - 1.81e-6*Bu).*Tc);
kpend = 1./(9.592e-2 + 2.6e-3*Bu + (2.5e-4 - 2.7e-7*Bu).*Tc);
kel1 = 1.32e-2*exp(1.88e-3*Tc);
k = ((1 - qf).*kpstart + qf.*kpend + kel1)*1e-2;%W/cmK

%Set coefficient
c = k.*region.x;
end

function d = dFunc(region, state) 
global density cp;
d = density*cp*region.x;
end

function f = fFunc(region, state) 
global LHR0 lngth Rf gamma rmp_time;
zr = region.y/(lngth/2);

if state.time < rmp_time
    Qfrac = state.time/rmp_time;
else
    Qfrac = 1.0;
end

%Calculate axial power profile
LHR = Qfrac*LHR0*cos(pi/(2*gamma)*(zr-1));
Q = LHR/(pi*Rf^2);

%Calculate coefficient
f = Q.*region.x;
end

function T_bnd = T_BC(region, state) 
global Tin Rf lngth gamma LHR0 mdot kc hcool dg dc kcons rmp_time
Tfab = 273;
alpha_c = 7.1e-6;
alpha_f = 11e-6;
CPW = 4200;

%Get relative z position
zr = region.y/(lngth/2);

if state.time < rmp_time
    Qfrac = state.time/rmp_time;
else
    Qfrac = 1.0;
end
%Calculate axial power profile
LHR = Qfrac*LHR0*cos(pi/(2*gamma)*(zr-1));

%Calculate coolant T
Tcool = Tin + (2*gamma/pi)*lngth/2*Qfrac*LHR0/(mdot*CPW)*(sin(pi/(2*gamma)) + sin(pi/(2*gamma)*(zr-1))); %K
   
TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.0015;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
Ts = TCI + LHR/(2*pi*Rf*hgap);

T_bnd = Ts;
end
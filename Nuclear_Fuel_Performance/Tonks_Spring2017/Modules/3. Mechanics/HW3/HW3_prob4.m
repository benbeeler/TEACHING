function HW3_prob4
clear
close all

global k density cp LHR0 lngth Rf

%Material Properties
k = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
density = 10.98; %g/cm3, density of UO2
cp = 0.325; %J/(g K), specific heat of UO2
LHR0 = 150; %W/cm
Ts = 855;

%Rodlet geometry
Rf = 0.5; %cm
lngth = 20.0; %cm
hmax = .1; % element size

%Time
tmax = 30; %seconds
M = 11; %number of time steps

%Calculate the heat generation rate
Q = LHR0/(pi*Rf^2);

%Define the problem
numberOfPDE = 1;
model = createpde(numberOfPDE);

%Define geometry of the fuel rod
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
bbottom = applyBoundaryCondition(model,'Edge',1,'u',@T_BC_tb);
bouter = applyBoundaryCondition(model,'Edge',2,'u',@T_BC_edge);
btop = applyBoundaryCondition(model,'Edge',3,'u',@T_BC_tb);
bcenter = applyBoundaryCondition(model,'Edge',4,'g',0.0);

%Set initial condition
setInitialConditions(model, Ts);

% Set time behavior
tlist = linspace(0, tmax, M);

%Turn on solver statistics
model.SolverOptions.ReportStatistics = 'on';

%Solve the system
result = solvepde(model,tlist);

u = result.NodalSolution;

%Plot the solution at time t = 3 s.
figure;
pdeplot(model,'XYData',u(:,2));
colormap('jet')
axis equal
axis ([ -brder Rf+brder -brder lngth+brder])
title(sprintf('Temperature at t = %g s',tlist(2)));

%Plot the solution at time t = 30 s.
figure;
pdeplot(model,'XYData',u(:,end));
colormap('jet')
axis equal
axis ([ -brder Rf+brder -brder lngth+brder])
title(sprintf('Temperature at t = %g s',tmax));
end

function c = cFunc(region, state)
T = state.u;
tnd = T/1000.;
tnd2 = tnd.^2;
tnd2p5 = tnd.^2.5;

%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
d = 7.5408 + 17.692*tnd + 3.6142*tnd2;
exp1 = exp(-16.35./tnd);
k = (100.0./d + (6400./tnd2p5).*exp1)*0.01; %W/cmK
c = k.*region.x;
end

function d = dFunc(region, state)
global density cp;
d = density*cp*region.x;
end

function f = fFunc(region, state)
global LHR0 lngth Rf;
gamma = 1.3;
zr = region.y/(lngth/2);
LHR = LHR0*cos(pi/(2*gamma)*(zr-1));
Q = LHR/(pi*Rf^2);
f = Q.*region.x;
end

function Ts = T_BC_tb(region, state)
global LHR0 lngth Rf;
gamma = 1.3;
mdot = 0.25;
CPW = 4200;
zr = region.y/(lngth/2);
LHR = LHR0*cos(pi/(2*gamma)*(zr-1));
Tin = 570;
Tcool = Tin + (2*gamma/pi)*lngth/2*LHR0/(mdot*CPW)*(sin(pi/(2*gamma)) + sin(pi/(2*gamma)*(zr-1))); %K
kc = 0.17; %W/(cm K), thermal conductivity of cladding
hcool = 2.5;
dc = 0.065;
dg = 30e-4;
TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.10;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
Ts = TCI + LHR/(2*pi*Rf*hgap);
end

function Ts = T_BC_edge(region, state)
global LHR0 lngth Rf;
gamma = 1.3;
mdot = 0.25;
CPW = 4200;
k = 0.03;
zr = region.y/(lngth/2);
LHR = LHR0*cos(pi/(2*gamma)*(zr-1));
Tin = 570;
Tfab = 273;
Tcool = Tin + (2*gamma/pi)*lngth/2*LHR0/(mdot*CPW)*(sin(pi/(2*gamma)) + sin(pi/(2*gamma)*(zr-1))); %K
kc = 0.17; %W/(cm K), thermal conductivity of cladding
hcool = 2.5;
dc = 0.065;
dg = 30e-4;
alpha_c = 7.1e-6;
alpha_f = 11e-6;
TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.10;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
%Account for gap closure
Ts = TCI + LHR/(2*pi*Rf*hgap);
T0 = Ts + LHR./(4*pi*k);
ch_gap = alpha_c*(Rf+dg+dc/2)*(mean([TCO, TCI]) - Tfab);
%Iterate to close the gap
j = 0; chng = 1;
Dgap = 0;
while chng > 1e-3
    j = j+1;
    ch_fuel = alpha_f*Rf*(mean([Ts T0])-Tfab);
    old_Dgap = Dgap;
    Dgap = ch_gap - ch_fuel;
    ndg = dg + Dgap;
    if ndg < 1e-8
        ndg = 1e-8;
    end
    hgapi = kgap/ndg;
    Ts = TCI + LHR/(2*pi*(Rf+ch_fuel)*hgapi);
    T0 = Ts + LHR/(4*pi*k);
    chng = abs(Dgap - old_Dgap)/abs(old_Dgap);
end
end
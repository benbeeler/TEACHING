function rod_temp_profile_2D
clear all
close all
clc
global kf density cp mdot LHRo Q Zo Tcool Tco Tci Tin tg tc h kc Rf pigam alphaf lngth

%Material Properties
kf = 0.03; %W/(cm K), thermal conductivity of UO2 at higher temperature
density = 10.98; %g/cm3, density of UO2
cp = 0.325; %J/(g K), specific heat of UO2
mdot=0.25;
kc=0.17;
Rf=0.5;
tc=0.065;
tg=30e-4;
Tin=570;
% Zo=10;
h=2.5;
LHRo=300;
alphaf=11e-6;
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number

%Reactor conditions
flux = 2.8e13; %n/(cm2 s), Neutron flux in the fuel
% Ts = 685; %K, surface temperature of the pellet
%Rodlet geometry
Rf = 0.5; %cm
lngth = 20.0; %cm
Zo=lngth/2;%cm
hmax = .1; % element size

%Time
tmax = 30; %seconds
M = 11; %number of time steps

%Calculate the heat generation rate
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*dens_U/MU; %atoms/cm3;
% Q = Ef*NU*flux*crosssection; %W/cm^3

gamma=1.3;
pigam=pi/(2*gamma);
Q = @(z) (LHRo) * cos(pi/2/gamma*(z/Zo - 1));

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
bbottom = applyBoundaryCondition(model,'Edge',1,'u',@surftemp);
bouter = applyBoundaryCondition(model,'Edge',2,'u',@sidetemp);
bmid = applyBoundaryCondition(model,'Edge',3,'u',@surftemp);
bcenter = applyBoundaryCondition(model,'Edge',4,'g',0.0);

%Set initial condition
setInitialConditions(model, @surftemp);

% Set time behavior
tlist = linspace(0, tmax, M);

%Turn on solver statistics
model.SolverOptions.ReportStatistics = 'on';

%Solve the system
result = solvepde(model,tlist);

u = result.NodalSolution;

%Plot the solution at time t = 30.
figure;
pdeplot(model,'XYData',u(:,end));
colormap('jet')
axis equal
axis ([ -brder Rf+brder -brder lngth+brder])
title(sprintf('Temperature at t = %g s',tmax));

%Plot the solution at time t = 3s.
figure;
pdeplot(model, 'XYData', u(:,2));
colormap('jet')
axis equal
axis([ -brder Rf+brder -brder lngth+brder])
title(sprintf('Temperature at t = 3 s', tmax));

end

function c = cFunc(region, state)
global k
tt = state.u./1000;
k = 1./(7.5408 + 17.629.*tt + 3.6142.*tt.^2);
c = k.*region.x;
end

function d = dFunc(region, state) 
global density cp;
d = density*cp*region.x;
end

function f = fFunc(region, state) 
global Q;
f = Q(region.y).*region.x;
end

function Ts=surftemp(region,state) 
global Q mdot kc Rf tc tg Tin Zo h pigam LHRo
cpw = 4200; %J/(g K), specific heat of UO2
AA=Zo*LHRo/(mdot*cpw);
Tcool=Tin+AA.*sin(pigam) + sin(pigam*(region.y/Zo - 1));
% Tco = Tcool + Q(region.y)*Rf/(2*h);
Tci = Tcool + Q(region.y)*Rf./(2*h) + Q(region.y)*Rf*tc./(2*kc);
kHe = 16e-6*Tci.^0.79;
kXe = 0.7e-6*Tci.^0.79;
y = 0.1;
kgap  = kHe.^(1-y).*kXe.^y;
hgap = kgap./tg;
Ts = Tci + Q(region.y)*Rf./(2*hgap);
end

function Tside=sidetemp(region,state) 
global Q mdot kc Rf tc tg Tin Zo h pigam LHRo kf
%Temperature calculations
cpw = 4200; %J/(g K), specific heat of UO2
AA=Zo*LHRo/(mdot*cpw);
Tcool=Tin+AA.*sin(pigam) + sin(pigam*(region.y/Zo - 1));
Tco = Tcool + Q(region.y)*Rf/(2*h);
Tci = Tco + Q(region.y)*Rf*tc./(2*kc);
kHe = 16e-6*Tci.^0.79;
kXe = 0.7e-6*Tci.^0.79;
y = 0.1;
kgap = kHe.^(1-y).*kXe.^y;
hgap = kgap./tg;
Ts = Tci + Q(region.y)*Rf./(2*hgap);
Tm = Ts + (Q(region.y).*Rf.^2)./(4*kf);


%Initializing parameters

Tfab = 273; %K, fabrication temperature 
alphac = 7.1e-6; %1/K, Thermal expansion coeffient
alphaf =11e-6; %1/K, Thermal expansion coefficent

%Initial change in gap size
Rc = Rf+ tg + tc/2; %cm, average radius upto cladding

%Initial cladding temperature 
Tcave = (Tci+Tco)/2 ;
dRc = Rc*alphac*(Tcave-Tfab);

%Gap iteration
i=0;
chng = 1;
dgap = 0;

while chng > 1e-6
i=i+1;
old_dgap = dgap;
dRf = alphaf.*Rf.*(((Tm+Ts)/2) - Tfab);
dgap = dRc - dRf;
tg = tg + dgap;
if tg<1e-8
    tg=1e-8;
end
hgap = kgap./tg;
Ts = Tci + (Q(region.y).*(dRf +Rf))./(2*hgap);
Tm = Ts + (Q(region.y).*((dRf +Rf).^2))./(4*kf);
chng = abs(dgap - old_dgap)/(old_dgap);
end
Tside = Ts;
end

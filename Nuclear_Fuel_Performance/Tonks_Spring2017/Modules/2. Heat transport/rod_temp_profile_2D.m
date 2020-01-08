function rod_temp_profile_2D
clear
close all

global k density cp Q

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

%Rodlet geometry
Rf = 0.5; %cm
lngth = 10.0; %cm
hmax = .1; % element size

%Time
tmax = 30; %seconds
M = 11; %number of time steps

%Calculate the heat generation rate
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*dens_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection; %W/cm^3

%Define the problem
numberOfPDE = 1;
model = createpde(numberOfPDE);

%Define geometry of the fuel rod
g = decsg([3 4 0 Rf Rf 0 0 0 lngth/2 lngth/2]');

% Convert the geometry and append it to the pde model
geometryFromEdges(model,g);

%Plot geometry
brder = 0.1;
figure
p1 = pdegplot(model,'EdgeLabels','on');
set(p1, 'linewidth',1.5)
axis equal
axis ([ -brder Rf+brder -brder lngth/2+brder])
title 'Geometry With Edge Labels';

% Generate the mesh
generateMesh(model,'Hmax',hmax);

%Plot the mesh
figure;
pdeplot(model);
axis equal
axis ([ -brder Rf+brder -brder lngth/2+brder])
title 'Triangular Element Mesh'
set(gca,'fontsize',18)

% Specify PDE Coefficients
specifyCoefficients(model,'m',0,'d',@dFunc,'c',@cFunc,'a',0,'f',@fFunc);

%Boundary conditions
bbottom = applyBoundaryCondition(model,'Edge',1,'u',Ts);
bouter = applyBoundaryCondition(model,'Edge',2,'u',Ts);
bmid = applyBoundaryCondition(model,'Edge',3,'g',0.0);
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

%Plot the solution at time t = 20000.
figure;
pdeplot(model,'XYData',u(:,6));
colormap('jet')
axis equal
axis ([ -brder Rf+brder -brder lngth/2+brder])
title(sprintf('Temperature at t = %g s',tlist(6)));

%Create line plot
p = model.Mesh.Nodes;
top_nodes = find(p(2,:) == lngth/2);
top_radius = p(1,top_nodes);
[top_radius, sort_ind] = sort(top_radius);
top_T = u(top_nodes(sort_ind),[1,3,end]);

figure;
plot(top_radius, top_T,'*','linewidth',1.5)
Tm = Q*Rf^2/(4*k) + Ts;
r = (0:20)/20*Rf;
Tan = Tm - Q/(4*k)*r.^2;
hold on
plot(r,Tan,'k--','linewidth',1.5)
set(gca,'fontsize',18)
legend('t = 0 s','t = 9 s','t = 30 s','analytical')
legend boxoff
xlabel('r (cm)')
ylabel('T (K)')
end

function c = cFunc(region, state)
global k
c = k*region.x;
end

function d = dFunc(region, state) 
global density cp;
d = density*cp*region.x;
end

function f = fFunc(region, state) 
global Q;
f = Q*region.x;
end
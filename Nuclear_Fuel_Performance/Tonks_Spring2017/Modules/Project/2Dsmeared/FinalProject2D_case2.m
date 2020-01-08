function FinalProject2D_case2
clear
close all
clearvars

global kcons density cp lngth Rf gamma mdot kc hcool dg dc vol n Tin
global Ef Q0 NU 

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
q = 0.041; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number
gamma = 1.3;
mdot = 0.25; 
CPW = 4200;
R = 8.3144598; %J?mol?1?K-1
Ti = 273; %K

%Reactor conditions
Tin = 580; %K, Coolant temperature
flux = 2.8e13;

%Rodlet geometry
Rf = 0.41; %cm
npellets = 10;
hpellet = 1.19;
hpl = 0.6;%cm
P = 2e6; %Pa
hmax = .1; % element size

%Time
tmax = 3600*24*365*2; %seconds
M = 101; %number of time steps

% ----------------------------------------------------------
%Calculate the heat generation rate
MU = 235*q + 238*(1-q); %g U/mol
NU = Na*dens_U/MU; %atoms/cm3;
Fdot0 = q*NU*flux*crosssection;
Q0 = Ef*Fdot0; %W/cm^3

%Define the problem
numberOfPDE = 1;
model = createpde(numberOfPDE);

%Define geometry of the fuel rod
lngth = npellets*hpellet; %cm
g = decsg([3 4 0 Rf Rf 0 0 0 lngth lngth]');

%Calculate fuel volume
vol = (pi*(Rf)^2*npellets*hpellet);

%Calculate initial moles of He in gap and plenum
V_wpellets = npellets*hpellet*(pi*(Rf + dg)^2 - pi*Rf^2);
V_plenum = hpl*pi*(Rf + dg)^2;
V = V_wpellets + V_plenum; %cm^3
V = V*(1e-2)^3;
n = P*V/(R*273);

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

% ----------------------------------------------------------
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
LHR0 = Q0*pi*Rf^2;
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
r = 0:.1:Rf;
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
plot(tlist/(24*3600), [max_T;min_T],'linewidth',1.5)
set(gca,'fontsize', 18)
xlabel('time(days)')
ylabel('T (K)')
legend('Max','Min','location','southeast')
legend boxoff

M = [tlist; max_T; min_T];
csvwrite('2Dsmeared_case2.csv',M);
end

function c = cFunc(region, state)
%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
global Q0 NU lngth gamma Ef

%Get relative z position
zr = region.y/(lngth/2);
t = state.time;

%Calculate axial power profile
Q = Q0*cos(pi/(2*gamma)*(zr-1));

%Calculate burnup
Fdot = Q/Ef;
Bu = Fdot*t/NU*950;

%Calculate T in C
Tc = state.u - 273.15;

%Calculate k
qf = 0.5*(1 + tanh((Tc-900)/150));
kpstart = 1./(9.592e-2 + 6.14e-3*Bu - 1.4e-5*Bu.^2 + (2.5e-4 - 1.81e-6*Bu).*Tc);
kpend = 1./(9.592e-2 + 2.6e-3*Bu + (2.5e-4 - 2.7e-7*Bu).*Tc);
kel1 = 1.32e-2*exp(1.88e-3*Tc);
k = ((1 - qf).*kpstart + qf.*kpend + kel1)*1e-2;%W/cmK

%Set coefficient
c = 1.2*k.*region.x;
end

function d = dFunc(region, state) 
global density cp;
d = density*cp*region.x;
end

function f = fFunc(region, state) 
global Q0 lngth gamma;

%Get relative z position
zr = region.y/(lngth/2);

%Calculate axial power profile
Q = Q0*cos(pi/(2*gamma)*(zr-1));

%Calculate coefficient
f = Q.*region.x;
end

function T_bnd = T_BC(region, state) 
global Tin Rf lngth gamma mdot kc hcool dg dc vol n
global Q0 NU Ef

%Constants
Tfab = 273;
alpha_c = 7.1e-6;
alpha_f = 11e-6;
kb = 8.6173303e-5;
Na = 6.022e23; %atoms/mol
CPW = 4200;

%Get relative z position
zr = region.y/(lngth/2);
t = state.time;

%Calculate axial power profile
Q = Q0*cos(pi/(2*gamma)*(zr-1));

%Calculate burnup
Fdot = Q/Ef;
Bu = Fdot*t/NU; %FIMA

%Calculate kcons
Tcalc = 1300-273.15;
Bug = Bu*950;
qf = 0.5*(1 + tanh((Tcalc-900)/150));
kpstart = 1./(9.592e-2 + 6.14e-3*Bug - 1.4e-5*Bug.^2 + (2.5e-4 - 1.81e-6*Bu).*Tcalc);
kpend = 1./(9.592e-2 + 2.6e-3*Bug + (2.5e-4 - 2.7e-7*Bug).*Tcalc);
kel1 = 1.32e-2*exp(1.88e-3*Tcalc);
kcons = 1.2*((1 - qf).*kpstart + qf.*kpend + kel1)*1e-2;%W/cmK

%Fission gas diffusivity
Tg = 1000; %Makes calculation possible
D1 = 7.6e-6*exp(-3.03./(kb * Tg) );
D2 = 1.41e-18 * exp(-1.19./(kb * Tg) ) * sqrt(Fdot);
D3 = 2.e-30 * Fdot;
D = (D1+D2+D3);

%Fission gas release
yield = 0.3017;
gas_produced = t*yield*Fdot; %Gas atoms/cm2
a = 10e-4; %grain size
f = 4*sqrt(D*t/(pi*a^2))-3/2*D*t/a^2;
gas_released = gas_produced*f;
n_gas = vol*gas_released/Na;
y = n_gas/(n + n_gas);

%Calculate coolant T
LHR0 = Q0*pi*Rf^2;
LHR = Q*pi*Rf^2;

Tcool = Tin + (2*gamma/pi)*lngth/2*LHR0/(mdot*CPW)*(sin(pi/(2*gamma)) + sin(pi/(2*gamma)*(zr-1))); %K
   
TCO = Tcool + LHR/(2*pi*Rf*hcool);
TCI = TCO + LHR*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
Ts = TCI + LHR/(2*pi*Rf*hgap);
T0 = Ts + LHR./(4*pi*kcons);
Tfav = Ts + LHR/(8*kcons*pi);

%Densification
Dp0 = 0.01;
Bd = 5/950; %FIMA
rho = 10.97; %g/cm3

%Account for gap closure
ch_clad = alpha_c*(Rf+dg+dc/2)*(Tfav - Tfab);
%Iterate to close the gap
j = 0; 
chng = 1;
Dgap = 0;
while chng > 1e-3
    j = j+1;
    
    Cd = 7.235-0.0086*(Tfav - (25+273.15));
    if Tfav >= 750+273.15
        Cd = 1.0;
    end
    
    eps_th = alpha_f*(Tfav - Tfab);
    eps_dens = Dp0*(exp(Bu*log(0.01)/(Cd*Bd)) - 1);
    eps_sfp = 5.577e-2*Bu*rho*1.28;
    eps_gfp = 1.96e-28*rho*Bu.*(2800-Tfav).^11.73.*exp(-0.0162*(2800-Tfav)).*exp(-17.8*rho*Bu);
    ch_fuel = (eps_th + eps_dens + eps_sfp + eps_gfp)*Rf;
    old_Dgap = Dgap;
    Dgap = ch_clad - ch_fuel;
    ndg = dg + Dgap;
    if ndg < 1e-8
        ndg = 1e-8;
    end
    hgapi = kgap/ndg;
    Ts = TCI + LHR/(2*pi*(Rf+ch_fuel)*hgapi);
    T0 = Ts + LHR/(4*pi*kcons);
    Tfav = Ts + LHR/(8*kcons*pi);
    chng = abs(Dgap - old_Dgap)/abs(old_Dgap);
end

T_bnd = Ts;
end
function FinalProject1p5D_case2
clear
close all
clearvars

global density cp Q Tcool kc hcool dc dg Rf kcons NU Fdotmax q n vol Ef

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

%Pellet dimensions
Rf = 0.41; %cm
npellets = 10;
hpellet = 1.19; %cm
hpl = 0.6;%cm
P = 2e6; %Pa
N = 20; %number of nodes along radius

%Time
tmax = 3600*24*365*2; %seconds
M = 151; %number of time steps

% ----------------------------------------------------------
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);
z = linspace(hpellet/2,hpellet/2+npellets*hpellet,npellets);
zmax = max(z) + hpellet/2;

%Calculate heat generation rate
MU = 235*q + 238*(1-q); %g U/mol
NU = Na*dens_U/MU; %atoms/cm3;
Fdotmax = q*NU*flux*crosssection;
Qmax = Ef*Fdotmax;
LHRmax = Qmax*pi*Rf^2;

%Calculate initial moles of He in gap and plenum
V_wpellets = npellets*hpellet*(pi*(Rf + dg)^2 - pi*Rf^2);
V_plenum = hpl*pi*(Rf + dg)^2;
V = V_wpellets + V_plenum; %cm^3
V = V*(1e-2)^3;
n = P*V/(R*Ti);

%Calculate fuel volume
vol = (pi*(Rf)^2*npellets*hpellet);

% ----------------------------------------------------------
%Loop over the ten pellets
for p = 1:npellets
    %Calculate axially varying properties
    zr = z(p)/(zmax/2);
    LHR = LHRmax*cos(pi/(2*gamma)*(zr-1));
    Q = LHR/(pi*Rf^2);
    
    %Calculate Tcool
    Tcool = Tin + (2*gamma/pi)*zmax/2*LHRmax/(mdot*CPW)*(sin(pi/(2*gamma)) + sin(pi/(2*gamma)*(zr-1))); %K
    
    % ----------------------------------------------------------
    %Solve problem in clyndrical coordinates (m = 1)
    Tp = pdepe(1,@PDEfunction,@ICfunction,@BCfunction,r,t);
    T(p,:,:) = Tp';
end
% ----------------------------------------------------------
% A surface plot is often a good way to study a solution.
[Mr,Mz]=meshgrid(r,z);
figure(1)
surf(Mr, Mz, T(:,:,end), 'edgecolor','none')
set(gca,'fontsize',18)
view(2)
axis equal tight
title('Temperature profile across radius with time')
xlabel('Radius (cm)')
ylabel('height (cm)')
colorbar

Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number

%Compute analytical temperature
TCO = Tcool + LHRmax/(2*pi*Rf*hcool);
TCI = TCO + LHRmax*dc/(2*pi*Rf*kc);
kHe = 16e-6*TCI^0.79;
kXe = 0.7e-6*TCI^0.79;
y = 0.0;
kgap  = kHe^(1-y)*kXe^y;
hgap = kgap/dg;
Ts = TCI + LHRmax/(2*pi*Rf*hgap);
Tm = Qmax*Rf^2/(4*kcons) + Ts;
Tan = Tm - Qmax/(4*kcons)*r.^2;

figure
maxT(:,:) = max(T,[],1);
maxT = max(maxT);
minT(:,:) = min(T,[],1);
minT = min(minT);
plot(t/(24*3600), minT, '-', t/(24*3600),maxT,'-','linewidth',1.5);
set(gca,'fontsize', 18)
xlabel('time (days)')
ylabel('T (K)')
legend('Minimum T','Maximum T','location','southeast')
legend boxoff

M = [t; maxT; minT];
csvwrite('1p5D_case2.csv', M);

end
% --------------------------------------------------------------
function [c,f,s] = PDEfunction(x,t,u,DuDx)
%Properties
global density cp Q NU Ef

%Assign c coefficient
c = density*cp;

%Calculate burnup
Fdot = Q/Ef;
Bu = Fdot*t/NU*950;

%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
%T in celsius
Tc = u - 273.15;

%Calculate k
qf = 0.5*(1 + tanh((Tc-900)/150));
kpstart = 1./(9.592e-2 + 6.14e-3*Bu - 1.4e-5*Bu.^2 + (2.5e-4 - 1.81e-6*Bu).*Tc);
kpend = 1./(9.592e-2 + 2.6e-3*Bu + (2.5e-4 - 2.7e-7*Bu).*Tc);
kel1 = 1.32e-2*exp(1.88e-3*Tc);
k = ((1 - qf).*kpstart + qf.*kpend + kel1)*1e-2;%W/cmK

f = k*DuDx;

s = Q;
end
% --------------------------------------------------------------
function u0 = ICfunction(x)
global Tin;
%Initial temperature
T0 = Tin; %K

%Assign values
u0 = T0*ones(size(x));
end
% --------------------------------------------------------------
function [pl,ql,pr,qr] = BCfunction(xl,ul,xr,ur,t)
%Material properties
global Tcool Q Rf kc hcool dc dg NU n vol Ef;

%Constants
Tfab = 273;
alpha_c = 7.1e-6;
alpha_f = 11e-6;
kb = 8.6173303e-5;
Na = 6.022e23; %atoms/mol

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
kcons = ((1 - qf).*kpstart + qf.*kpend + kel1)*1e-2;%W/cmK

%Fission gas diffusivity
Tg = 1000; %Makes calculation possible
D1 = 7.6e-6*exp(-3.03./(kb * Tg) );
D2 = 1.41e-18 * exp(-1.19./(kb * Tg) ) * sqrt(Fdot);
D3 = 2.e-30 * Fdot;
D = D1+D2+D3;

%Fission gas release
yield = 0.3017;
gas_produced = t*yield*Fdot; %Gas atoms/cm2
a = 10e-4; %grain size
f = 4*sqrt(D*t/(pi*a^2))-3/2*D*t/a^2;
gas_released = gas_produced*f;
n_gas = vol*gas_released/Na;
y = n_gas/(n + n_gas);

%Calculate temperature
LHR = Q*pi*Rf^2;

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
Cd = 7.235-0.0086*(Tfav - (25+273.15));
if Tfav >= 750+273.15
    Cd = 1.0;
end

%Account for gap closure
ch_clad = alpha_c*(Rf+dg+dc/2)*(mean([TCO, TCI]) - Tfab);
%Iterate to close the gap
j = 0; 
chng = 1;
Dgap = 0;
while chng > 1e-4
    j = j+1;
    
    Cd = 7.235-0.0086*(Tfav - (25+273.15));
    if Tfav >= 750+273.15
        Cd = 1.0;
    end
    
    eps_th = alpha_f*(Tfav - Tfab);
    eps_dens = Dp0*(exp(Bu*log(0.01)/(Cd*Bd)) - 1);
    eps_sfp = 5.577e-2*Bu*rho;
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

%Assign values
pl = 0; %This gets ignored
ql = 0; %This gets ignored
pr = ur-Ts;
qr = 0;
end

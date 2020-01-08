function rod_temp_profile_1D
clc
clear
close all
global density cp Q Tb k kc h tc tgap Rf Ts NU Ef crosssection Tco Tci y time_ss

% ----------------------------------------------------------
%Material Properties
k=0.03;
density = 10.98; %g/cm3, density of UO2
cp = 0.325; %J/(g K), specific heat of UO2
Rf=0.5;     %cm
tc=0.065;   %cm
tgap=30e-4; %cm
h=2.5;      %W/cm2K
kc=0.17;    %W/cmK

% ----------------------------------------------------------
%Heat Generation Rate (W/cm3)
Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235
dens_U = 9.65; %g/cm3, density of U in UO2
q = 0.04; %Enrichment
Na = 6.022e23; %atoms/mol, Avagadro's number

% ----------------------------------------------------------
%Calculate necessary parameters
MU = 235*q + 238*(1-q); %g U/mol
flux = 2.8e13; %n/(cm2 s), Neutron flux in the fuel
NU = q*Na*dens_U./MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;

%Reactor conditions
Tb = 600; %K, surface temperature of the pellet
y=0.1;
Tco=Tb+Q/(2*h)*Rf;
Tci=Tco+Q/(2*kc)*Rf*tc;
k_xe=0.7e-6*(Tci^0.79); %W/cmK
k_he=16.6e-6*(Tci^0.79); %W/cmK
kgap=k_he^(1-y)*k_xe^(y);
hgap=kgap/tgap;
Ts=Tci+Q/(2*hgap)*Rf;

%Pellet radius
Rf = 0.5; %cm
N = 100; %number of nodes along radius

%Time
tmax = 2e4; %seconds
M = 41; %number of time steps

% ----------------------------------------------------------
%Create mesh and time steps
r = linspace(0, Rf, N);
t = linspace(0, tmax, M);
%Compute analytical temperature
Tm = Q*Rf^2/(4*k) + Ts;
Tan = Tm - Q/(4*k)*r.^2;

% ----------------------------------------------------------
%Solve problem in clyndrical coordinates (m = 1)
T = pdepe(1,@PDEfunction,@ICfunction,@BCfunction,r,t);

% A surface plot is often a good way to study a solution.
figure(1)
surf(r, t, T, 'edgecolor','none') 
set(gca,'fontsize',12)
title('Temperature profile across radius with time')
xlabel('Radius (cm)')
ylabel('Time (s)')
zlabel('Temperature (K)')
% A line plot of the temperature at various times, including cladding and coolant.
figure(2)
time_ind = [1 3 11 16 21 41];%actual time: 0 0.1e4 1e4 2e4
solT = T(time_ind,:);
pltt = t(time_ind);
flux=2.8e13*ones(size(pltt));
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*dens_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;
Tco=Tb+Q/(2*h)*Rf;
Tci=Tco+Q/(2*kc)*Rf*tc;
y=0.1;
k_xe=0.7e-6*(Tci.^0.79); %W/cmK
k_he=16.6e-6*(Tci.^0.79); %W/cmK
kgap=k_he.^(1-y).*k_xe.^(y);
hgap=kgap./tgap;
plotT = [solT,[ Tci',Tco',Tb*ones(size(pltt'))]];
rlong = [r,Rf+[tgap,tgap+tc,tgap+2*tc]];

plot(rlong, plotT,'linewidth',1.5)
set(gca,'fontsize', 12)
hold on
plot(r, Tan, 'k--','linewidth',1.5)
title('Temperature profile across radius')
xlabel('Radius (cm)')
ylabel('Temperature (K)')
legend('t = 0 s', 't = 0.1{\times}10^4 s','t = 0.5{\times}10^4 s', 't = 0.75{\times}10^4 s', 't = 1{\times}10^4 s',  't = 2{\times}10^4 s' )
legend boxoff
%Time for Steady State Solution
figure;
for i=1:M-1;
    dT(i,:)=max(T(i+1,:)-T(i,:));
    plot(t(:,i),dT(i,:),'o')
    xlabel('Time (s)')
    ylabel('T_{t+\Deltat}-T_{t} [K]')
    hold on
    if dT(i,:)<0.001
        time_check(i)=i;
    end
        i=i+1;
end
        time_ss=find(time_check>0);
    plot([t(:,time_ss(1,1)) t(:,time_ss(1,1))],[0, 100],'k--')
txt1 = ['\leftarrow time = ',num2str(t(:,time_ss(1,1)),'%.2g'),' s'];
text(t(:,time_ss(1,1)),75,txt1)


%------------------------------------------------------------------------
% Calculate and Plot of all three components of the stress vs radius in the fuel pellet
% at t=2.0e4s
alpha=11e-6; %Thermal Exp. Coeff of UO2
E=200; % Modulus of Elasticity of UO2[GPa] 
v=0.345;
dT= Tm-Ts;
eta=r./Rf;
sigma_star=(alpha*E*dT)/(4*(1-v)); %Sigma Star
sigma_rr=-1*sigma_star*(1-(eta.^2)); %Radial Stress
sigma_tt=-1*sigma_star*(1-(3*(eta.^2))); %Hoop Stress
sigma_zz=-2*sigma_star*(1-(2*(eta.^2))); %Axial Stress
sigma_frac=0.130; %Fracture Stress [GPa]
eta_critical=sqrt((1/3*(1+sigma_frac/sigma_star)));
dist=eta_critical*Rf;
eta_critical1=sprintf('%.2g',eta_critical)
dist1=sprintf('%.2g',dist)
hold on
figure(5)
plot(eta,sigma_rr, eta, sigma_tt, eta, sigma_zz,[0,1], [sigma_frac sigma_frac], '--','linewidth',1.5)
legend ('{\sigma}_{rr}', '{\sigma}_{\theta\theta}', '{\sigma}_{zz}', '{\sigma}_{fr}')
xlabel ('r/Rf')
ylabel ('Stress [GPa]')
hold on
strmin1 = ['{\eta}_{cr} = ',num2str(eta_critical1),'\rightarrow'];
text(eta_critical-0.05,2*sigma_frac,strmin1,'Color','black','FontSize',14);
strmin2 = ['{r}_{cr}= ',num2str(dist1),'cm'];
text(eta_critical+0.02,2*sigma_frac,strmin2,'Color','black','FontSize',14);
x_cor = eta_critical;
y_cor = sigma_frac;
plot(x_cor,y_cor,'-o','Color','black','MarkerFaceColor','red','MarkerSize',14)
end


% --------------------------------------------------------------
%PDE COEFFICIENTS
function [c,f,s] = PDEfunction(x,t,u,DuDx)
%Properties
global density cp Q  NU Ef crosssection 

%Assign values
c = density*cp;
%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
exp1 = exp(-16.35./(u/1000));
k = (100.0./(7.5408 + 17.692*(u/1000) + 3.6142*(u/1000).^2) + (6400./(u/1000).^2.5).*exp1)*0.01; %W/cmK
f = k*DuDx;



if t<1e4
    Q=Ef*NU*crosssection*2.8e9.*t;
elseif t>=1e4
    Q=Ef*NU*crosssection*2.8e13;
end
s = Q;
end

% --------------------------------------------------------------
function u0 = ICfunction(x)
global Tb;
%Initial temperature
T0 = Tb; %K

%Assign values
u0 = T0*ones(size(x));

end
% --------------------------------------------------------------
function [pl,ql,pr,qr] = BCfunction(xl,ul,xr,ur,t)
%Material properties
global Q Tb kc h tc tgap Rf Ts NU Ef crosssection Tco Tci y;

Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235

if t < 1e4;
 Q=Ef*NU*crosssection*2.8e9*t;
 elseif t>=1e4
 Q=Ef*NU*crosssection*2.8e13;
end




%Recalculation of the surface temperature by using Q(t);
Tco=Tb+Q/(2*h)*Rf;
Tci=Tco+Q/(2*kc)*Rf*tc;
k_xe=0.7e-6*(Tci^0.79); %W/cmK
k_he=16e-6*(Tci^0.79); %W/cmK
kgap=k_he.^(1-y)*k_xe.^(y);
hgap=kgap./tgap;
Ts=Tci+Q./(2*hgap).*Rf;

%Assign values
pl = 0; %This gets ignored
ql = 0; %This gets ignored
pr = ur-Ts;
qr = 0;


end
% --------------------------------------------------------------

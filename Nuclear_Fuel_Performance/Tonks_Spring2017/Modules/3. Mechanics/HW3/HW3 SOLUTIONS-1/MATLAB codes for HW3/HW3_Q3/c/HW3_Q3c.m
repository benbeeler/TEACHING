clc; clear all;close all;
%------------------------------------------

rho_U= 9.65;%g U/cm3
Na = 0.6022e24; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
m=1;
for i=1:500;
flux = 2.8e13*i;
phi(m,1)=flux;
q = 0.035;
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*rho_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;
%------------------------------------------
%Relevant parameters
kf = 0.03;
M=100;
Rf=0.5;
LHR=Q*pi*Rf^2;
dr=Rf/M;
tc=0.065;
tg=30e-4;
kc=0.17;
hcool=2.5;
Tcool=600;
%------------------------------------------
%Temperature calculations
Tco=Tcool+Q*Rf./(2*hcool);
Tci=Tco+Q*Rf*tc./(2*kc);
khe=16e-6*Tci.^0.79;
kxe=0.7e-6*Tci.^0.79;
y=0.1;
kgap=khe.^(1-y).*kxe.^y;
hgap=kgap/tg;
Ts=Tci+Q*Rf./(2*hgap);
To=Ts+Q*Rf^2./(4*kf);
Tc(m,1)=To;
Tc(m,2)=Ts;
alpha=11e-6; %Thermal Exp. Coeff of UO2
E=200; % Modulus of Elasticity of UO2[GPa] 
v=0.345;
dT= To-Ts;

sigma_frac=0.130; %Fracture Stress [GPa]
sigma_star=(alpha*E*dT)/(4*(1-v)); %Sigma Star
eta(m,1)=sqrt((1/3*(1+sigma_frac/sigma_star)));
m=m+1;
end
dT_safe=2760-Tc(1,2);
sigma_star_safe=(alpha*E*dT_safe)/(4*(1-v));
eta_safe=sqrt((1/3*(1+sigma_frac/sigma_star_safe)));

plot(phi,eta)
xlabel('{\phi} [n/cm^2-s]')
ylabel('{\eta}')
hold on
eta_limit=sqrt(1/3);
plot([0 flux], [eta_limit eta_limit], 'r--','linewidth',1.5)
strmin = ['{\eta}_{limit} =',num2str(eta_limit)];
text(flux/2,eta_limit-0.002,strmin,'Color','black','FontSize',12);
% hold on
% plot([0 flux], [eta_safe eta_safe], 'g--','linewidth',1.5)
% strmin = ['{\eta}_{safe} =',num2str(eta_safe)];
% text(flux/2,eta_safe-0.002,strmin,'Color','black','FontSize',12);
close all; clc; clear all;
Tmelting=[1132 2865 2850 2860 1665]+273;
%Known parameters from HW-1
rho_U= [19.04, 9.65, 12.97, 13.52, 11.31];%g U/cm3
Na = 0.6022e24; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
flux = 2.8e13;
q = 0.035;
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*rho_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;

%Relevant parameters for Q1
kf = [0.38, 0.03, 0.25, 0.2, 0.23];
M=20;
Rf=0.5;
dr=Rf/M;
tc=0.065;
tg=30e-4;
kc=0.17;
hcool=2.5;
Tcool=600;
%Temperature calculations
Tco=Tcool+Q*Rf./(2*hcool);
Tci=Tco+Q*Rf*tc./(2*kc);
khe=16e-6*Tci.^0.79;
kxe=0.7e-6*Tci.^0.79;
y=0.1;
kgap=khe.^(1-y).*kxe.^y;
hgap=kgap/tg;
Ts=Tci+Q*Rf./(2*hgap);
Tc=Ts+Q*Rf^2./(4*kf);
j=1;
rad=linspace(0, Rf, M);
for i=1:5;
   Tf(j,:)=Ts(i)+Q(i)*(Rf^2-rad.^2)/(4*kf(i));
   j=j+1;
end
%Plotting the Temp. profile
T = [Tf,Tci',Tco',Tcool*ones(size(Tco'))];
r = [rad,Rf+tg,Rf+tg+tc,Rf+tg+tc*4];
dT=Tmelting'-Tf(:,1);
plot(r,T,'linewidth',1.5);
ylabel('Temperature (K)');
xlabel('Radius[cm]')
legend('U_{Metal}','UO_2','UC','UN','U_3Si_2')
hold on
plot([Rf Rf],[600, 1800],'k--')
plot([Rf+tg Rf+tg],[600, 1800],'k--')
plot([Rf+tg+tc Rf+tg+tc],[600, 1800],'k--')
%Checking if Tmelt is exceeded
figure;
bar(dT)
set(gca,'fontsize',12,'xticklabel',{'Metal','UO_2','UC','UN','U_3Si_2'})
ylabel('T_{melt.} - T_{CL}')

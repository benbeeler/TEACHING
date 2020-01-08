%Calculation of thick wall cylinder stresses
clear;
close all

Ro = 0.58; %cm
Ri = 0.52; %cm
E = 80; %Gpa
nu = 0.41;
alpha = 7.1e-6;
DT = 700 - 300;
r = [0:100]/100*(Ro-Ri)+Ri;

delta = Ro - Ri;

%rr stress
sigma_rr = 1/2*DT*alpha*E/(1-nu)*(r/Ri-1).*(1-Ri/delta.*(r/Ri-1));

%tt stress
sigma_tt = 1/2*DT*alpha*E/(1-nu).*(1 - 2*Ri/delta.*(r/Ri-1));

%zz stress
sigma_zz = 1/2*DT*alpha*E/(1-nu).*(1 - 2*Ri/delta.*(r/Ri-1));

figure(1)
plot(r,[sigma_rr;sigma_tt;sigma_zz],'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('r (cm)')
ylabel('Stress (GPa)')
legend('\sigma_{rr}', '\sigma_{\theta \theta}', '\sigma_{zz}')
legend boxoff

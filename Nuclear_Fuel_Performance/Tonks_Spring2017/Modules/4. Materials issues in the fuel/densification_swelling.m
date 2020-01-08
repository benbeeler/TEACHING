2.0e13*3600*24*7*2/2.44e22%Swelling and Densification
clear;
close all;

t = 0:10:3600*24*2*365;
frate = 2.01e13; %fissions/(cm3 s)
deltaU = 9.65; %g U/cm^3
delta = 10.97; %g/cm^3
MU = 238;
Na = 6.022e23;
T = 1600;
TC = T - 273.15;

NU = deltaU*Na/MU;
burnup = t*frate/NU;
tot_dens = 0.01;
beta_D = 5/950;
if TC <= 750
    CD = 7.235 - 0.0086*(TC - 25);
else
    CD = 1;
end
eps_D = tot_dens*(exp(burnup*log(0.01)/(CD*beta_D))-1);

figure
plot(t/(3600*24),eps_D,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (days)')
ylabel('Densification strain')

%Solid fission product swelling
eps_sfp = 5.577e-2*delta*burnup;
figure
plot(t/(3600*24),eps_sfp,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (days)')
ylabel('Solid fission product strain')

%Gaseous fission product swelling
eps_gfp = 1.96e-28*delta*burnup*(2800-T)^11.73.*exp(-0.0162*(2800-T)).*exp(-17.8*delta*burnup);

figure
plot(t/(3600*24),eps_gfp,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (days)')
ylabel('Gaseous fission product strain')
title('T = 1600 K')

eps_tot = eps_D + eps_sfp + eps_gfp;

figure
plot(t/(3600*24),[eps_D; eps_sfp; eps_gfp],'--',t/(3600*24),eps_tot,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (days)')
ylabel('Volumetric strain')
axis tight
legend('Densification','Solid swelling','Gaseous swelling','Total','location','northwest')
legend boxoff
title('T = 800 K')
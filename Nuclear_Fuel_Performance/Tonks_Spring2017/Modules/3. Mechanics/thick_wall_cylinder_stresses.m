%Calculation of thick wall cylinder stresses
clear;
close all

Ro = 0.58; %cm
Ri = 0.52; %cm
p = 9; %MPa
nu = 0.41;
r = [0:100]/100*(Ro-Ri)+Ri;

%rr stress
sigma_rr = -p*((Ro./r).^2-1)./((Ro/Ri)^2-1);

%tt stress
sigma_tt = p*((Ro./r).^2+1)./((Ro/Ri)^2-1);

%zz stress
sigma_zz = p/((Ro/Ri)^2 - 1)*ones(size(r));

figure(1)
plot(r,[sigma_rr;sigma_tt;sigma_zz],'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('r (cm)')
ylabel('Stress (MPa)')
legend('\sigma_{rr}', '\sigma_{\theta \theta}', '\sigma_{zz}')
legend boxoff

%Thin walled cylinders
Rav = (Ro + Ri)/2;
th = (Ro - Ri);
sigma_rr_thin = -p/2*ones(size(r));
sigma_tt_thin = p*Rav/th*ones(size(r));
sigma_zz_thin = p*Rav/(2*th)*ones(size(r));

figure(1)
plot(r,[sigma_rr;sigma_tt;sigma_zz],'linewidth',1.5)
hold on
ax = gca;
ax.ColorOrderIndex = 1;
plot(r,[sigma_rr_thin;sigma_tt_thin;sigma_zz_thin],'--','linewidth',1.5)
set(gca,'fontsize',18)
xlabel('r (cm)')
ylabel('Stress (MPa)')
legend('\sigma_{rr}', '\sigma_{\theta \theta}', '\sigma_{zz}')
legend boxoff



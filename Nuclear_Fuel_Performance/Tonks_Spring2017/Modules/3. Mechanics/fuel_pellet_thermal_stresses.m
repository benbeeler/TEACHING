%Fuel pellet thermal stresses
clear
close all;

%Parameters
DT = 530; %K
E = 200; %GPa
nu = 0.345;
alpha = 11e-6;
stress_f = 0.130; %GPa

%Stress calculation
stress_star = alpha*E*DT/(4*(1-nu));
eta = 0:0.01:1;

sigma_rr = -stress_star*(1 - eta.^2);
sigma_tt = -stress_star*(1 - 3*eta.^2);
sigma_zz = -2*stress_star*(1 - 2*eta.^2);

plot(eta,[sigma_rr; sigma_tt; sigma_zz],'linewidth',1.5)
hold on
plot(eta, ones(size(eta))*stress_f, 'k--','linewidth',1.5)
xlabel('r/R_f')
ylabel('Stress (GPa)')
legend('\sigma_{rr}', '\sigma_{\theta \theta}', '\sigma_{zz}','location','northwest')
legend boxoff
set(gca,'fontsize',18)
text(0.2, stress_f, 'Fracture stress', 'fontsize', 18)
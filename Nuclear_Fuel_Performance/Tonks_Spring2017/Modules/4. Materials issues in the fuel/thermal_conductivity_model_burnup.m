%This computes the thermal conductivity as a functino of burnup and T
clear
close all

T = 500:10:1800;
Bu = 0:1:75;

Tc = T - 273.15;
[Tcm,Bum]=meshgrid(T,Bu);
Rf = 0.5*(1 + tanh((Tcm-900)/150));
kpstart = 1./(9.592e-2 + 6.14e-3*Bum - 1.4e-5*Bum.^2 + (2.5e-4 - 1.81e-6*Bum).*Tcm);
kpend = 1./(9.592e-2 + 2.6e-3*Bum + (2.5e-4 - 2.7e-7*Bum).*Tcm);
kel1 = 1.32e-2*exp(1.88e-3*Tcm);
%kel2 = 6400./(Tcm/1000).^(5/2).*exp(-16.35./(Tcm/1000));

k = (1 - Rf).*kpstart + Rf.*kpend + kel1;

figure
surf(Bum, Tcm, k)
set(gca,'ydir','reverse','xdir','reverse','fontsize',18)
xlabel('Burnup (MWD/kgU')
ylabel('Temperature ({\circ}C)')
zlabel('k (W/(m K)')
axis tight

figure
plot(T,Rf,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Temperature (\circC)')
ylabel('R_f')

figure
surf(Bum, Tcm, kpstart)
set(gca,'ydir','reverse','xdir','reverse','fontsize',18)
xlabel('Burnup (MWD/kgU')
ylabel('Temperature ({\circ}C)')
zlabel('k_{ph1} (W/(m K)')
axis tight

figure
surf(Bum, Tcm, kpend)
set(gca,'ydir','reverse','xdir','reverse','fontsize',18)
xlabel('Burnup (MWD/kgU')
ylabel('Temperature ({\circ}C)')
zlabel('k_{ph2} (W/(m K)')
axis tight
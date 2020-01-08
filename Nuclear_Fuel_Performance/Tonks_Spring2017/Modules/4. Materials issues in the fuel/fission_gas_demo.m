%Fission gas release
clear;
close all;

Na = 6.022e23; %atoms/mol, Avagadro's number
D = 8e-15; %cm2/s
a = 10e-4; %cm

t = 0:1:3600*24*1.5;

%Calculate fraction
f = 6*sqrt(D*t/(pi*a^2)) - 3*D*t/a^2;
fr = 6*sqrt(D*t/(pi*a^2));

figure
plot(t/3600,[f;fr],'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('time (hours)')
ylabel('fraction of released gas')
legend('Full eqn','1st term','location','southeast')
legend boxoff

t = 0:100:3600*24*365*2.5;
f = 6*sqrt(D*t/(pi*a^2)) - 3*D*t/a^2;
flong = 1 - 6/pi^2*exp(-pi^2*(D*t)/a^2);

figure
plot(t/(3600*24),[f;flong],'linewidth',1.5)
hold on
tch = a^2/(D*pi^2);
plot([tch tch]/(3600*24), [0 1],'k--','linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (days)')
ylabel('Fraction of released gas')
legend('Low f expression','High f expression','location','southeast')
legend boxoff
axis tight

%In pile gas release

%Calculate fraction
t = 0:1:3600*24*1.5;
f = 4*sqrt(D*t/(pi*a^2)) - 3/2*D*t/a^2;
fr = 4*sqrt(D*t/(pi*a^2));

figure
plot(t/3600,[f;fr],'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('time (hours)')
ylabel('fraction of released gas')
legend('Full eqn','1st term','location','southeast')
legend boxoff

t = 0:200:3600*24*365*5;
f = 4*sqrt(D*t/(pi*a^2)) - 3/2*D*t/a^2;
tl = 0.5*tch:200:3600*24*365*5;
tau = D*tl/a^2;
flong = 1 - 0.0662./tau.*(1 - 0.93*exp(-pi^2*tau));

figure
plot(t/(3600*24*365),f,tl/(3600*24*365),flong,'linewidth',1.5)
hold on
plot([tch tch]/(3600*24*365), [0 1],'k--','linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (years)')
ylabel('Fraction of released gas')
legend('Low f expression','High f expression','location','southeast')
legend boxoff
axis tight


t = 0:1:3600*24*3;
frate = 2.01e13; %fissions/(cm3 s)
r = 0.5; %cm
h = 1.2; %cm
y = 0.3017;
vol = pi*r^2*h;
gas_production = frate*y*t*vol;
f = 4*sqrt(D*t/(pi*a^2)) - 3/2*D*t/a^2;
gas_released = gas_production.*f;
figure
plot(t/3600,[gas_production;gas_released]/Na,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (hours)')
ylabel('Fission gas (moles)')
legend('Produced','Released','location','northwest')
legend boxoff
axis tight

%DIffusion coefficients
kb = 8.6173324e-5; %eV/K
T = 500:10:2000; %K
D1 = 7.6e-6*exp(-3.03./(kb * T) );
D2 = 1.41e-18 * exp(-1.19./(kb * T) ) * sqrt(frate);
D3 = 2.e-30 * frate;
D = D1+D2+D3;
figure
semilogy(1e4./T,D,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('10^4/T (10^4/K)')
ylabel('D (cm^2/s)')


%This is the second HW problem from HW 4
clear;
close all;

%Input parameters
D0 = 10e-6;%m
Ts = 800;%K
Rf = 4.5e-1;%cm
k = 0.028; %W/cmK
LHR = 250;
r = [0, 1/3, 1]*Rf;

%Part A
%Caclulate the temperature
T = LHR/(4*pi*k)*(1 - r.^2/Rf^2) + Ts;

%Calculate the mobility
M0 = 4.6e-9; %m4 /(Js)
Q = 2.77; %eV
kb = 8.6173303e-5; %eV/kg
M = M0*exp(-Q./(kb*T));

fprintf(1,'Part A, M = %6.2e m^4 J/s\n',M)

%Part B
Dm = 2.23e3*exp(-7620./T)*1e-6; %microns
GBenergy = 1.58; %J/m^2
Mr = 2*M*GBenergy; %m^2/s

max_time = 1*365*24*3600; %seconds
num_steps = 200;
dt = max_time/(num_steps);
for t = 1:3
    D(t,1) = D0;
    for i = 1:num_steps
        growth_rate = Mr(t)*(1/D(t,i) - 1/Dm(t));
        if growth_rate < 0
            growth_rate = 0;
        end
        D(t,i+1) = D(t,i) + dt*growth_rate;
    end
end

figure
time = 0:dt:max_time;
plot(time/(max_time/12),D*1e6,'-','linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (months)')
ylabel('Average grain size ({\mu}m)')
legend('r = 0.0 cm','r = 0.15 cm','r = 0.45 cm','location','northwest')
legend boxoff

%Part C
Tmin = -7620/log(10/2.23e3);
rmin = Rf*sqrt(1 - (Tmin - Ts)*4*pi*k/LHR)
fprintf(1,'Grain growth stops at a radius of %f cm\n',rmin)


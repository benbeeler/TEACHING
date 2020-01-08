%Grain growth example
clear;
close all

D0 = 10e-6;
T = 1600;
M0 = 9.2124e-09/2
Q = 2.77;
GB_energy = 1.58;
kb = 8.6173303e-5;
R = 8.314;

%Calculate the mobility
M = M0*exp(-Q/(kb*T));
k = 2*M*GB_energy;
kalt = 5.24e7 * exp( -2.67e5 / ( R * T ))*(1e-6)^2/3600;
Dm = 2.23e3*exp(-7620/T)*1e-6;

max_time = 1*365*24*3600; %seconds
num_steps = 200;
dt = max_time/(num_steps);
D(1) = D0;
for i = 1:num_steps
    growth_rate = k*(1/D(i) - 1/Dm);
    if growth_rate < 0
        growth_rate = 0;
    end
    D(i+1) = D(i) + dt*growth_rate;
end

time = 0:dt:max_time;
timef = 0:max_time/10:max_time;
%plot(time,D*1e6,timef,(2*k*timef+D0^2).^(1/2)*1e6,'*','linewidth',1.5)
plot(time/(max_time/12),D*1e6,'-','linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (months)')
ylabel('Average grain size ({\mu}m)')

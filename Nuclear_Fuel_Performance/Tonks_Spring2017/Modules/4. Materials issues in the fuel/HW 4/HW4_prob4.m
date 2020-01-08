%Problem 4 from HW 4
clear;
close all;

Rf = 0.41; %m;
th_gap = 80.0e-4; %m;
th_clad = 0.57e-1; %m
Tfab = 300;
Ts = 800;
Tcool = 580;
hcool = 2.5;
flux = 2.75e13; %neutrons/cm2s
q = 0.042;
MU = 238; %g U/mol
dU = 9.65;%g U/cm3
Na = 6.022e23; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
k = 0.03; %W/(cm K)
kc = 0.17;
trmp = 3600*3;
ttot = 24*3600*365*2+trmp;
alpha_f = 11e-6;
alpha_c = 7.1e-6;
rho = 10.97; %g/cm3

tv_rmp = 0:10:trmp;
tv_armp = trmp:200:ttot;
tv = [tv_rmp, tv_armp];

NU = q*Na*dU/MU; %atoms/cm3;
Fdotmax = NU*flux*crosssection;
Fdot = [tv_rmp*Fdotmax/trmp,Fdotmax*ones(size(tv_armp))];
Q = Ef*Fdot;
LHR = Q*pi*Rf^2;
avDT = LHR/(8*k*pi);
avT = Ts + avDT;

burnup_rmp = q*flux*crosssection/trmp/2*tv_rmp.^2;
burnup_armp = burnup_rmp(end) + q*flux*crosssection*(tv_armp-trmp);
burnup = [burnup_rmp,burnup_armp];

%Calculate th expansion
eps_th = alpha_f*(avT - Tfab);

%Calculate densification
Dp0 = 0.01;
Bd = 5/950; %FIMA
Cd = ones(size(avT));
Cd(avT<750+273.15) = 7.235-0.0086*(avT(avT<750+273.15)-(25+273.15));
eps_dens = Dp0*(exp(burnup*log(0.01)./(Cd.*Bd)) - 1);

%Solid fission product swelling
eps_sfp = 5.577e-2*burnup*rho;

%Gaseous fission product swelling
figure
eps_gfp = 1.96e-28*rho*burnup.*(2800-avT).^11.73.*exp(-0.0162*(2800-avT)).*exp(-17.8*rho*burnup);
plot(tv/(3600*24), eps_th + eps_dens + eps_sfp + eps_gfp,'linewidth',1.5)
set(gca,'fontsize',18)
xlabel('Time (hours)')
ylabel('Swelling strain')
axis tight

%Part B
LHR = LHR(end);
%Temperature calc
%Coolant
TCO = Tcool + LHR/(2*pi*Rf*hcool);
%Clad
TCI = TCO + LHR*th_clad/(2*pi*Rf*kc);
%Gap
kHe = 16e-6*TCI.^0.79;
kgap = kHe;
hgap = kgap/th_gap;
Ts = TCI + LHR./(2*pi*Rf*hgap);
ch_clad = alpha_c*(Rf+th_gap+th_clad/2)*(mean([TCO, TCI]) - Tfab);

%Pellet
T0 = Ts + LHR./(4*pi*k);
avT = Ts + avDT(end);
ch_gap = 0;
%Iterate to close the gap
j = 0; chng = 1;
fprintf(1,'%d, hgap = %f, th_gap = %g, Ts = %f, and T0 = %f\n',j, hgap, th_gap, Ts, T0)
while chng > 1e-3
    j = j+1;
    eps_th = alpha_f*(avT(end) - Tfab);
    eps_dens = Dp0*(exp(burnup(end)*log(0.01)./(1.*Bd)) - 1);
    eps_sfp = 5.577e-2*burnup(end)*rho;
    eps_gfp = 1.96e-28*rho*burnup(end).*(2800-avT(end)).^11.73.*exp(-0.0162*(2800-avT(end))).*exp(-17.8*rho*burnup(end));
    ch_fuel = (eps_th + eps_dens + eps_sfp + eps_gfp)*Rf;
    old_ch_gap = ch_gap;
    ch_gap = ch_clad - ch_fuel;
    nth_gap = th_gap + ch_gap;
    if nth_gap < 1e-8
        nth_gap = 1e-8;
    end
    hgap = kgap/nth_gap;
    Ts = TCI + LHR/(2*pi*(Rf+ch_fuel)*hgap);
    T0 = Ts + LHR/(4*pi*k);
    avT = Ts + avDT(end);
    fprintf(1,'%d, hgap = %f, dg = %g, Ts = %f, and T0 = %f\n',j, hgap, nth_gap, Ts, T0)
    chng = abs(ch_gap - old_ch_gap)/abs(old_ch_gap);
end
new_dg = nth_gap;
r = (0:10)/10*Rf;
for i = 1:length(k)
    Tf(i,:) = LHR(i)./(4*pi*k(i))*(1-r.^2./Rf.^2) + Ts(i);
end
temps = [Tf,TCI',TCO',Tcool*ones(size(TCO'))];
r = [r,Rf+mean(new_dg),Rf+mean(new_dg)+th_clad,Rf+mean(new_dg)+th_clad*4];

figure
set(gcf,'units','inches','position',[1,1,6,4])
plot(r,temps,'linewidth',2);
axis tight
xlabel('r (cm)')
ylabel('T (k)')
hold on
plot([Rf Rf],[min(temps(:)), max(temps(:))],'k--')
plot([Rf+nth_gap Rf+nth_gap],[min(temps(:)), max(temps(:))],'k--')
plot([Rf+nth_gap+th_clad Rf+nth_gap+th_clad],[min(temps(:)), max(temps(:))],'k--')
set(gca,'fontsize',18)
legend boxoff
title('HW 2, problem 1')

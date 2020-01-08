 clc; clear all;close all;
%------------------------------------------
%Known parameters from HW-1
Data=string({'Umetal'; 'UO2';'UC';'UN';'U3Si2'});
for j=1:5
info=[19.04, 9.65, 12.97, 13.52, 11.31;0.38, 0.03, 0.25, 0.2, 0.23;13.9e-6, 11e-6, 10.5e-6, 7.5e-6, 16e-6];
% prompt='Choose fuel type(1-Umetal, 2-UO2, 3-UC, 4-UN, 5-U3SiO2)? : ';
% selection=input(prompt);
rho_U= info(1,j);%g U/cm3
Na = 0.6022e24; %atoms/mol
Ef = 3e-11; %J/s
crosssection = 5.5e-22; %cm2
flux = 2.8e13;
q = 0.035;
MU = 235*q + 238*(1-q); %g U/mol
NU = q*Na*rho_U/MU; %atoms/cm3;
Q = Ef*NU*flux*crosssection;
%------------------------------------------
%Relevant parameters
kf = info(2,j);
M=100;
Rf=0.5;
LHR=Q*pi*Rf^2;
dr=Rf/M;
tc=0.065;
tg=30e-4;
kc=0.17;
hcool=2.5;
Tcool=600;
%------------------------------------------
%Temperature calculations
Tco=Tcool+Q*Rf./(2*hcool);
Tci=Tco+Q*Rf*tc./(2*kc);
khe=16e-6*Tci.^0.79;
kxe=0.7e-6*Tci.^0.79;
y=0.1;
kgap=khe.^(1-y).*kxe.^y;
hgap=kgap/tg;
Ts=Tci+Q*Rf./(2*hgap);
To=Ts+Q*Rf^2./(4*kf);

r=linspace(0, Rf, M);
T1=Ts+Q*(Rf^2-r.^2)/(4*kf);

%------------------------------------------
%Calculations for HW3 Q1
%------------------------------------------
%Relevant parameters
Tfab=300; %K
Tfave=(To+Ts)/2; %K
Tcave=(Tco+Tci)/2; %K
alphac=7.1e-6; %1/K
alphaf=info(3,j); %%1/K Umetal
Rc=Rf+tg+tc/2;
%-------------------------------------------
%Initial state t=0;
dRc=Rc*alphac.*(Tcave-Tfab);

dgap=0;

%-------------------------------------------
% Temperature Iteration
i=0; chng=1; m=1;
while chng>1e-3
    i=i+1;
    dRf=alphaf*Rf*((Ts+To)/2-Tfab);
    old_dgap=dgap;
    dgap=dRc-dRf;
    tgnew=tg+dgap;
    if tgnew<1e-8
        tgnew=1e-8;
    end
    hg=kgap/tgnew;
    Ts=Tci+LHR/(2*pi*(Rf+dRf)*hg);
    To=Ts+LHR/(4*pi*kf);
    chng=abs(dgap-old_dgap)/old_dgap;
end

T2=Ts+Q*(Rf^2-r.^2)/(4*kf);
T1 = [T1,Tci',Tco',Tcool*ones(size(Tco'))]; %without thermal expansion
T = [T2,Tci',Tco',Tcool*ones(size(Tco'))]; %with thermal expansion
r = [r,Rf+tg,Rf+tg+tc,Rf+tg+tc*4];

tgap(j,:)=tgnew;

%Plotting the temperature profiles
subplot(3,2,j)
plot(r,T1,'b','linewidth',1.5)
hold on
plot(r,T,'r--','linewidth',1.5)
title([char(Data(j))])
legend('no thermal expansion', 'thermal expansion')
xlabel('radius [cm]')
ylabel('Temperature [K]')

plot([Rf Rf],[600, T1(1)],'k--')
plot([Rf+tgnew Rf+tgnew],[600, T1(1)],'k--')
plot([Rf+tgnew+tc Rf+tgnew+tc],[600, T1(1)],'k--')

%Calculation the centerline temperature difference
xt = [0 0];
yt = [(T1(1)+T2(1))/2 (T1(1)+T2(1))/2];
strmin = ['{\Delta}T = ',sprintf('%.1f',T1(1)-T2(1))];
text(0,(T1(1)+T2(1))/2,strmin,'Color','black','FontSize',10);
end
%Final gap width plot
subplot(3,2,6)
bar(tgap*10^4)
set(gca,'fontsize',12,'xticklabel',{'Metal','UO_2','UC','UN','U_3Si_2'})
ylabel('tgap [{\nu}m]')
title('Final gap width')

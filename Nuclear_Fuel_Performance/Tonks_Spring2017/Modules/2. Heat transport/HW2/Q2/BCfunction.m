function [pl,ql,pr,qr] = BCfunction(xl,ul,xr,ur,t)
%Material properties
global Q Tb kc h tc tgap Rf Ts NU Ef crosssection Tco Tci y;

Ef = 3e-11; %J/s, energy released per fission
crosssection = 5.5e-22; %cm2, thermal crosssection for U-235

if t < 1e4;
 Q=Ef*NU*crosssection*2.8e9*t;
 elseif t>=1e4
 Q=Ef*NU*crosssection*2.8e13;
end




%Recalculation of the surface temperature by using Q(t);
Tco=Tb+Q/(2*h)*Rf;
Tci=Tco+Q/(2*kc)*Rf*tc;
k_xe=0.7e-6*(Tci^0.79); %W/cmK
k_he=16e-6*(Tci^0.79); %W/cmK
kgap=k_he.^(1-y)*k_xe.^(y);
hgap=kgap./tgap;
Ts=Tci+Q./(2*hgap).*Rf;

%Assign values
pl = 0; %This gets ignored
ql = 0; %This gets ignored
pr = ur-Ts;
qr = 0;


end
% --------------------------------------------------------------

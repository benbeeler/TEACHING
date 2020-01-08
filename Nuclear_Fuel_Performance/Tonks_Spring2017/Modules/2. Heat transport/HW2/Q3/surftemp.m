function Ts=surftemp(region,state) 
global Q mdot kc Rf tc tg Tin Zo h pigam LHRo
cpw = 4200; %J/(g K), specific heat of UO2
AA=Zo*LHRo/(mdot*cpw);
Tcool=Tin+AA.*sin(pigam) + sin(pigam*(region.y/Zo - 1));
% Tco = Tcool + Q(region.y)*Rf/(2*h);
Tci = Tcool + Q(region.y)*Rf./(2*h) + Q(region.y)*Rf*tc./(2*kc);
kHe = 16e-6*Tci.^0.79;
kXe = 0.7e-6*Tci.^0.79;
y = 0.1;
kgap  = kHe.^(1-y).*kXe.^y;
hgap = kgap./tg;
Ts = Tci + Q(region.y)*Rf./(2*hgap);
end
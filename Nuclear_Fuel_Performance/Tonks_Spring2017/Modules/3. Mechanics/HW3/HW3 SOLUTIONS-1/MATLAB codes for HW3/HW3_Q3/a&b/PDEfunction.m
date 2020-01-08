%PDE COEFFICIENTS
function [c,f,s] = PDEfunction(x,t,u,DuDx)
%Properties
global density cp Q  NU Ef crosssection 

%Assign values
c = density*cp;
%Temperature dependent thermal conductivity, corrected to full density, with fission gas correction
exp1 = exp(-16.35./(u/1000));
k = (100.0./(7.5408 + 17.692*(u/1000) + 3.6142*(u/1000).^2) + (6400./(u/1000).^2.5).*exp1)*0.01; %W/cmK
f = k*DuDx;



if t<1e4
    Q=Ef*NU*crosssection*2.8e9.*t;
elseif t>=1e4
    Q=Ef*NU*crosssection*2.8e13;
end
s = Q;
end
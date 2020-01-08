function u0 = ICfunction(x)
global Tb;
%Initial temperature
T0 = Tb; %K

%Assign values
u0 = T0*ones(size(x));

end
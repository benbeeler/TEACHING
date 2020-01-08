%Example lecture 23
k=5e-8;
rhod = 1e10; %cm-2
Z = 10;
nu = 1e13;
D0 = 0.01; %cm2/s
EmV = 1.0;
EmI = 0.5;
kb = 8.6173324e-5;
T = 573;

%Calculate
DI = D0*exp(-EmI/(kb*T))
DV = D0*exp(-EmV/(kb*T))
KIV = Z*nu*exp(-EmI/(kb*T))
kI2 = 1.02*rhod
kV2 = 1*rhod
Xi = 4*k*KIV/(kI2*kV2*2*DI*DV)

%CI
if (Xi < 1)
    CI = k/(1.02*DI*rhod)
    CV = k/(1*DV*rhod)
else
    CI = kV2*DV/(2*KIV)*sqrt(Xi)
    CV = kI2*DI/(2*KIV)*sqrt(Xi)
end
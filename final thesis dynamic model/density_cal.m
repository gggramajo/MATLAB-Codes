% this function calculates the standard day conditions in whihc the vehicle
% is flying 
% This function assumes that the celing level of the UAV is less than the
% first atmospheric layer
function rho=density_cal(alt)
rho_sea=1.225; %kg/m^3 (sea level density) 
g=9.81; %m/s^2 (gravity) 
T_s=288.16; %K (sea level temperature)
a=-6.5*10^(-3); %K/m 
T=T_s+a*(alt); %m
R=287; %
rho=rho_sea*(T/T_s)^(-((g/(a*R))+1));
end
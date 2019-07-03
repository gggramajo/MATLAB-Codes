aileron=-45:5:45;
rudder=-45:5:45;

for jj=1:length(rudder)
    delCy(1,jj)=.157*pi/180*rudder(jj);
end
for jj=1:length(rudder)
    for kk=1:length(aileron)
        delCl(jj,kk)=.134*pi/180*aileron(kk)+.107*pi/180*rudder(jj);
        delCn(jj,kk)=-.0035*pi/180*aileron(kk)-.072*pi/180*rudder(jj);
    end
end
save bank_turn aileron rudder delCy delCl delCn
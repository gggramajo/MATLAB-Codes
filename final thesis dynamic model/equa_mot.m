function dy=equa_mot(t,y,p)
dy=zeros(3,1);
dy(1)=p(1)*cos(y(3));
dy(2)=p(1)*sin(y(3));
dy(3)=p(2);
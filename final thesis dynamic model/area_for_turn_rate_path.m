function [Xc,Yc]=area_for_turn_rate_path(path,xc,yc)
H=size(path,1);
x=path(1,1);
y=path(1,2);
x_c=x+xc;
y_c=y+yc;
[XC,YC]=poly2cw(x_c,y_c);
Xt=XC;
Yt=YC;
for ct=2:1:H
    x=path(ct,1);
    y=path(ct,2);
    x_circle=x+xc;
    y_circle=y+yc;
    [xx,yy]=poly2cw(x_circle,y_circle);
    [XXC,YYC]=polybool('union',Xt,Yt,xx,yy);
    Xt=XXC;
    Yt=YYC;
end
Xc=Xt;
Yc=Yt;
end
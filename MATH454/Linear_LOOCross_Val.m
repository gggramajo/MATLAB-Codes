function CV=Linear_LOOCross_Val(X,Y,n)
%performs leave one out cross validation

b=(X'*X)\X'*Y;
H=X*(X'*X)\X';
y_hat=X*b;
CV=1/n*sum(((Y-y_hat)./(1-diag(H))).^2);
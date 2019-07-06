function CV=Cross_Val(X,Y,n)
%this function performs the cross validation n amounts

S=X*(X'*X)^-1*X';
y_hat=S*Y;
CV=1/n*sum(((Y-y_hat)./(1-diag(S))).^2);
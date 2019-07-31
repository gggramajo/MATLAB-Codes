function CV=Cross_Val(X,Y,n)
%this function performs the cross validation n amounts

c=cvpartition(length(X),'kfold',n);
MSE=zeros(c.NumTestSets,1);

for ii=1:c.NumTestSets
    train_x=X(training(c,ii),:);
    train_y=Y(training(c,ii));
    test_x=X(test(c,ii),:);
    test_y=Y(test(c,ii),:);
    b=(train_x'*train_x)\train_x'*train_y;
    SSR=(test_y-test_x*b).^2;
    MSE(ii)=SSR/length(test_x);
end
CV=mean(MSE);
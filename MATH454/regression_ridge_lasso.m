clear
clc


R=importdata('CompanyBill.txt');   %imports the data from a txt file extension 
B=all(R.data,2);                    %identifies rows with missing data value of 0 - zero data in the row  1 - nonzero data in the row
row=find(B==1);                    %finds the rows without missing data                    
DATA=R.data(row,:);                %copies data without any missing data
X=DATA(:,2:end);                   %predictors
x=[ones(length(X),1) X];
Y=DATA(:,1);                       %response
mu_0=sum(Y)/length(Y);
C=(x'*x)\(x'*Y);
ds=dataset;
ds.linear=C;
index=dec2bin(1:63);
index=index=='1';
results=[ones(length(index),1) double(index)];
results(:,8)=zeros(length(index),1);


%performs best subset
%generates the regression models for best subset
for ii=1:length(index)
    foo=index(ii,:);
    regf=@(XTRAIN,YTRAIN,XTEST)(XTEST*regress(YTRAIN,XTRAIN));
    results(ii,8)=crossval('mse',X(:,foo),Y,'predfun',regf);
end
index=sortrows(results,8);
%compares results
beta=regress(Y,x(:,logical(index(1,1:7))));
Subset=zeros(7:1);
ds.Subset=Subset;
ds.Subset(logical(index(1,1:7)))=beta;
disp(ds)



%performs forward stepwise
TSS=(Y-mu_0)'*(Y-mu_0);
sigma_sq=TSS/(length(X)-1);
pre=zeros(length(X),6);                       
predictors_num=1:6;
pred_used=zeros(1,6);                         %keeps a list of the predictors used
RSS=zeros(6,1);
adjusted_R2=zeros(6,1);
R2=zeros(6,1);
BIC=zeros(6,1);
for ii=1:6
    cal_RSS=zeros(7-ii,1);
    X_d=X(:,predictors_num);
    for jj=1:7-ii
        predictors=pre(:,1:ii);
        predictors(:,ii)=X_d(:,jj);
        X_data=[ones(length(X),1) predictors];
        coef=(X_data'*X_data)\(X_data'*Y);
        pred_Y=X_data*coef;
        error=Y-pred_Y;
        cal_RSS(jj)=error'*error;    
    end
    RSS(ii)=min(cal_RSS);
    R2(ii)=1-RSS(ii)/TSS;
    adjusted_R2(ii)=1-(RSS(ii)/(length(X)-ii-1))/(TSS/(length(X)-1));
    BIC(ii)=1/length(X)*(RSS(ii)+log(length(X))*ii*sigma_sq);
    selec_pred=find(cal_RSS==min(cal_RSS));
    pred_used(ii)=predictors_num(selec_pred);
    predictors_num=predictors_num(pred_used(ii)~=predictors_num);
    pre(:,ii)=X(:,pred_used(ii));
end
figure(1)
plot(RSS)
hold on
ylabel('R square')
xlabel('# of predictors')
hold off
figure(2)
plot(adjusted_R2)
hold on 
ylabel('adjusted R square')
xlabel('# of predictors')
hold off
figure(3)
plot(BIC)
hold on 
ylabel('BIC')
xlabel('# of predictors')
hold off


%performs ridge regression
%randomly samples half of the data 
train_index=sort(randperm(length(X),length(X)/2));
training_data_x=X(train_index,:);
Train_X=[ones(length(training_data_x),1) training_data_x];
index_id=ismember(X,training_data_x,'rows');
test_data_x=X(~index_id,:);
Test_X=test_data_x-mean(test_data_x);
training_data_y=Y(train_index,:);
test_data_y=Y(~index_id,:);
lambda=0:.01:100;
OUTputs=zeros(6,length(lambda));
REsults=zeros(length(lambda),1);
mean_x=mean(training_data_x)
mean_y=mean(training_data_y)
X_bar=training_data_x-mean_x
for ii=1:length(lambda)
    OUTputs(:,ii)=(X_bar'*X_bar+lambda(ii)*eye(6))\X_bar'*training_data_y;
    REsults(ii)=mean((test_data_y-(mean_y+Test_X*OUTputs(:,ii))).^2+lambda(ii)*OUTputs(:,ii)'*OUTputs(:,ii));
end
Best_Coef=OUTputs(:,find(REsults==min(REsults)))
find(REsults==min(REsults))

%performs Lasso
[B,fitinfo]=lasso(training_data_x,training_data_y,'CV',5,'PredictorNames',{'x1','x2','x3','x4','x5','x6'});

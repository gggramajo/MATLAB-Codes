%This code implements a simple linear regression model for customer's
%average waiting time vs. number of cshiers in service
%
%The code calculates the least square coefficients using the following
%function:
%
%    y=a+bx
%
%and obtaing the partial derivatives of the square of the function above.
%The partial derivative reuslting in the following function:
%
%             [n sum(x);sum(x) sum(x^2)]*[a;b]=[sum(y);sum(x*y)]
%               which is simplified to A*coef=B
%

clear
clc
N=15;                                                         %number of cashiers
Data_x=[3 4 5 6 8 10 12];                                     %data of number of cashiers in service
Data_y=[16 12 9.6 7.9 6 4.7 4];                               %data of avg waiting time in min 
A=[length(Data_x) sum(Data_x);sum(Data_x) sum(Data_x.^2)];    %creates matrix A
B=[sum(Data_y);sum(Data_x.*Data_y)];                          %creates vector
coef=A^-1*B;                                                  %calculates the least square coefficients 


pre=coef(1)+coef(2)*Data_x;                                   %prediction of the customer's average waiting time for the cashier data 
cashiers_open=1:15;
predicted_wait_time=coef(1)+coef(2)*cashiers_open;
scatter(Data_y,Data_x)
hold on 
plot(cashiers_open,predicted_wait_time,'-r')
legend('DATA','Least Square')
ylabel('average waiting time (min)')
xlabel('cashier avaible')
hold off

%calculates the Standard Error of the coefficients
x_bar=mean(Data_x);                                           %average value of X
S_x=sum((Data_x-mean(Data_x)).^2);                            %calculates the variance of x
S_y=sum((Data_y-mean(Data_y)).^2);
S_xy=sum((Data_x-mean(Data_x)).*(Data_y-mean(Data_y)));
error=Data_y-pre;                                              %error between the actual waiting time and the fitted point 
S=sqrt(sum(error.^2)/(length(Data_x)-2));                      %estimation of the variance 
error_a=S*sqrt(1/length(Data_x)+x_bar^2/S_x);                   %error of coefficient a
error_b=S/sqrt(S_x);                                            %error of coefficient b


%Calculates the 95% confidence interval 
a_low_limit=coef(1)-1.96*error_a;
a_upper_limit=coef(1)+1.96*error_a;
b_low_limit=coef(2)-1.96*error_b;
b_upper_limit=coef(2)+1.96*error_b;

%calculates the 95% pediction interval of the average waiting time 
a=[a_low_limit;a_upper_limit];
b=[b_low_limit;b_upper_limit];
pred_val=zeros(1,4);
for ii=1:2
    for jj=1:2
        count=2*(ii-1)+jj;
        pred_val(count)=a(jj)+b(ii)*15;
    end
end
pred_interval=[min(pred_val);max(pred_val)];
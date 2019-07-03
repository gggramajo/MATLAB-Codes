%This code compares estimates variables
%the code demonstrates that as the # of variables reaches infinity the 

clear
clc
rng(1)                         %control the random number generator
n=1000;                        %the number of variables (terms/elements)
Z=randn(n,1);                  %generates the random vector for variable Z, with 1000 terms/elements
Z_bar=zeros(n,1);              %initializes variable Z_bar
sum=0;                         %initializes variable sum 

%used a for loop to calculate the averages of variable Z from element 1 to 1000  
for ii=1:n
    sum=sum+Z(ii);
    Z_bar(ii)=sum/ii;
end
plot(1:n,Z_bar)                 %plots the averages of variable Z with respect to the amount of terms/elements 
hold on 
plot([0 n],[0 0],'r')           %plots y=0
hold off

A=repmat(Z(1:100),1,1000);      %copies the first 100 of variable Z 1000 times
B=mean(median(A,2));            %calculates the mean of the median of the 100 first elements of variable Z
                                %shows that the sample median of the
                                %samples is an unbiased estimate of 0

                                
C=var(Z_bar);                   %calculates the variace of the averages of the elements in variable Z_bar
D=var(median(A,2));             %calculates the variance of the sample data

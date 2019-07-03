%This code implements the law of large numbers (law of averages) for two
%fair dices. The law of averages states that as the # of indentically
%distributed variables increases, randomly generated, the sample mean
%approaches the theoretical mean.
%
%The program approximates the probability of obtaining the event "sum of
%the two outcomes is equal to 6" for the two fair dices

clear
clc
rng(1)                                 %controls random number generation
X1=randi([0 6],1000);                  %value of the first dice
X2=randi([0 6],1000);                  %value of the second dice
X=X1+X2;                               %sum of the two dices
sum=0;                                 %initializes the variable sum
P=zeros(1000,1);                       %initializes vector P for 1000 elements

%uses a for loop to calculate the sum of events in which the sum of the two
%dices is equal to 6
for ii=1:1000
    %uses an if statement to determine the event in which the sum of the two dices is equal to 6 
    if X(ii)==6
        sum=sum+1;
    end 
    %calculates the probability that the sum of the dices is 6
    P(ii)=sum/ii;
end
plot(1:1000,P)                          %plots the sequence 
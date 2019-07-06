%This code implements leave one out cross validation for linear or
%polynomial regression 

%The is suppose to measure the odor in a chemical process by relating three
%variables temperature, ratio, and height

clear 
clc

fileID=fopen('odor.txt','r');                           %obtains file id and opens file    
C=textscan(fileID,'%f %f %f %f','headerlines',1);       %imports file odor
fclose(fileID);                                         %closes file
x=cell2mat(C);                                          %converts the imported data from cell array to a matrix
p=size(x,1);                                            %identifies the lenght of the data for the variables in the data 
x1=ones(p,1);                                           %generates a vector of ones as the constant of the model
Y=x(:,1);                                               %output data
n=1;                                                    %number of folds

%MODEL 1
%Y=a0+a1*x1+a2*x2+a3*x3+a4*x1^2+a5*x2^+a6*x3^2+epsilon
X1=[x1 x(:,2:end) x(:,2:end).^2];
CV1=Cross_Val(X1,Y,n)

%MODEL 2
%Y=a0+a1*x1+a2*x2+a3*x1^2+a4*x2^+epsilon
X2=[x1 x(:,2:end) x(:,1:2).^2];
CV2=Cross_Val(X2,Y,n)

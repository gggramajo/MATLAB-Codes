%This code implements generalized linear regression for Poisson model

clear
clc

FileID=fopen('crab.txt','r')
C=textscan(FileID,'%f %f %f %f %f %f', 'headerLines',1);
fclose(FileID);
X=cell2mat(C);
Obs=X(:,1);
C=X(:,2);
S=X(:,3);
W=X(:,4);
Wt=X(:,5);
Sa=X(:,6);
b=glmfit([W Wt],Sa,'poisson')


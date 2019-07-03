%The program plots the user defined function for a taylor series and y=e
%The programs proves that the infinte sum of terms for the user defined 
%function for the taylor series is equal to y=e 

clear
clc
X=1:100;                                 %number of terms in the taylor series
Y=Taylor_func(X);                        %values of the taylor series for each amount of terms in the series
plot(X,Taylor_func(X))                   %plots the taylor series with respect to the number of terms in the series
hold on 
plot([0 100],[Y(end) Y(end)],'--r')      %plots y=e
hold off
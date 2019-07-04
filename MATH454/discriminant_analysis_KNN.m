%the script implements discriminat analysis and K-nearest neighbors
%The code attempts to predict the gender of a person from a set of data for
%6 persons that provides the log(weights) for the gender of the person.  


clear 
clc
X=[5 4.7 4.4 5.12 4.3 5.44];                      %log(weight) of the 6 person sample
Y=[1 0 0 0 1 1];                                  %Gender data of the 6 person sample male=1 female=0
P=4.9;                                            %the log(weight) of the seventg person 

male_value=find(Y==1);                                   %find the data entry for males
female_value=find(Y==0);                                 %finds the data entry for female
mu_male=sum(X(male_value))/length(male_value);           %finds the mean for the male data
mu_female=sum(X(female_value))/length(female_value);     %finds the mean for the female data
mu=[mu_male;mu_female];                                  %puts the mean of male and female data into a vector
male_var=sum((X(male_value)-mu_male).^2)/(length(Y)-1);              %Variance of the male data
female_var=sum((X(female_value)-mu_female).^2)/(length(Y)-1);        %variance of the female data
prob_male=length(male_value)/length(X)
prob_female=length(female_value)/length(X)

male_sigma=-1/2*log(male_var)-1/2*P*male_var^-1*P+P*male_var^-1*mu_male-1/2*mu_male*male_var^-1*mu_male+log(prob_male)
female_sigma=-1/2*log(female_var)-1/2*P*female_var^-1*P+P*female_var^-1*mu_female-1/2*mu_female*female_var^-1*mu_female+log(prob_female)


%K_nearest neighbors
K=3
dista=sqrt((X-P).^2)
sorted_dis=sort(dista)
min_K=sorted_dis(1:K)
[Val,pos]=intersect(dista,min_K)
categ=round(sum(Y(pos))/length(pos))

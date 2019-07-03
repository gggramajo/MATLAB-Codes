%This code is a function that generates the Taylor series for y=e
%with the following function
%
%  f(n)=1+1/2!+1/3!+....+1/n!


function Y=Taylor_func(n)
L=length(n);
if L==1
    if n<1
        error('enter value greater than or equal to 1');
    else
        sum=2;
        if n>=1
            for ii=2:n
                value1=1/factorial(ii);
                sum=sum+value1;
            end
        end
    end
else
    sum=zeros(1,L);
    if n<1
        error('enter value greater than or equal to 1');
    else
        for j=1:L
            sum0=2;
            if n(j)>=1
                for ii=2:n(j)
                    value1=1/factorial(ii);
                    sum0=sum0+value1;
                end
            end
            sum(j)=sum0;
        end
    end
end
Y=sum;

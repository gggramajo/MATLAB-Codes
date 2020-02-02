%this code simulates BPSK
clear
clc

N=100000000;               %number of bits
data=round(rand(1,N));       %generates random data bits
bpsk_data=2*data-1;          %BPSK data


SNR=0:10;                    %SNR in dB
snr_lin=10.^(SNR/10);

%initiates vector of signal and receiver 
y=zeros(length(SNR),N);       %initiates signal
Y=zeros(length(SNR),N);       %initiates receiver

%generates noise
noise=1/2*randn(1,N);          %generates random noise
noise_pw=mean(noise.^2);      %calcualtes power of the noise

for ii=1:length(SNR)
    y(ii,:)=sqrt(snr_lin(ii))*bpsk_data+noise;
end


err=zeros(length(SNR),N);
ERR=zeros(length(SNR),1);

for jj=1:length(SNR)
    for kk=1:N
        if y(jj,kk)>=0
            Y(jj,kk)=1;
        else
            Y(jj,kk)=0;
        end
    end
    err(jj,:)=abs(Y(jj,:)-data);
    ERR(jj,:)=length(find(err(jj,:)));
end


%calculates BER
ber=zeros(length(SNR),1);
for ii=1:length(SNR)
    ber(ii)=ERR(ii)/N;
end

theory_BER=.5*erfc(sqrt(snr_lin));
semilogy(SNR,ber,'r--','linewidth',2)
hold on 
semilogy(SNR,theory_BER,'b*-','linewidth',2)
xlabel('Eb/N0')
ylabel('BER')
legend('Simulation','theory')
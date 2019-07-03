clear
clc
A=xlsread('Book1.xlsx','Sheet1','A2:F10');
B=xlsread('Book1.xlsx','Sheet2','A2:F10');

figure (1)
bar(A(:,1),A(:,2:3))
legend('energy optimization','time optimization')
xlabel('turn duration (s)')
ylabel('Percent of area covered (%)')

figure(2)
bar(B(7,1),B(7,3))
legend('time optimization')
xlabel('turn duration (s)')
ylabel('Percent of area covered (%)')

figure (3)
bar(A(:,1),A(:,4:5))
legend('energy optimization','time optimization')
xlabel('turn duration (s)')
ylabel('Distance from esit state (m)')

figure (4)
bar(A(7,1),B(7,5))
legend('time optimization')
xlabel('turn duration (s)')
ylabel('Distance from esit state (m)')

figure (5)
bar(A(:,1),A(:,6),'r')
xlabel('turn duration (s)')
ylabel('mission duration (s)')
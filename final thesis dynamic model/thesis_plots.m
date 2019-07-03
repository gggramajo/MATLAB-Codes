A=xlsread('Book1.xlsx','A2:F10');
plot(A(:,1),A(:,2),A(:,1),A(:,3),'LineWidth',5);
xlabel('\bf{turn duration (s)}')
ylabel('\bf{area covered (%)}')
legend('energy optimization','time optimization')
figure(2)
plot(A(:,1),A(:,4),A(:,1),A(:,5),'LineWidth',5);
xlabel('\bf{turn duration (s)}')
ylabel('\bf{distance from desired exit state (m)}')
legend('energy optimization','time optimization')
figure(3)
plot(A(:,1),A(:,6),'LineWidth',5);
xlabel('\bf{turn duration (s)}')
ylabel('\bf{mission duration (s)}')
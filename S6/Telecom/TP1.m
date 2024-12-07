close all;

Fe = 24000; %Hz
Te = 1/Fe;
Rb = 3000; %bits/s
Tb = 1/Rb;

%---------Modulateur 1-----------
Ts1 = Tb;
Ns1 = floor(Ts1/Te);
n = 10000;
bit1 = randi([0,1],[n,1]);

Symbol1 = 2*bit1 - 1; %-1 ou 1 pour moy nulle
pDirac1 = kron(Symbol1,[1,zeros(1,Ns1-1)]);
h1 = ones(1,Ns1);
x1 = filter(h1,1,pDirac1);
[DSP1,f1] = pwelch(x1,[],[],[],Fe,'twosided', 'centered');


%---------Modulateur 2-----------
Ts2 = 2*Tb
Ns2 = floor(Ts2/Te)
bit2 = randi([0,1],[n,2]);

Symbol2 = 4*bit2(:,1) + 2*bit2(:,2) - 3;
h2 = ones(1,Ns2);
pDirac2 = kron(Symbol2,[1,zeros(1,Ns2-1)]);
x2 = filter(h2,1,pDirac2);
[DSP2,f2] = pwelch(x2,[],[],[],Fe,'twosided', 'centered');

%---------Modulateur 3-----------
Ns3 = Ns1;
bit3 = bit1;

Symbol3 = Symbol1;
pDirac3 = pDirac1;
l = length(pDirac3);
h3 = rcosdesign(0.5,floor(l/Ns3)+1,Ns3);
x3 = filter(h3,1,pDirac3);
[DSP3,f3] = pwelch(x3,[],[],[],Fe,'twosided', 'centered');

%-----------PLOT------------

figure;
subplot(2,1,1);
%plot(0:Te:Te*(length(x1)-1),Symbol1,'blue');
hold on;
plot(0:Te:Te*(length(x2)-1),Symbol2,'red');
hold off;
grid;
title('Signal généré');
xlabel('Temps (s)');
ylabel('Signal');

subplot(2,1,2);
semilogy(f1,DSP1,'blue');
hold on;
semilogy(f2,DSP2,'red');
semilogy(f3,DSP3,'yellow');
hold off;
grid;
title('DSP du signal');
xlabel('Fréquence (Hz)');
ylabel('DSP');
legend('Modulateur 1', 'Modulateur 2');

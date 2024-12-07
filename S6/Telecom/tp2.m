%Nettoyer l'interface
clc;
clear all;
close all;

%Constantes
Fe = 24000;
Rb = 3000;
Tb = 1/Rb;
Nbits = 1000;
Te = 1/Fe;
V = 1;

alpha = 0.2 ;
L = 8;
Te = 1 / Fe;
bits = randi([0 1],1, Nbits);

Symboles1 = 2*bits - 1;

Tsbin =Tb ;
Nsbin = floor(Tsbin / Te);

surech1 = zeros(1,Nsbin);
surech1(1) = 1;

Xk1 = kron(Symboles1,surech1);

%Mise en forme: 
h1=ones(1,Nsbin);
Signal_Filtre1 = filter(h1,1,Xk1);
hr = h1;
g= conv(h1,hr);
z=filter(g,1,Xk1);

% g la convolution de h1 et hr
figure (1);
plot(g);
xlabel("Temps(s)");
ylabel("Amplitude");
title("Signal g");
grid on;

%  z la convolution de xk1 et g 
temps = [0:Te:(length(z)-1)*Te];
figure(2);
plot(temps,z);
xlabel("Temps(s)");
ylabel("Amplitude");
title("Signal passé par le demodulateur bdb");
grid on;
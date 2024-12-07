

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
%Symboles1 = zeros(1,length(bits));
%Symboles1(bits==1) = V;
%Symboles1(bits==0) = -V;

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

%% III.1 Etude sans canal de propagation
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


% explication: g verifie le critére de nyquist pour le choix de t0=Ts



%diagramme de l'oeuil 
diagramme_oeuil = reshape(z,Nsbin,floor(length(z)/Nsbin)) ; 
figure(3);
plot(diagramme_oeuil);
xlabel("Temps(s)");
ylabel("Amplitude");
title("Diagramme de l'oeuil");
grid on;

% explication du choix de l'instant d'echantillonage à partir du diagramme
% de l'oeuil

% echantillonage à t0=Ts 
figure(4);
z_ech = z(Nsbin : Nsbin : end ) ; 
plot(z_ech);
xlabel("Temps(s)");
ylabel("Amplitude");
title("z échantilloné");
grid on;

%% Decision
Seuil = 0;
SymboleDecide = zeros(1,length(z_ech));
SymboleDecide(z_ech>Seuil) = V;
SymboleDecide(z_ech<-Seuil) = -V;

%% echantilloner à n0+mNs avec n0=3
n0=3 ; 
z_ech2 = z(n0 : Nsbin : end ) ; 

%tracé de z_ech2
figure(5);
plot(z_ech2);
xlabel("Temps(s)");
ylabel("Amplitude");
title("z échantilloné à n0+mNs");
grid on;

%% Estimation du TEB du signal échantilloné 
% TEB1
bits_estimes1=zeros(1,Nbits); 
bits_estimes1(z_ech>0) = 1;
TEB1 = sum(bits ~=bits_estimes1)/Nbits ;

% TEB2
bits_estimes2=zeros(1,Nbits); 
bits_estimes2(z_ech2>0) = 1;
TEB2 = sum(bits ~=bits_estimes2)/Nbits ;










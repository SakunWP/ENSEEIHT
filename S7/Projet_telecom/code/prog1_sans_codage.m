%% Paramètres généraux
%on  a une emlleure precision si on a plus d'erreur
clear all
close all

bw = 33000;  %On se place dans le cas de la BW=33 Mhz

% Paramètres du filtre de mise en forme
alpha = 0.35;

% Débit symbole
Rs = bw/(1+alpha);

Ts=1/Rs;
%Débit binaire
Rb = 2*Rs;
%Nombre de bits
N =2000;
% Facteur de suréchantillonage 
Ns = 6; %Ns=Fe*Ts et on prend au dessus
%%Fréquence d'echantillonage (Hz)
Fe=2*bw; 
%%Periode d'echantillonage (s)
Te=1/Fe;
% Génération de bits 
bits = randi(2, 1, N) - 1;
%Rapport signal bruit
EbN0_db=[-4:0.5:4];
EbN0=10.^(EbN0_db./10);
SPAN=6; % Durée du rcosdesign en nombre de période symbole

TEB_liste=zeros(size(EbN0_db));

for i=1:length(EbN0)
    % Mapping QPSK
    symboles=(1-2*bits(1:2:end))+1j*(1-2*bits(2:2:end));

    % Mise en forme
    h_m1 = rcosdesign(alpha, SPAN, Ns, 'sqrt');
    retard = (6 * Ns); %filtre numérique : introduit retard de longueur de moitié de sa longueur
    modulation = [kron(symboles, [1, zeros(1, Ns-1)]) zeros(1,retard)];
    %Le filtre introduit un retard de span * Ns, or les premiers bits ne
    %peuvent pas être utilisés donc on rajoute des 0 et pour pouvoir obtenir toutes les 
    % décisions on rajouter des 0 pour obtenir les informations sur les derniers bits codés.

    signalQPSK=filter(h_m1, 1,modulation);
    

    %Bruit
    Px = mean(abs(signalQPSK).^2);
    sigma2=((Px*Ns)/(2*2*EbN0(i)));
    bruit = sqrt(sigma2) * (randn(size(signalQPSK)) + 1i * randn(size(signalQPSK)));
    signal_bruite = signalQPSK + bruit;
    
    %Signal reception
    signal_recu=filter(h_m1, 1, signal_bruite);

    % Échantillonnage des symboles après correction du retard
    demodulation = signal_recu(retard+1:Ns:end);

    % Décodage QPSK
    detecte=zeros(1,2*length(demodulation));
    detecte(1:2:2*length(demodulation))=real(demodulation)<0;
    detecte(2:2:2*length(demodulation))=imag(demodulation)<0;

    % Calcul des erreurs
    TEB_liste(i)=mean(bits(1:length(detecte))~=detecte);
end


% Tracé du TEB en fonction de Eb/N0
figure;
semilogy(EbN0_db, TEB_liste, 'b','DisplayName', 'TEB AWGN');
xlabel('Eb/N0 (dB)');
ylabel('TEB');
hold on
semilogy(EbN0_db,qfunc(sqrt(2*EbN0)), 'g','DisplayName', 'TEB théorique');
title('Courbe du TEB en fonction de Eb/N0');
legend;
grid on;




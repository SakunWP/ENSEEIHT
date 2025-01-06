%% Paramètres généraux
%on  a une emlleure precision si on a plus d'erreur
clear all
close all
%On se place dans le cas de la BW=33 Mhz
bw = 33000;
%Ns=Fe*Ts
% Paramètres du filtre de mise en forme
alpha = 0.35;
% Débit symbole
Rs = bw/(1+alpha);
% rcosdesign explication : h=rcosdesigne(beta, span, sps)
% la fome est donnée par beta, la durée et le ratio est sps = Ts/Te 
Ts=1/Rs;
%Débit binaire
Rb = 2*Rs;
%Nombre de bits
N =2000;
% Facteur de suréchantillonage 
Ns = 6;
%%Fréquence d'echantillonage (Hz)
Fe=2*bw; 
%%Periode d'echantillonage (s)
Te=1/Fe;
% Génération de bits 
bits = randi(2, 1, N) - 1;
%Rapport signal bruit
EbN0_db=[-4:0.5:4];
EbN0=10.^(EbN0_db./10);



for i=1:length(EbN0)
    % Mapping QPSK
    bits_reshape=reshape(bits, 2, length(bits)/2);
    symboles = pskmod(bits_reshape,4,InputType='bit');

    % Mise en forme
    h_m1 = rcosdesign(alpha, 8, Ns);
    modulation = kron(symboles, [1 zeros(1, Ns-1)]);

    signalQPSK=filter(h_m1, 1,modulation);
    

    % DSP
    %dsp= pwelch(signalQPSK, [], [], [],1,'centered');

    % %Tracé de la DSP
    % figure
    % plot(10*log10(dsp))
    % title('DSP du signal QPSK')
    % legend('DSP QPSK')
    % xlabel('Fréquence (MHz)')
    % ylabel('DSP')
    % grid on;

    %bruit
    Px=mean(abs(signalQPSK).^2);
    sigma2=((Px*Ns)/(2*2*EbN0(i)));

    signal_bruite=signalQPSK+sqrt(sigma2)*randn(1, length(signalQPSK))+1i*sqrt(sigma2)*randn(1, length(signalQPSK));

    %Signal reception
    signal_recu=filter(h_m1, 1, signal_bruite);

    % Retard causé par le filtre
    retard = (8*Ns);

    % Échantillonnage des symboles après correction du retard
    demodulation = signal_recu(retard+1:Ns:end);

    % Décodage QPSK
    detecte = pskdemod(demodulation, 4, OutputType='bit');
    detecte_reshape=reshape(detecte, 1, size(detecte, 1)*size(detecte,2));

    % Calcul des erreurs
    erreurs = bits(1:end-2*retard/Ns) ~= detecte_reshape; % Comparaison bit à bit
    TEB = sum(erreurs) / length(detecte_reshape);
    TEB_liste(i)=TEB;
end


% Tracé du TEB en fonction de Eb/N0
figure;
semilogy(EbN0_db, TEB_liste);
xlabel('Eb/N0 (dB)');
ylabel('TEB');
hold on
semilogy(EbN0_db,qfunc(sqrt(2*EbN0)), 'g')
title('Courbe du TEB en fonction de Eb/N0');
grid on;




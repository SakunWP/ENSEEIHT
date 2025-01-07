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
N =20000;
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

    trellis=poly2trellis(7, [171 133]);
    donnees_codees=convenc(bits, trellis);

    % Mapping QPSK
    bits_reshape=reshape(donnees_codees, 2, length(donnees_codees)/2);
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
    signal_sup_retard=signal_recu(retard+1:end);
    demodulation = signal_sup_retard(1:Ns:end);

    %décodage soft
    demodulation_soft_r=real(demodulation);
    demodulation_soft_i=imag(demodulation);

    demodulation_soft=zeros(1,2*length(demodulation));
    % 
    demodulation_soft(1:2:end)=demodulation_soft_r;
    demodulation_soft(2:2:end)=demodulation_soft_i;
    
    % Décodage QPSK soft
    detecte = pskdemod(demodulation_soft, 4, OutputType='bit');
    detecte_reshape=reshape(detecte, 1, size(detecte, 1)*size(detecte,2));

    tbdepth = 25;
    %decodedData = vitdec(reshape(demodulation_soft, 1, size(demodulation, 1)*size(demodulation,2)),trellis,tbdepth,'trunc','unquant');
    %decodedData = vitdec(demodulation_soft, trellis, tbdepth, 'trunc', 'unquant');
    decodedData = vitdec(real(demodulation), trellis, tbdepth, 'trunc', 'unquant');




    % Calcul des erreurs soft
    %erreurs = bits(1:end-retard/Ns) ~= decodedData; % Comparaison bit à bit
    erreurs = bits(1:length(decodedData)) ~= decodedData;
    TEB = sum(erreurs) / length(decodedData);
    TEB_liste_soft(i)=TEB;

    % decodage hard
    demodulation_hard=real(demodulation)>0;
    demodulation_hard_reshaped = reshape(demodulation_hard, 1, size(demodulation, 1) * size(demodulation, 2));
    decodedData_hard = vitdec(demodulation_hard_reshaped, trellis, tbdepth, 'trunc', 'hard');
    

    % Calcul du TEB hard
    erreurs_hard = bits(1:length(decodedData_hard)) ~= decodedData_hard;
    TEB_hard = sum(erreurs_hard) / length(decodedData_hard);
    TEB_liste_hard(i) = TEB_hard;
end


% Tracé du TEB en fonction de Eb/N0 pour le décodage soft et hard
figure;
semilogy(EbN0_db, TEB_liste_soft, 'b-o');
hold on;
semilogy(EbN0_db, TEB_liste_hard, 'r-s');
semilogy(EbN0_db, qfunc(sqrt(2 * EbN0)), 'g');
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend('TEB Soft', 'TEB Hard', 'TEB Théorique QPSK');
title('Comparaison des TEB Soft et Hard en fonction de Eb/N0');
grid on;




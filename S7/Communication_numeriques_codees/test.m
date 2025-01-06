% clear all;
% close all;
% 
% %% QPSK bande de base
% 
% %% constantes
% rendement = 1/2;
% % B = 1.35 *Rs = 54 * 10^6;
% Rb = 84.4*10^6;
% Fe = Rb;
% Te = 1/Fe;
% Tb = 1/Rb;
% n=2;
% M = 2^n;
% 
% Ts = log2(M)*Tb;
% Rs = Rb/log2(M);
% nb_bits = 1000000 ;
% Ns = Fe * Ts; % Nombre d'échantillons par bits
% 
% EbN0dB = [-4:4];
% EbN0=10.^(EbN0dB./10);
% L= 8;
% h1 = rcosdesign(0.35,L,Ns); % filtre de mise en forme
% hr = fliplr(h1); % filtre de réception
% 
% treillis = poly2trellis(7,[171 133]);
% commcnv_plotnextstates(treillis.nextStates);
% for k=1:length(EbN0)
% 
%     %% modulateur :
%     % Mapping
%     S = randi([0 1],1,nb_bits);
% 
%     Code_codage = convenc(S,treillis);
% 
%     dk = 1-2*Code_codage(1:2:nb_bits*2) +1i * (1-2*Code_codage(2:2:nb_bits*2));
%     At = [kron(dk, [1, zeros(1, Ns-1)]) zeros(1,length(h1))];
% 
%     %% canal 
%     % Filtrage
% 
%     y = filter(h1, 1, At);
%     T1 = ([0:length(y)-1] * Te);
% 
%     %bruit
%     Px = mean(abs(y).^2);
%     sigma2 = ((Px*Ns)/(2*log2(M)*EbN0(k)));
% 
%     y_et_bruit_reel = y + sqrt(sigma2)*randn(1,length(y)); % bruit réel
%     recu = y_et_bruit_reel + 1i *sqrt(sigma2)*randn(1,length(y)); % bruit imaginaire
% 
% 
%     %filtre de récéption
%     z= filter(hr,1,recu);
% 
% 
%     %echantillonage et démapping 
%     xe = z(length(h1):Ns:length(z)-1);
% 
% 
%     xr(1:2:nb_bits*2)=real(xe);
%     xr(2:2:nb_bits*2)=imag(xe);
% 
%     xr_h(1:2:nb_bits*2)=real(xe)<0;
%     xr_h(2:2:nb_bits*2)=imag(xe)<0;
% 
%     code_soft = vitdec(xr,treillis,5*(7-1),'trunc','unquant');
%     code_hard = vitdec(xr_h,treillis,5*(7-1),'trunc','hard');
% 
%     TEB1(k) = mean(S ~= code_soft);
%     TEB2(k) = mean(S ~= code_hard);
% end
% 
% figure
% %TEB simulé avec soft décodage
% semilogy(EbN0dB,TEB1)
% xlabel('Eb/N0 (dB)')
% ylabel('TEB')
% hold on
% %TEB simulé avec hard décodage
% semilogy(EbN0dB,TEB2)
% hold on
% %TEB théorique
% semilogy(EbN0dB,qfunc(sqrt(2*EbN0)),'g')
% legend('TEB avec codage et décodage soft','TEB avec codage et décodage hard', 'TEB théorique')
% grid on

%% Paramètres généraux
% on a une meilleure précision si on a plus d'erreurs
clear all
close all

% On se place dans le cas de la BW=33 Mhz
bw = 33000;

% Paramètres du filtre de mise en forme
alpha = 0.35;

% Débit symbole
Rs = bw / (1 + alpha);

% Période symbole
Ts = 1 / Rs;

% Débit binaire
Rb = 2 * Rs;

% Nombre de bits
N = 20000;

% Facteur de suréchantillonnage 
Ns = 6;

% Fréquence d'échantillonnage (Hz)
Fe = 2 * bw; 

% Période d'échantillonnage (s)
Te = 1 / Fe;

% Génération de bits 
bits = randi(2, 1, N) - 1;

% Rapport signal bruit
EbN0_db = -4:0.5:4;
EbN0 = 10 .^ (EbN0_db ./ 10);

% Initialisation des listes de TEB
TEB_liste_soft = zeros(1, length(EbN0));
TEB_liste_hard = zeros(1, length(EbN0));

for i = 1:length(EbN0)
    % Codage convolutif
    trellis = poly2trellis(7, [171 133]);
    donnees_codees = convenc(bits, trellis);

    % Mapping QPSK
    bits_reshape = reshape(donnees_codees, 2, length(donnees_codees) / 2);
    symboles = pskmod(bits_reshape, 4, InputType = 'bit');

    % Mise en forme
    h_m1 = rcosdesign(alpha, 8, Ns);
    modulation = kron(symboles, [1 zeros(1, Ns - 1)]);
    signalQPSK = filter(h_m1, 1, modulation);

    % Ajout du bruit AWGN
    Px = mean(abs(signalQPSK).^2);
    sigma2 = (Px * Ns) / (2 * log2(4) * EbN0(i)); % Correction de la variance
    signal_bruite = signalQPSK + sqrt(sigma2) * randn(1, length(signalQPSK)) + 1i * sqrt(sigma2) * randn(1, length(signalQPSK));

    % Réception et filtrage
    signal_recu = filter(h_m1, 1, signal_bruite);

    % Correction du retard causé par le filtre
    retard = (8 * Ns);
    signal_sup_retard = signal_recu(retard + 1:end);
    demodulation = signal_sup_retard(1:Ns:end);

    %% Décodage soft
    demodulation_soft_r = real(demodulation);
    demodulation_soft_i = imag(demodulation);
    demodulation_soft = zeros(1, 2 * length(demodulation));
    demodulation_soft(1:2:end) = demodulation_soft_r;
    demodulation_soft(2:2:end) = demodulation_soft_i;
    decodedData_soft = vitdec(demodulation_soft, trellis, 25, 'trunc', 'unquant');

    % Calcul des erreurs soft
    erreurs_soft = bits(1:length(decodedData_soft)) ~= decodedData_soft;
    TEB_liste_soft(i) = sum(erreurs_soft) / length(decodedData_soft);

    %% Décodage hard
    demodulation_hard = zeros(1, 2 * length(demodulation));
    demodulation_hard(1:2:end) = real(demodulation) < 0;
    demodulation_hard(2:2:end) = imag(demodulation) < 0;
    decodedData_hard = vitdec(demodulation_hard, trellis, 25, 'trunc', 'hard');

    % Calcul des erreurs hard
    erreurs_hard = bits(1:length(decodedData_hard)) ~= decodedData_hard;
    TEB_liste_hard(i) = sum(erreurs_hard) / length(decodedData_hard);
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

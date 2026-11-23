%% Paramètres généraux
clear all
close all

% Paramètres du filtre de mise en forme
alpha = 0.35;

% Nombre de bits
N = 20000;

% Facteur de suréchantillonnage et fréquence d'échantillonnage
Ns = 6;

% Génération des bits
bits = randi(2, 1, N) - 1;

% Rapport signal sur bruit
EbN0_db = [-4:1:4];
EbN0 = 10.^(EbN0_db ./ 10);

% Codage convolutif
trellis = poly2trellis(7, [171 133]);

%matrice de poinçonnage
poinconnage=[1 1 0 1];

% Initialisation des TEB
TEB_soft_p = zeros(size(EbN0_db));
TEB_soft = zeros(size(EbN0_db));
TEB_hard = zeros(size(EbN0_db));

for i = 1:length(EbN0_db)
    % Codage convolutif
    donnees_codees_p = convenc(bits, trellis, poinconnage); %pour le poinçonnage
    donnees_codees = convenc(bits, trellis);
    
    % Mapping QPSK poinconnage
    bits_reshape_p=reshape(donnees_codees_p, 2, length(donnees_codees_p)/2);
    symboles_p=(1-2*donnees_codees_p(1:2:end))+1j*(1-2*donnees_codees_p(2:2:end));

    % Mapping QPSK
    bits_reshape=reshape(donnees_codees, 2, length(donnees_codees)/2);
    symboles=(1-2*donnees_codees(1:2:end))+1j*(1-2*donnees_codees(2:2:end));
    
    % Mise en forme
    h_m1 = rcosdesign(alpha,6,Ns, 'sqrt');
    
    retard = (6 * Ns);  

    modulation_p = [kron(symboles_p, [1, zeros(1, Ns-1)]) zeros(1,retard)]; 
    modulation = [kron(symboles, [1, zeros(1, Ns-1)]) zeros(1,retard)]; 
    
    signalQPSK=filter(h_m1, 1,modulation);
    signalQPSK_p=filter(h_m1, 1,modulation_p);


    % Bruit AWGN poinconnage
    Px_p = mean(abs(signalQPSK_p).^2);
    sigma2_p=((Px_p*Ns)/(2*2*EbN0(i)));
    bruit_p = sqrt(sigma2_p) * (randn(size(signalQPSK_p)) + 1i * randn(size(signalQPSK_p)));
    signal_bruite_p = signalQPSK_p + bruit_p;

    % Bruit AWGN
    Px = mean(abs(signalQPSK).^2);
    sigma2=((Px*Ns)/(2*2*EbN0(i)));
    bruit = sqrt(sigma2) * (randn(size(signalQPSK)) + 1i * randn(size(signalQPSK)));
    signal_bruite = signalQPSK + bruit;

    % Filtrage de réception
    signal_recu = filter(h_m1, 1, signal_bruite);
    signal_recu_p = filter(h_m1, 1, signal_bruite_p);

    % Échantillonnage des symboles après correction du retard
    demodulation=signal_recu(retard+1:Ns:end);
    demodulation_p=signal_recu_p(retard+1:Ns:end);

    % Décodage soft
    demodulation_soft_r=real(demodulation);
    demodulation_soft_i=imag(demodulation);
    demodulation_soft=zeros(1,2*length(demodulation));
    demodulation_soft(1:2:end)=demodulation_soft_r;
    demodulation_soft(2:2:end)=demodulation_soft_i;

    % Décodage hard
    bits_recu_hard = zeros(1, 2 * length(demodulation));
    bits_recu_hard=demodulation_soft<0;
    bits_recu_hard = reshape(bits_recu_hard, 1, []);
    decoded_hard = vitdec(bits_recu_hard, trellis, 30, 'trunc', 'hard');

    % DEcodage soft poinconnage
    demodulation_soft_r_p=real(demodulation_p);
    demodulation_soft_i_p=imag(demodulation_p);
    demodulation_soft_p=zeros(1,2*length(demodulation_p));
    demodulation_soft_p(1:2:end)=demodulation_soft_r_p;
    demodulation_soft_p(2:2:end)=demodulation_soft_i_p;


    decoded_soft_p = vitdec(demodulation_soft_p, trellis, 30, 'trunc', 'unquant', poinconnage);
    decoded_soft = vitdec(demodulation_soft, trellis, 30, 'trunc', 'unquant');
  
    TEB_soft(i)=mean(bits~=decoded_soft);
    TEB_soft_p(i)=mean(bits~=decoded_soft_p);
    TEB_hard(i)=mean(bits~=decoded_hard);
end

% Tracé des TEB
figure;
semilogy(EbN0_db, TEB_soft, 'r', 'DisplayName', 'Soft');
hold on;
semilogy(EbN0_db, TEB_soft_p, 'b', 'DisplayName', 'Soft poinconné');
hold on;
semilogy(EbN0_db, TEB_hard, 'c', 'DisplayName', 'hard');
hold on;
semilogy(EbN0_db,qfunc(sqrt(2*EbN0)), 'g', 'DisplayName', 'TEB théorique');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend;
grid on;
title('Comparaison des TEB avec décodage soft et hard');

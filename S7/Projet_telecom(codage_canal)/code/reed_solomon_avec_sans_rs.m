%% Paramètres généraux
clear all
close all

% Paramètres du filtre de mise en forme
alpha = 0.35;

% Nombre de bits
N = 188 * 80;

% Facteur de suréchantillonnage et fréquence d'échantillonnage
Ns = 6;

% Génération des bits
bits = randi(2, 1, N) - 1;

% Rapport signal sur bruit
EbN0_db = [-4:1:4];
EbN0 = 10.^(EbN0_db ./ 10);

% Codage convolutif
trellis = poly2trellis(7, [171 133]);

% Initialisation des TEB
TEB_rs = zeros(size(EbN0_db));
TEB_no_rs = zeros(size(EbN0_db));

for i = 1:length(EbN0_db)
    %% Avec Reed-Solomon (RS)
    % Codage Reed-Solomon
    enc = comm.RSEncoder(204, 188, BitInput=true);
    bits_rs = enc(bits.');

    % Codage convolutif
    donnees_codees_rs = convenc(bits_rs', trellis);

    % Mapping QPSK avec RS
    bits_reshape_rs = reshape(donnees_codees_rs, 2, length(donnees_codees_rs) / 2);
    symboles_rs = (1 - 2 * donnees_codees_rs(1:2:end)) + 1j * (1 - 2 * donnees_codees_rs(2:2:end));

    % Mise en forme avec RS
    h_m1 = rcosdesign(alpha, 6, Ns, 'sqrt');
    retard = (6 * Ns);
    modulation_rs = [kron(symboles_rs, [1, zeros(1, Ns-1)]) zeros(1, retard)];
    signalQPSK_rs = filter(h_m1, 1, modulation_rs);

    % Bruit AWGN avec RS
    Px_rs = mean(abs(signalQPSK_rs).^2);
    sigma2_rs = (Px_rs * Ns) / (2 * 2 * EbN0(i));
    bruit_rs = sqrt(sigma2_rs) * (randn(size(signalQPSK_rs)) + 1i * randn(size(signalQPSK_rs)));
    signal_bruite_rs = signalQPSK_rs + bruit_rs;

    % Filtrage de réception avec RS
    signal_recu_rs = filter(h_m1, 1, signal_bruite_rs);

    % Échantillonnage des symboles après correction du retard avec RS
    demodulation_rs = signal_recu_rs(retard+1:Ns:end);
    demodulation_soft_r_rs = real(demodulation_rs);
    demodulation_soft_i_rs = imag(demodulation_rs);
    demodulation_soft_rs = zeros(1, 2 * length(demodulation_rs));
    demodulation_soft_rs(1:2:end) = demodulation_soft_r_rs;
    demodulation_soft_rs(2:2:end) = demodulation_soft_i_rs;

    % Décodage convolutif avec RS
    decode_conv_rs = vitdec(demodulation_soft_rs, trellis, 30, 'trunc', 'unquant');

    % Décodage Reed-Solomon
    denc = comm.RSDecoder(204, 188, BitInput=true);
    decode_rs = denc(decode_conv_rs.');

    % Calcul TEB avec RS
    TEB_rs(i) = mean(bits ~= decode_rs');

    %% Sans Reed-Solomon (RS)
    % Codage convolutif seulement
    donnees_codees_no_rs = convenc(bits, trellis);

    % Mapping QPSK sans RS
    bits_reshape_no_rs = reshape(donnees_codees_no_rs, 2, length(donnees_codees_no_rs) / 2);
    symboles_no_rs = (1 - 2 * donnees_codees_no_rs(1:2:end)) + 1j * (1 - 2 * donnees_codees_no_rs(2:2:end));

    % Mise en forme sans RS
    modulation_no_rs = [kron(symboles_no_rs, [1, zeros(1, Ns-1)]) zeros(1, retard)];
    signalQPSK_no_rs = filter(h_m1, 1, modulation_no_rs);

    % Bruit AWGN sans RS
    Px_no_rs = mean(abs(signalQPSK_no_rs).^2);
    sigma2_no_rs = (Px_no_rs * Ns) / (2 * 2 * EbN0(i));
    bruit_no_rs = sqrt(sigma2_no_rs) * (randn(size(signalQPSK_no_rs)) + 1i * randn(size(signalQPSK_no_rs)));
    signal_bruite_no_rs = signalQPSK_no_rs + bruit_no_rs;

    % Filtrage de réception sans RS
    signal_recu_no_rs = filter(h_m1, 1, signal_bruite_no_rs);

    % Échantillonnage des symboles après correction du retard sans RS
    demodulation_no_rs = signal_recu_no_rs(retard+1:Ns:end);
    demodulation_soft_r_no_rs = real(demodulation_no_rs);
    demodulation_soft_i_no_rs = imag(demodulation_no_rs);
    demodulation_soft_no_rs = zeros(1, 2 * length(demodulation_no_rs));
    demodulation_soft_no_rs(1:2:end) = demodulation_soft_r_no_rs;
    demodulation_soft_no_rs(2:2:end) = demodulation_soft_i_no_rs;

    % Décodage convolutif sans RS
    decode_no_rs = vitdec(demodulation_soft_no_rs, trellis, 30, 'trunc', 'unquant');

    % Calcul TEB sans RS
    TEB_no_rs(i) = mean(bits ~= decode_no_rs);
end

% Tracé des TEB
figure;
semilogy(EbN0_db, TEB_rs, 'r', 'DisplayName', 'Avec RS');
hold on;
semilogy(EbN0_db, TEB_no_rs, 'b', 'DisplayName', 'Sans RS');
hold on;
semilogy(EbN0_db, qfunc(sqrt(2 * EbN0)), 'g', 'DisplayName', 'TEB théorique');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend;
grid on;
title('Comparaison des TEB avec et sans Reed-Solomon');

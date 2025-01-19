%% Paramètres généraux
clear all
close all
% Paramètres du filtre de mise en forme
alpha = 0.35;
% Nombre de bits
N = 188*80*100;
% Facteur de suréchantillonnage et fréquence d'échantillonnage
Ns = 6;
% Rapport signal sur bruit
EbN0_db = [-4:1:4];
EbN0 = 10.^(EbN0_db ./ 10);

% Codage convolutif
trellis = poly2trellis(7, [171 133]);

% Initialisation des TEB
TEB_rs = zeros(size(EbN0_db));

% Paramètres de l'entrelaceur
m = 12; % Profondeur de l'entrelaceur nrows
n = 17; % Nombre d'éléments de retard slope

for i = 1:length(EbN0_db)
    % Génération des bits
    bits = randi([0 1], 1, N);
    
    % Codage Reed-Solomon
    enc = comm.RSEncoder(204, 188, 'BitInput', true);
    bits_rs = enc(bits.');
    
    % Conversion en octets
    octets_rs = bitToOctet(bits_rs);
    retard_entre = zeros (1,12*17*(12-1));
    
    % Entrelacement convolutif
    mat_ent = [octets_rs'  retard_entre];
    octets_ent = convintrlv(mat_ent, m, n);
    %bits_ent = convintrlv(bits_rs, m, n);
    %octets_ent = UserDefined_convintrlv(octets_rs, m, n)
    
    % Conversion des octets entrelacés en bits
    bits_ent = OctetTobit(octets_ent);
    
    % Codage convolutif
    donnees_codees = convenc(bits_ent', trellis);
    
    % Mapping QPSK
    bits_reshape = reshape(donnees_codees, 2, length(donnees_codees)/2);
    symboles = (1 - 2 * donnees_codees(1:2:end)) + 1j * (1 - 2 * donnees_codees(2:2:end));
    
    % Mise en forme
    h_m1 = rcosdesign(alpha, 6, Ns, 'sqrt');
    retard = (6 * Ns);
    modulation = [kron(symboles', [1, zeros(1, Ns-1)]) zeros(1,retard)];  
    signalQPSK = filter(h_m1, 1, modulation);
    
    % Bruit AWGN
    Px = mean(abs(signalQPSK).^2);
    sigma2 = (Px * Ns) / (2 * 2 * EbN0(i));
    bruit = sqrt(sigma2) * (randn(size(signalQPSK)) + 1i * randn(size(signalQPSK)));
    signal_bruite = signalQPSK + bruit;
    
    % Filtrage de réception
    signal_recu = filter(h_m1, 1, signal_bruite);
    
    % Échantillonnage des symboles après correction du retard
    demodulation = signal_recu(retard + 1:Ns:end);
    demodulation_soft_r = real(demodulation);
    demodulation_soft_i = imag(demodulation);
    demodulation_soft = zeros(1, 2 * length(demodulation));
    demodulation_soft(1:2:end) = demodulation_soft_r;
    demodulation_soft(2:2:end) = demodulation_soft_i;
    
    % Décodage convolutif
    decode_conv = vitdec(demodulation_soft, trellis, 30, 'trunc', 'unquant');
    
    % Conversion des bits décodés en octets
    octets_decode = bitToOctet(decode_conv);
    %enleve_retard =  octets_decode(1,12*17*(12-1)+1:end);
    %enleve_retard =  octets_decode(n*m*(n-1)+1:end,1);

    
    % Désentrelacement convolutif
    %decode_entre = UserDefined_convdeintrlv(octets_decode, m, n);
    decode_entre = convdeintrlv(octets_decode, m, n);
    enleve_retard =  decode_entre(1,12*17*(12-1)+1:end);
    
    % Conversion des octets désentrelacés en bits
    bits_decode_entre = OctetTobit(enleve_retard);
    
    % Décodage Reed-Solomon
    denc = comm.RSDecoder(204, 188, 'BitInput', true);
    decode_rs = denc(bits_decode_entre');
    
    % Calcul du TEB
    TEB_rs(i) = mean(bits ~= decode_rs');
end

% Tracé des TEB
figure;
semilogy(EbN0_db, TEB_rs, 'r', 'DisplayName', 'entrelacement');
hold on;
semilogy(EbN0_db, qfunc(sqrt(2 * EbN0)), 'g', 'DisplayName', 'TEB théorique');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend;
title('Comparaison des TEB avec et sans entrelacement');

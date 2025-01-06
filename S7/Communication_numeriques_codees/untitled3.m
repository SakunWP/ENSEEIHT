%% Paramètres généraux
bw = 33000; % Bande passante (en kHz)
alpha = 0.35; % Facteur de roll-off
Rs = bw / (1 + alpha); % Débit symbole
Ts = 1 / Rs; % Durée d'un symbole
Rb = 2 * Rs; % Débit binaire
N = 1000; % Nombre de bits (doit être multiple de 2)
Ns = 6; % Facteur de suréchantillonnage
Fe = 2 * bw; % Fréquence d'échantillonnage (en Hz)
Te = 1 / Fe; % Période d'échantillonnage


% Génération de bits
bits = randi([0 1], 1, N);

% Mapping QPSK
bits1 = reshape(bits, 2, []).'; % Regrouper par paires de bits
symboles = pskmod(bi2de(bits1), 4, pi/4, 'gray'); % Modulation QPSK avec Gray coding

% Filtre de mise en forme (RC)
h_m1 = rcosdesign(alpha, 8, Ns, 'sqrt');
modulation = upfirdn(symboles, h_m1, Ns); % Suréchantillonnage et filtrage

% Transmission sur le canal (ajout éventuel de bruit ici si nécessaire)
signal_recu = modulation; % On simule un canal parfait pour le moment

% Filtre de réception
signal_filtre = conv(signal_recu, h_m1, 'same');

% Échantillonnage au bon moment
echantillons = signal_filtre(Ns:Ns:end); % Échantillonnage aux instants des symboles

% Demapping QPSK
demod_bits_matrix = de2bi(pskdemod(echantillons, 4, pi/4, 'gray'), 2); 
demod_bits = demod_bits_matrix.'; % Transposition
demod_bits = demod_bits(:).'; % Conversion en vecteur ligne

% Troncature pour aligner les tailles
demod_bits = demod_bits(1:N); % S'assurer que la taille est correcte

% Calcul du TEB
erreurs = bits ~= demod_bits; % Comparaison bit à bit
TEB = sum(erreurs) / N; % Taux d'erreur binaire

% Affichage du TEB
disp(['Taux d''erreur binaire (TEB) : ', num2str(TEB)]);

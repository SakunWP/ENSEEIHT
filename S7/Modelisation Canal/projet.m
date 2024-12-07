% Paramètres de simulation DVB-S
numBits = 1e4;              % Nombre de bits
Fs = 8;                     % Facteur de suréchantillonnage
rollOff = 0.35;             % Roll-off pour SRRCF
SNR_dB = 10;                % Rapport SNR en dB

% Génération des données binaires
dataBits = randi([0, 1], numBits, 1);

% Mapping QPSK (Gray)
dataSymbols = reshape(dataBits, 2, []); % Groupement par paires
mappingTable = [1+1j, -1+1j, 1-1j, -1-1j]/sqrt(2); % QPSK normalisée
symbols = mappingTable(bi2de(dataSymbols', 'left-msb') + 1);

% Mise en forme avec SRRCF
txSignal = upsample(symbols, Fs); % Suréchantillonnage
span = 6; % Nombre de symboles pour le filtre
rCosFilter = rcosdesign(rollOff, span, Fs, 'sqrt'); % Filtre racine de cosinus surélevé
txFiltered = conv(txSignal, rCosFilter, 'same');

% Ajout de bruit AWGN
%rxSignal = awgn(txFiltered, SNR_dB, 'measured');

% Filtrage à la réception
rxFiltered = conv(rxSignal, rCosFilter, 'same');

% Échantillonnage et démodulation
rxSymbols = downsample(rxFiltered, Fs);
rxSymbols = rxSymbols(span+1:end-span); % Suppression des bords
[~, detectedSymbols] = min(abs(rxSymbols - mappingTable.'), [], 2);
rxBits = de2bi(detectedSymbols - 1, 2, 'left-msb');
rxBits = rxBits(:); % Bits reçus

% Taux d'erreur binaire
numErrors = sum(rxBits ~= dataBits);
BER = numErrors / numBits;

% Affichage des résultats
disp(['TEB simulé : ', num2str(BER)])

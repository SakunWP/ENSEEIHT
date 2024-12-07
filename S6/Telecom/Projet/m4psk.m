% Nettoyer l'interface
clc;
clear;
close all;

% Constantes

% Fréquence d'échantillonnage
Fe = 6000;
% Débit binaire
Rb = 3000;
% Temps binaire
temps_binaire = 1/Rb;
% Temps symbole
ts = temps_binaire;
% Nombre de bits
nb_bits = 10000;
% Temps d'échantillonnage 
Te = 1/Fe;
% Nombre de symboles 
nb_symboles = floor(ts / Te);
% Roll-off
facteur_rolloff = 0.35;
% Span
duree_filtre = 8;
% Retard 
retard = duree_filtre * nb_symboles / 2;
% Amplitude
amplitude = 1;

%--------------------------------------------------------------------------
% Chaine passe-bas équivalente
%--------------------------------------------------------------------------

%% Début de modulation
% Génération des bits
bits = randi([0 1], 1, nb_bits);

% Regroupement en symboles 4-ASK
bits_groupes = reshape(bits, 2, [])';
symboles_4ASK = 2*bits_groupes(:,1) + bits_groupes(:,2);
symboles_4ASK = 2*symboles_4ASK - 3;

% Suréchantillonnage
nb_echantillons_symbole = floor(ts / Te);
X_k = kron(symboles_4ASK.', [1 zeros(1, nb_echantillons_symbole - 1)]);

% Filtre de mise en forme
filtre_forme = rcosdesign(facteur_rolloff, duree_filtre, nb_echantillons_symbole);

% Ajout du zero padding sur le X_k
signal_filtre = filter(filtre_forme, 1, [X_k zeros(1, retard)]);

% Suppression du zero padding
x_e = signal_filtre(retard + 1:end);

%% Tracé des signaux
figure(1);
plot(real(x_e));
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signal généré avec modulation 4-ASK");
grid on;

% Calcul de la FFT et de la DSP
N = 1024;
X_E = fft(x_e, N);
axe_frequence = linspace(-Fe/2, Fe/2, N);

%% Tracé de la DSP
figure(2);
semilogy(axe_frequence, fftshift(abs(X_E).^2)/length(X_E));
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("DSP du signal 4-ASK");
grid on;

% Canal avec bruit pour la chaîne passe-bas équivalente
EbN0_dB = 0:6;
nb_EbN0 = length(EbN0_dB);
puissance_x_e = mean(abs(x_e).^2);
TEB_4ASK_EQ = zeros(1, nb_EbN0);

for i = 1:nb_EbN0
    puissance_bruit = (puissance_x_e * nb_echantillons_symbole) / (2 * log2(4) * 10^(EbN0_dB(i) / 10));
    bruit = sqrt(puissance_bruit) * randn(1, length(x_e));
    signal_bruit = x_e + bruit;

    % Filtre de réception
    filtre_reception = filtre_forme;
    signal_recu_bruit = filter(filtre_reception, 1, [signal_bruit zeros(1, retard)]);
    signal_recu_bruit = signal_recu_bruit(retard + 1:end);

    % Échantillonnage
    signal_ech_bruit = signal_recu_bruit(1 : nb_echantillons_symbole : end);

    % Décision
    symboles_decides_bruit = 2*floor((real(signal_ech_bruit)+3)/2) - 3;

    % Calcul du TEB pour chaque Eb/N0
    nb_erreurs = length(find(symboles_4ASK ~= symboles_decides_bruit));
    TEB_4ASK_EQ(i) = nb_erreurs / length(symboles_4ASK);
end

% Constellation en sortie du Mapping 
figure(3);
plot(real(symboles_4ASK), zeros(size(symboles_4ASK)), 'o', 'LineWidth', 1);
title('Constellations en sortie du mapping');
xlim([-4 4]);
ylim([-1 1]);

% TEB théorique pour la chaîne passe-bas équivalente
TEB_theorique_4ASK_EQ = (3/2) * qfunc(sqrt((4/5) * (10.^(EbN0_dB / 10))));

% Tracé du TEB théorique et expérimental
figure(4);
semilogy(EbN0_dB, TEB_4ASK_EQ, '*b-');
hold on;
semilogy(EbN0_dB, TEB_theorique_4ASK_EQ, 'sr-');
hold off;
title("TEB estimé et théorique de la chaîne passe-bas équivalente en 4-ASK");
legend({'TEB_{estimé}', 'TEB_{Théorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");
grid on;

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variables
N = 16;                      % Nombre total de porteuses
N_actif = 16;                % Nombre de porteuses actives
nb_bits = 10000;             % Nombre total de bits
taille_garde = 2;            % Taille de l'intervalle de garde (en échantillons)

% Matrice des symboles (initialisation)
S = zeros(N, nb_bits);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mapping BPSK
for i = 1:N_actif
    S(i, :) = randi([0 1], 1, nb_bits) * 2 - 1;
end

% Génération du signal temporel via IFFT
Xe = ifft(S, N);

% Ajout de l'intervalle de garde
zero = zeros(taille_garde, nb_bits); % Zéros pour l'intervalle de garde
Xe = [zero; Xe];                    % Préfixe ajouté au début de chaque symbole
signalTemps = reshape(Xe, 1, nb_bits * (N + taille_garde));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Calcul de la DSP (avant canal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DSP avec pwelch
frequenceEchantillonnage = N; % Correspond au nombre de porteuses
[dspAvant, frequences] = pwelch(signalTemps, [], [], [], frequenceEchantillonnage, 'centered');

% Tracé de la DSP
figure('Name', 'DSP avant canal');
plot(frequences, 10 * log10(dspAvant), 'b', 'LineWidth', 1.5);
xlabel('Fréquence (Hz)');
ylabel('DSP (dB)');
title('Densité Spectrale de Puissance (avant canal)');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Passage dans le canal de transmission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Réponse impulsionnelle du canal
h = [0.407, 0.815, 0.407];

% Filtrage du signal par le canal
signalCanal = filter(h, 1, signalTemps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Calcul de la DSP (après canal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DSP après passage dans le canal
[dspApres, frequences] = pwelch(signalCanal, [], [], [], frequenceEchantillonnage, 'centered');

% Tracé de la DSP après le canal
figure('Name', 'DSP après canal');
plot(frequences, 10 * log10(dspApres), 'r', 'LineWidth', 1.5);
xlabel('Fréquence (Hz)');
ylabel('DSP (dB)');
title('Densité Spectrale de Puissance (après canal)');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Démodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reshape du signal reçu
signalRecu = reshape(signalCanal, N + taille_garde, nb_bits);

% Suppression de l'intervalle de garde
Xs = signalRecu(taille_garde + 1:end, :);

% FFT pour retourner au domaine fréquentiel
symbolesRecus = fft(Xs, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Constellations (porteuses 6 et 15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constellation pour les porteuses 6 et 15
porteuse6 = symbolesRecus(6, :);
porteuse15 = symbolesRecus(15, :);

figure('Name', 'Constellation porteuse 6');
scatter(real(porteuse6), imag(porteuse6));
xlabel('Partie réelle');
ylabel('Partie imaginaire');
title('Constellation - Porteuse 6');

figure('Name', 'Constellation porteuse 15');
scatter(real(porteuse15), imag(porteuse15));
xlabel('Partie réelle');
ylabel('Partie imaginaire');
title('Constellation - Porteuse 15');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Calcul du Taux d'Erreur Binaire (TEB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Décision sur les symboles reçus
bitsRecus = real(symbolesRecus) > 0;
bitsRecus = bitsRecus * 2 - 1;

% Calcul du TEB
tauxErreurBinaire = mean(S ~= bitsRecus, "all");

% Affichage des résultats
disp(['Taux d''Erreur Binaire (TEB) : ', num2str(tauxErreurBinaire)]);

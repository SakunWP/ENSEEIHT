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

% Réponse impulsionnelle du canal
h = [0.407, 0.815, 0.407];

% Réponse en fréquence du canal
ck = fft(h, N);
matr_ck = repmat(ck(:), 1, nb_bits);

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

% Ajout du préfixe cyclique
prefixe_cyclique = Xe(N-taille_garde+1:end, :); % Copier la fin du symbole
Xe = [prefixe_cyclique; Xe];                   % Ajouter le préfixe au début
signalTemps = reshape(Xe, 1, nb_bits * (N + taille_garde));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Passage dans le canal de transmission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Filtrage du signal par le canal
signalCanal = filter(h, 1, signalTemps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Démodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reshape du signal reçu
signalRecu = reshape(signalCanal, N + taille_garde, nb_bits);

% Suppression du préfixe cyclique
Xs = signalRecu(taille_garde + 1:end, :);

% FFT pour retourner au domaine fréquentiel
symbolesRecus = fft(Xs, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Égalisation ZFE (Zero Forcing Equalizer)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Application de l'égalisation
symbolesEgales = (1 ./ matr_ck) .* symbolesRecus;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Constellations (porteuses 6 et 15)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constellation pour les porteuses 6 et 15 après égalisation
porteuse6 = symbolesEgales(6, :);
porteuse15 = symbolesEgales(15, :);

figure('Name', 'Constellation porteuse 6 après égalisation');
scatter(real(porteuse6), imag(porteuse6));
xlabel('Partie réelle');
ylabel('Partie imaginaire');
title('Constellation - Porteuse 6 (après égalisation)');
grid on;

figure('Name', 'Constellation porteuse 15 après égalisation');
scatter(real(porteuse15), imag(porteuse15));
xlabel('Partie réelle');
ylabel('Partie imaginaire');
title('Constellation - Porteuse 15 (après égalisation)');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Calcul du Taux d'Erreur Binaire (TEB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Décision sur les symboles égalisés
bitsRecus = real(symbolesEgales) > 0;
bitsRecus = bitsRecus * 2 - 1;

% Calcul du TEB
tauxErreurBinaire = mean(S ~= bitsRecus, "all");

% Affichage des résultats
disp(['Taux d''Erreur Binaire (TEB) : ', num2str(tauxErreurBinaire)]);

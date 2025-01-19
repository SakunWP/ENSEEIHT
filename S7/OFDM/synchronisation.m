clear all;
close all;

% Paramètres de base
N = 16; % Nombre de porteuses
nb_bits = 1000; 
taille_garde_min = 2; 
taille_garde = 3 * taille_garde_min; 
h = [0.407, 0.815, 0.407]; 

% Génération des données
S = zeros(N, nb_bits);
for i = 1:N
    S(i, :) = randi([0 1], 1, nb_bits) * 2 - 1; % Mapping BPSK
end

% Génération du signal OFDM avec préfixe cyclique
Xe = ifft(S, N);
intervalle = Xe(N - taille_garde + 1:end, :);
Xe = [intervalle; Xe];
SignalEmission = reshape(Xe, 1, nb_bits * (N + taille_garde));

% Passage dans le canal
SignalSortieCanal = filter(h, 1, SignalEmission);

% Simulations des cas de synchronisation
cas = {'avancé', 'aligné', 'retardé'};
decalages = [-1, 0, 1]; % En échantillons
figure;

for i = 1:3
    % Décalage avec validation
    decalage_actuel = mod(decalages(i), length(SignalSortieCanal));
    SignalSynchronise = circshift(SignalSortieCanal, decalage_actuel);

    % Restructuration et extraction de la période utile
    Y_reshape = reshape(SignalSynchronise, N + taille_garde, []);
    if size(Y_reshape, 1) >= taille_garde + N 
        Xs = Y_reshape(taille_garde + 1:N + taille_garde, :); % Période utile
    else
        error('Problème dans l''extraction de la période utile');
    end

    % Démodulation 
    disp(['Valeurs de Xs (Cas ', cas{i}, '):']);
    disp(Xs(:, 1:5)); 

    Y_recep = fft(Xs, N);
    Y_recep = Y_recep / sqrt(N); 

    % Constellations pour les porteuses 6 et 15
    porteuse6 = Y_recep(6, :);
    porteuse15 = Y_recep(15, :);

    % Affichage
    subplot(3, 2, 2 * i - 1);
    scatter(real(porteuse6), imag(porteuse6));
    title(['Constellation Porteuse 6 - Cas ', cas{i}]);
    xlabel('Partie réelle');
    ylabel('Partie imaginaire');

    subplot(3, 2, 2 * i);
    scatter(real(porteuse15), imag(porteuse15));
    title(['Constellation Porteuse 15 - Cas ', cas{i}]);
    xlabel('Partie réelle');
    ylabel('Partie imaginaire');
end

% Nettoyer l'interface
clc;
clear;
close all;

% Constantes

% Fréquence d'échantillonnage
Fe = 24000;
% Fréquence porteuse
Fp = 2000;
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
% Chaine en transposition en fréquence
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
X_k = kron(symboles_4ASK, [1 zeros(1, nb_echantillons_symbole - 1)]);

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

% DSP du signal
X_E = fft(x_e, 1024);
axe_frequence = linspace(-Fe/2, Fe/2, length(X_E));

%% Tracé de la DSP
figure(2);
semilogy(axe_frequence, fftshift(abs(X_E)));
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("DSP du signal 4-ASK");
grid on;

%% Calcul de x(t) : signal qui va entrer au canal
vecteur_temps = 0:Te:(length(x_e) - 1) * Te;
x_t = real(x_e .* exp(1i*2*pi*Fp*vecteur_temps));

figure(3);
plot(vecteur_temps, x_t);
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signal transmis sur fréquence porteuse");
grid on;

% Densité spectrale de puissance du signal transmis sur fréquence porteuse
X_t = fft(x_t, 1024);
figure(4);
semilogy(axe_frequence, fftshift(abs(X_t)));
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Densité spectrale de puissance du signal transmis sur fréquence porteuse");
grid on;

% Démodulation sans bruit
x_cos = x_t .* cos(2*pi*Fp*vecteur_temps);
x_sin = x_t .* sin(2*pi*Fp*vecteur_temps);

% Signal à démoduler en bande de base
signal_complexe = x_cos - 1i*x_sin;

% Filtre de réception
filtre_reception = filtre_forme;
signal_recu = filter(filtre_reception, 1, [signal_complexe zeros(1, retard)]);
signal_recu = signal_recu(retard + 1:end);

% Échantillonnage
signal_ech = signal_recu(1 : nb_echantillons_symbole : end);

% Décision
symboles_decides = 2*floor((real(signal_ech)+3)/2) - 3;

% Demapping
bits_decides = zeros(1, nb_bits);
bits_decides(1:2:end) = (symboles_decides + 3)/2 >= 2;
bits_decides(2:2:end) = mod((symboles_decides + 3)/2, 2);

% Calcul du TEB
nb_erreurs = length(find(bits ~= bits_decides));
TEB_sans_bruit = nb_erreurs / nb_bits;
fprintf("TEB de la chaîne sur fréquence porteuse sans bruit est : %f\n", TEB_sans_bruit);

% Canal avec bruit
EbN0_dB = 0:6;
nb_EbN0 = length(EbN0_dB);
puissance_x_t = mean(abs(x_t).^2);
TEB_4ASK = zeros(1, nb_EbN0);

for i = 1:nb_EbN0
    puissance_bruit = (puissance_x_t * nb_echantillons_symbole) / (2 * log2(4) * 10^(EbN0_dB(i)/10));
    bruit = sqrt(puissance_bruit) * randn(1, length(x_t));
    signal_bruit = x_t + bruit;

    % Démodulation
    x_cos_bruit = 2 * signal_bruit .* cos(2*pi*Fp*vecteur_temps);
    x_sin_bruit = 2 * signal_bruit .* sin(2*pi*Fp*vecteur_temps);
    signal_complexe_bruit = x_cos_bruit - 1i*x_sin_bruit;

    % Filtre de réception
    filtre_reception = filtre_forme;
    signal_recu_bruit = filter(filtre_reception, 1, [signal_complexe_bruit zeros(1, retard)]);
    signal_recu_bruit = signal_recu_bruit(retard + 1:end);

    % Échantillonnage
    signal_ech_bruit = signal_recu_bruit(1 : nb_echantillons_symbole : end);

    % Décision
    symboles_decides_bruit = 2*floor((real(signal_ech_bruit)+3)/2) - 3;

    % Calcul du TEB pour chaque Eb/N0
    nb_erreurs = length(find(symboles_4ASK ~= symboles_decides_bruit));
    TEB_4ASK(i) = nb_erreurs / length(symboles_4ASK);
end

% Calcul du TEB théorique
TEB_theorique_4ASK = (3/2) * qfunc(sqrt((4/5) * (10.^(EbN0_dB / 10))));

% Tracé du TEB théorique et expérimental
figure(5);
semilogy(EbN0_dB, TEB_4ASK, '*b-');
hold on;
semilogy(EbN0_dB, TEB_theorique_4ASK, 'sr-');
hold off;
title("TEB estimé et théorique de la chaîne sur fréquence porteuse en 4-ASK");
legend({'TEB_{estimé}', 'TEB_{Théorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");
grid on;

%--------------------------------------------------------------------------
% Chaine passe-bas équivalente
%--------------------------------------------------------------------------

% Signal généré
x_e_reel = real(x_e);

% Tracé des signaux
figure(6);
plot(x_e_reel);
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signal généré avec modulation 4-ASK");
grid on;

% DSP de l'enveloppe complexe
X_e = fft(x_e, 1024);
figure(7);
semilogy(axe_frequence, fftshift(abs(X_e)));
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Densité spectrale de puissance de l'enveloppe complexe 4-ASK");
grid on;

X_e_DSP = periodogram(x_e);
X_t_DSP = periodogram(x_t);

% Tracé comparatif des DSP
figure(8);
plot(fftshift(X_e_DSP), 'g');
hold on;
plot((X_t_DSP), 'r');
ylabel('DSP');
title('Comparaison de la densité spectrale de puissance des deux chaînes');
legend('Chaine sur fréquence porteuse', 'Chaine passe-bas équivalente');

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
figure(9);
plot(real(symboles_4ASK), zeros(size(symboles_4ASK)), 'o', 'LineWidth', 1);
title('Constellations en sortie du mapping');
xlim([-4 4]);
ylim([-1 1]);

% TEB théorique pour la chaîne passe-bas équivalente
TEB_theorique_4ASK_EQ = (3/2) * qfunc(sqrt((4/5) * (10.^(EbN0_dB / 10))));

% Tracé du TEB théorique et expérimental
figure(10);
semilogy(EbN0_dB, TEB_4ASK_EQ, '*b-');
hold on;
semilogy(EbN0_dB, TEB_theorique_4ASK_EQ, 'sr-');
hold off;
title("TEB estimé et théorique de la chaîne passe-bas équivalente en 4-ASK");
legend({'TEB_{estimé}', 'TEB_{Théorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");
grid on;

% Comparaison du TEB: chaîne passe-bas équivalente avec chaîne sur fréquence porteuse
figure(11);
semilogy(EbN0_dB, TEB_4ASK_EQ, '*b-');
hold on;
semilogy(EbN0_dB, TEB_4ASK, 'sr-');
hold off;
title("TEB sur chaîne passe-bas équivalente et TEB sur fréquence porteuse en 4-ASK");
legend({'TEB_{EQ}', 'TEB_{FP}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");
grid on;

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

% Répartitions en deux vecteurs
bits_phase = bits(1:2:end);
bits_quadrature = bits(2:2:end);

% Mapping binaire de a_k
symboles_phase = zeros(1, length(bits_phase));
symboles_phase(bits == 1) = amplitude;
symboles_phase(bits == 0) = -amplitude;

% Mapping binaire de b_k
symboles_quadrature = zeros(1, length(bits_quadrature));
symboles_quadrature(bits == 1) = amplitude;
symboles_quadrature(bits == 0) = -amplitude;

% Calcul des deux canaux
a_k = 2 * bits_phase - 1;
b_k = 2 * bits_quadrature - 1;

% Calcul de d_k
d_k = a_k + 1j * b_k;

% Suréchantillonnage
temps_symbole_binaire = temps_binaire;
nb_echantillons_binaire = floor(temps_symbole_binaire / Te);
surechantillonnage = zeros(1, nb_echantillons_binaire - 1);
surechantillonnage(1) = 1;
X_k = kron(d_k, [1 zeros(1, nb_echantillons_binaire - 1)]);

% Filtre de mise en forme
filtre_forme = rcosdesign(facteur_rolloff, duree_filtre, nb_echantillons_binaire);

% Ajout du zero padding sur le X_k
signal_filtre = filter(filtre_forme, 1, [X_k zeros(1, retard)]);

% Suppression du zero padding
x_e = signal_filtre(retard + 1:end);
x_e_reel = real(x_e);
x_e_imag = imag(x_e);

%% Tracé des signaux
figure(1);
subplot(2,1,1);
plot(x_e_reel);
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signaux générés sur les voies en phase");
grid on;

subplot(2,1,2);
plot(x_e_imag);
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signaux générés sur les voies en quadrature");
grid on;

% DSP de la partie réelle et imaginaire du signal
X_E_REEL = fft(x_e_reel, 1024);
X_E_IMAG = fft(x_e_imag, 1024);
axe_frequence = linspace(-Fe, Fe, length(X_E_REEL));


%% Calcul de x(t) : signal qui va entrer au canal
vecteur_temps = 0:Te:(length(x_e) - 1) * Te;
x_t = real(x_e .* exp(1i*2*pi*Fp*vecteur_temps));

figure(2);
plot(vecteur_temps, x_t);
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signal transmis sur fréquence porteuse");
grid on;

% DENSITÉ SPECTRALE: 

% Densité spectrale du signal transmis sur fréquence porteuse
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
signal_ech = signal_recu(1 : nb_echantillons_binaire : end);
signal_ech_reel = real(signal_ech);
signal_ech_imag = imag(signal_ech);

% Décision
symboles_decides_reel = sign(signal_ech_reel);
symboles_decides_imag = sign(signal_ech_imag);

% Demapping
bits_decides_reel = (symboles_decides_reel + 1) / 2;
bits_decides_imag = (symboles_decides_imag + 1) / 2;
bits_decides = zeros(1, nb_bits);
bits_decides(1:2:end) = bits_decides_reel;
bits_decides(2:2:end) = bits_decides_imag;

% Calcul du TEB
nb_erreurs = length(find(bits ~= bits_decides));
TEB_sans_bruit = nb_erreurs / nb_bits;
fprintf("TEB de la chaîne sur fréquence porteuse sans bruit est : %f\n", TEB_sans_bruit);

% Canal avec bruit
EbN0_dB = 0:6;
nb_EbN0 = length(EbN0_dB)
puissance_x_t = mean(abs(x_t).^2);
TEB_QPSK = zeros(1, nb_EbN0);

for i = 1:nb_EbN0
    puissance_bruit = (puissance_x_t * nb_echantillons_binaire) / (2 * log2(4) * 10^(EbN0_dB(i)/10));
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
    signal_ech_bruit = signal_recu_bruit(1 : nb_echantillons_binaire : end);
    signal_ech_bruit_reel = real(signal_ech_bruit);
    signal_ech_bruit_imag = imag(signal_ech_bruit);

    % Décision
    symboles_decides = zeros(1, length(d_k));
    for j = 1:length(signal_ech_bruit_imag)
        if (signal_ech_bruit_reel(j) < 0 && signal_ech_bruit_imag(j) < 0)
            symboles_decides(j) = -1 - 1i;
        elseif (signal_ech_bruit_reel(j) >= 0 && signal_ech_bruit_imag(j) >= 0)
            symboles_decides(j) = 1 + 1i;
        elseif (signal_ech_bruit_reel(j) < 0 && signal_ech_bruit_imag(j) > 0)
            symboles_decides(j) = -1 + 1i;
        else
            symboles_decides(j) = 1 - 1i;
        end
    end
    
    % Calcul du TEB pour chaque Eb/N0
    nb_erreurs = length(find(d_k ~= symboles_decides));
    TEB_QPSK(i) = nb_erreurs / nb_bits;
end

% Calcul du TEB théorique
TEB_theorique_QPSK = qfunc(2 * sqrt(10 .^ (EbN0_dB / 10)));

% Tracé du TEB théorique et expérimental
figure(5);
semilogy(EbN0_dB, TEB_QPSK, '*b-');
hold on;
semilogy(EbN0_dB, TEB_theorique_QPSK, 'sr-');
hold off;
title("TEB estimé et théorique de la chaîne sur fréquence porteuse");
legend({'TEB_{estimé}', 'TEB_{Théorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");

%--------------------------------------------------------------------------
% Chaine passe-bas équivalente
%--------------------------------------------------------------------------

% Signal généré sur les voies en phase et en quadrature
x_e_reel = real(x_e);
x_e_imag = imag(x_e);

% Tracé des signaux
figure(6);
subplot(2,1,1);
plot(x_e_reel);
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signaux générés sur les voies en phase");
grid on;

subplot(2,1,2);
plot(x_e_imag);
xlabel("Temps (s)");
ylabel("Amplitude");
title("Signaux générés sur les voies en quadrature");
grid on;

% DSP de l'enveloppe complexe
X_e = fft(x_e, 1024);
figure(8);
semilogy(axe_frequence, fftshift(abs(X_e)));
xlabel("Fréquence (Hz)");
ylabel("Puissance");
title("Densité spectrale de puissance de l'enveloppe complexe");
grid on;

X_e_DSP = periodogram(x_e);
X_t_DSP = periodogram(x_t);

% Tracé comparatif des DSP
figure(9);
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
TEB_QPSK_EQ = zeros(1, nb_EbN0);

for i = 1:nb_EbN0
    puissance_bruit = (puissance_x_e * nb_echantillons_binaire) / (2 * log2(4) * 10^(EbN0_dB(i) / 10));
    bruit_reel = sqrt(puissance_bruit) * randn(1, length(x_e));
    bruit_imag = sqrt(puissance_bruit) * randn(1, length(x_e));
    bruit = bruit_reel + 1j * bruit_imag;
    signal_bruit = x_e + bruit;

    % Filtre de réception
    filtre_reception = filtre_forme;
    signal_recu_bruit = filter(filtre_reception, 1, [signal_bruit zeros(1, retard)]);
    signal_recu_bruit = signal_recu_bruit(retard + 1:end);

    % Échantillonnage
    signal_ech_bruit = signal_recu_bruit(1 : nb_echantillons_binaire : end);

    % Tracé des constellations pour différentes valeurs de Eb/N0
    figure(i + 9);
    plot(real(signal_ech_bruit), imag(signal_ech_bruit), 'o', 'LineWidth', 3);
    xlim([-2 2]);
    ylim([-2 2]);
    title('Constellations en sortie de lechantillonneur');

    signal_ech_bruit_reel = real(signal_ech_bruit);
    signal_ech_bruit_imag = imag(signal_ech_bruit);

    % Décision
    symboles_decides = zeros(1, length(d_k));
    for j = 1:length(signal_ech_bruit_imag)
        if (signal_ech_bruit_reel(j) < 0 && signal_ech_bruit_imag(j) < 0)
            symboles_decides(j) = -1 - 1i;
        elseif (signal_ech_bruit_reel(j) >= 0 && signal_ech_bruit_imag(j) >= 0)
            symboles_decides(j) = 1 + 1i;
        elseif (signal_ech_bruit_reel(j) < 0 && signal_ech_bruit_imag(j) > 0)
            symboles_decides(j) = -1 + 1i;
        else
            symboles_decides(j) = 1 - 1i;
        end
    end
    
    % Calcul du TEB pour chaque Eb/N0
    nb_erreurs = length(find(d_k ~= symboles_decides));
    TEB_QPSK_EQ(i) = nb_erreurs / nb_bits;
end

% Constellation en sortie du Mapping 
figure(17);
plot(real(d_k), imag(d_k), 'o', 'LineWidth', 1);
title('Constellations en sortie du mapping');
xlim([-2 2]);
ylim([-2 2]);

% TEB théorique pour la chaîne passe-bas équivalente
TEB_theorique_QPSK_EQ = qfunc(sqrt(2 * 10.^(EbN0_dB / 10)));

% Tracé du TEB théorique et expérimental
figure(19);
semilogy(EbN0_dB, TEB_QPSK_EQ, '*b-');
hold on;
semilogy(EbN0_dB, TEB_theorique_QPSK_EQ, 'sr-');
hold off;
title("TEB estimé et théorique de la chaîne passe-bas équivalente");
legend({'TEB_{estimé}', 'TEB_{Théorique}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");

% Comparaison du TEB: chaîne passe-bas équivalente avec chaîne sur fréquence porteuse
figure(20);
semilogy(EbN0_dB, TEB_QPSK_EQ, '*b-');
hold on;
semilogy(EbN0_dB, TEB_QPSK, 'sr-');
hold off;
title("TEB sur chaîne passe-bas équivalente et TEB sur fréquence porteuse");
legend({'TEB_{EQ}', 'TEB_{FP}'});
xlabel("Eb/N0 (dB)");
ylabel("TEB");

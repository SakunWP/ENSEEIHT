% Script pour calculer le TEB pour la modulation QAM dans des canaux ISI avec FDE
% Ce script effectue la simulation du TEB pour une modulation QAM (ici 4-QAM)
% dans un canal avec interférence inter-symboles (ISI) et utilise des égaliseurs ZF et MMSE.

close all;  % Ferme toutes les fenêtres de figure ouvertes
clear all;  % Efface toutes les variables de l'espace de travail

%% Paramètres de simulation
% Description des paramètres généraux pour la simulation

% Paramètres de modulation
M = 4;  % Ordre de la modulation (ici 4-QAM)
Nframe = 100;  % Nombre de trames
Nfft = 1024;  % Taille de la FFT
Ncp = 8;  % Longueur du préfixe cyclique
Ns = Nframe * (Nfft + Ncp);  % Nombre total d'échantillons
N = log2(M) * Nframe * Nfft;  % Nombre total de bits

% Paramètres du canal
Eb_N0_dB = [0:40];  % Plage des valeurs Eb/N0 en dB

% Paramètres du canal multipath
hc = [1 -0.9];  % Réponse impulsionnelle du canal (modèle simple)
Lc = length(hc);  % Longueur du canal
H = fft(hc, Nfft);  % Spectre du canal

% Pré-allocation des variables pour le comptage des erreurs
nErr_zffde = zeros(1, length(Eb_N0_dB));  % Erreurs pour égaliseur ZF
nErr_mmsefde = zeros(1, length(Eb_N0_dB));  % Erreurs pour égaliseur MMSE

%% Boucle de simulation
for ii = 1:length(Eb_N0_dB)
   
    % Génération du message (bits aléatoires)
    bits = randi([0 1], N, 1);  % Génération des bits aléatoires
    s = qammod(bits, M, 'InputType', 'bit');  % Modulation QAM
    sigs2 = var(s);  % Calcul de la variance du signal modulé
    
    % Ajout du préfixe cyclique (CP)
    smat = reshape(s, Nfft, Nframe);  % Reshape pour organiser les symboles par trame
    smatcp = [smat(end-Ncp+1:end, :); smat];  % Ajout du PC aux symboles
    scp = reshape(smatcp, 1, (Nfft + Ncp) * Nframe);  % Reshape final
    
    % Convolution du canal : représentation symbolique équivalente
    z = filter(hc, 1, scp);  % Convolution du signal avec la réponse impulsionnelle du canal
    
    % Génération du bruit
    sig2b = 10^(-Eb_N0_dB(ii) / 10);  % Calcul de la puissance du bruit en fonction d'Eb/N0
    
    % Création du bruit gaussien complexe
    n = sqrt(sig2b / 2) * randn(1, Ns) + 1j * sqrt(sig2b / 2) * randn(1, Ns);  % Bruit complexe
    
    % Addition du bruit au signal
    ycp = z + n;  % Signal reçu avec bruit
   
    % Suppression du préfixe cyclique
    ycp_matrice = reshape(ycp, Nfft + Ncp, Nframe);  % Reshape pour séparer les CP
    y_no_cp = ycp_matrice(Ncp+1:end, :);  % Enlever le CP
    
    % Calcul de l'égalisation ZF (Zero Forcing)
    wzf = 1 ./ H;  % Calcul du facteur d'égalisation ZF
    Y = fft(y_no_cp, Nfft, 1);  % FFT du signal reçu sans PC
    Yf = diag(wzf) * Y;  % Application du facteur d'égalisation ZF
    s_zf = ifft(Yf, Nfft, 1);  % IFFT pour revenir au domaine temporel
    bhat_zfeq = qamdemod(s_zf(:), M, 'bin', 'OutputType', 'bit');  % Démodulation ZF
    
    % Calcul de l'égalisation MMSE (Minimum Mean Squared Error)
    Wmmse = conj(H) ./ (abs(H).^2 + sig2b / sigs2);  % Calcul du facteur MMSE
    Y_mmse = fft(y_no_cp, Nfft, 1);  % FFT du signal reçu sans PC
    Yf_mmse = diag(Wmmse) * Y_mmse;  % Application du facteur MMSE
    xhat_mmse = ifft(Yf_mmse, Nfft, 1);  % IFFT pour revenir au domaine temporel
    bhat_mmseeq = qamdemod(xhat_mmse(:), M, 'bin', 'OutputType', 'bit');  % Démodulation MMSE
    
    % Calcul du nombre d'erreurs pour chaque méthode
    nErr_zffde(1, ii) = size(find([bits(:) - bhat_zfeq(:)]), 1);  % Erreurs ZF
    nErr_mmsefde(1, ii) = size(find([bits(:) - bhat_mmseeq(:)]), 1);  % Erreurs MMSE

end

% Calcul de la densité spectrale de puissance du canal
dsp_H = pwelch(H);
nexttile
plot(10 * log(dsp_H))  % Affichage de la DSP en échelle logarithmique
xlabel('Fréquence')
ylabel('DSP')

% Calcul du taux d'erreur binaire (TEB) simulé
simBer_zf = nErr_zffde / N;  % TEB pour ZF
simBer_mmse = nErr_mmsefde / N;  % TEB pour MMSE

% Tracé de la courbe du TEB en fonction de Eb/N0
figure
semilogy(Eb_N0_dB, simBer_zf(1, :), 'bs-', 'LineWidth', 2);  % Tracé ZF
hold on
semilogy(Eb_N0_dB, simBer_mmse(1, :), 'rd-', 'LineWidth', 2);  % Tracé MMSE
axis([0 70 10^-6 0.5])  % Limites des axes
grid on  % Affichage de la grille
legend('sim-zf-fde', 'sim-mmse-fde');  % Légende
xlabel('Eb/No, dB');  % Label axe des abscisses
ylabel('Bit Error Rate');  % Label axe des ordonnées
title("Courbe de la probabilité d'erreur binaire pour QPSK dans un canal ISI avec égaliseurs ZF et MMSE");  % Titre de la figure

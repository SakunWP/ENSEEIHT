
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variables
nbPorteuses = 16;                      % Nombre total de porteuses
nbPorteusesActives = 16;                % Nombre de porteuses actives
nbBitsParPorteuse = nbPorteuses*1000;              % Nombre de bits par porteuse
nbBitsTotal = nbPorteuses * nbBitsParPorteuse; % Nombre total de bits

% Matrice des symboles (initialisation)
symboles = zeros(nbPorteuses, nbBitsParPorteuse);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mapping BPSK
if nbPorteusesActives==8
    for i = 5:12 % Activation des porteuses 5 à 12
        symboles(i, :) = randi([0, 1], 1, nbBitsParPorteuse) * 2 - 1;
    end
else
    for i = 1:nbPorteusesActives
        symboles(i, :) = randi([0, 1], 1, nbBitsParPorteuse) * 2 - 1;
    end
end


% Génération du signal temporel via IFFT
signalOFDM = ifft(symboles, nbPorteuses);


% Reshape du signal pour transmission continue
signalTemps = reshape(signalOFDM, 1, nbBitsTotal);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Calcul de la DSP (avant canal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DSP avec pwelch
frequenceEchantillonnage = nbPorteuses; % Correspond au nombre de porteuses
[dspAvant, frequences] = pwelch(signalTemps, [], [], [], frequenceEchantillonnage, 'centered');

% Tracé de la DSP
figure('Name', 'DSP');
plot(frequences, 10 * log10(dspAvant), 'b', 'LineWidth', 1.5);
xlabel('Fréquence (Hz)');
ylabel('DSP (dB)');
title('Densité Spectrale de Puissance (emission)');
grid on;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Démodulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reshape du signal reçu
signalRecu = reshape(signalTemps, nbPorteuses, nbBitsParPorteuse);

% Démodulation via FFT
symbolesRecus = fft(signalRecu, nbPorteuses);

% Décision sur les symboles reçus
symbolesDecides = sign(real(symbolesRecus));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Calcul du Taux d'Erreur Binaire (TEB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calcul du TEB
tauxErreurBinaire = mean(symboles ~= symbolesDecides, "all");

% Affichage des résultats
disp(['Taux d''Erreur Binaire (TEB) : ', num2str(tauxErreurBinaire)]);

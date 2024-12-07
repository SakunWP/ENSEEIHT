% Données du problème :
Fe = 6000;  % Fréquene d'échantillonnage
Rb = 3000;  % Débit binaire
Te = 1/Fe;  % Période d'échantillonnage
Tb = 1/Rb;  % Période binaire
Nb = 9000; 
alpha1 = 0.35; 
SNRdB = linspace(0,6,13);
SNR = 10 .^ (SNRdB / 10);

% Parametres de la modulation
M = 4;                      % Ordre de modulation
l = log2(M);                % Nombre de bits codants par symbole
Ts = l * Tb;                % Période symbole
Rs = 1/Ts;                  % Débit symbole
Ns = Ts / Te;               % Nombre de bit par symbole
long = Nb * Ns / l;         % Nombre total d'échantillons dans le signal
T = long * Te;              % Durée du signal
L = Nb/Ns;                  % Nombre de symboles
attente = M*Ns;             % Retard du signal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Modulation Bande De Base 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mapping
symboles = -(1 - 2*bits(1:2:end)) .* (3 - 2*bits(2:2:end));
pDirac = kron(symboles, [1 zeros(1, Ns-1)]);

% Création du filtre de mise en forme
h = rcosdesign(alpha1, 4, Ns, 'sqrt');

% Application du filtre
signal_module =filter(h, 1, [pDirac zeros(1, attente)]);
signal_module = signal_module(attente+1 : end);

% Filtre de réception
h_r =  fliplr(h);
signal_3 = filter(h_r, 1, signal_module);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Chaine de Transmission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Paramètre pour le calcul du TEB
TEB_3 = zeros(1, length(SNRdB));
TEB_theorique = (2/log2(M)) * (1 - 1/M) * qfunc(sqrt((6 * log2(M)/(M^2 - 1)) * SNR));

% Tableau pour stocker les figures affichees
nombre_figure = length(SNRdB) + 3;
stockage = gobjects(1, nombre_figure);

for i = 1:length(SNRdB)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       Calcul du signal bruité
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Ajout du bruit
    Px = mean(abs(signal_module).^2);
    sigma_n_carre = (Px*Ns)/(2*log2(M)*SNR(i));
    sigma_n = sqrt(sigma_n_carre);
    nI = sigma_n * randn(1,length(signal_module));
    nQ = sigma_n * randn(1,length(signal_module));
    ne = nI + 1j*nQ;
    signal_bruite = signal_module + ne;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DémodE_b/N_0ulation bande de base
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    signal = filter(h_r, 1, signal_bruite);

    % Instants optimaux d'échantillonnage
    n0 = 1;

    % Démodulation personnalisée et calcul du TEB
    signal_echant = signal(n0:Ns:end); % z(n0 + mNs) m€N

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                           Démapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Demapping adapté au mapping utilisé
    BitsRecuperes = zeros(1, Nb);
    BitsRecuperes(1:2:end) = real(signal_echant) > 0;
    BitsRecuperes(2:2:end) = abs(real(signal_echant)) < 2;
    erreur = abs(bits - BitsRecuperes);
    TEB_3(i) = mean(erreur);

    % Tracé des constellations en sortie de l'échantillonneur
    stockage(i) = scatterplot(signal_echant);
    title("Constellation en sortie de l'échantillonneur pour Eb/n0 = " + SNRdB(i) + " dB.");
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tracés
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tracé des constellations en sortie du mapping
stockage(nombre_figure-2) = scatterplot(symboles);
title('Constellation en sortie du mapping');

% Tracé du TEB
stockage(nombre_figure-1) = figure('Name', 'Taux d''erreur binaire');
semilogy(SNRdB, TEB_2);
legend('TEB simulé', 'Location', 'NorthWest');
title('Taux d''erreur binaire');
xlabel('SNR (dB)');
ylabel('TEB');
grid on;

% Tracé de comparaison des TEB théoriques et simulé
stockage(nombre_figure) = figure;
semilogy(SNRdB, TEB_3, 'b*-');
hold on;
semilogy(SNRdB, TEB_theorique, 'r--');
legend('TEB simulé', 'TEB théorique');
title('Taux d''erreur binaire');
xlabel('SNR (dB)');
ylabel('TEB');
grid on;

% Attendre que toutes les figures soient fermées avant de continuer
for i = 1:nombre_figure
    waitfor(stockage(i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                              PARTIE 4.2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tableau pour stocker les figures affichees
stockage = gobjects(1, 2);

% Tracé des TEB en fonction des SNR des deux modulateurs
stockage(1) = figure;
semilogy(SNRdB, TEB_1, 'b*-');
hold on;
semilogy(SNRdB, TEB_3, 'r--');
legend('TEB du QPSK du DVB-S', 'TEB du 4-ASK');
title('Taux d''erreur binaire');
xlabel('SNR (dB)');
ylabel('TEB');
grid on;

% Tracés des densités spectrales des deux modulateurs
stockage(2) = figure;
pwelch(signal_1,[],[],[],Fe,'centered');
hold on;
pwelch(signal_3,[],[],[],Fe,'centered');
legend('DSP du QPSK du DVB-S', 'DSP du 4-ASK');
title('Densité spectrale de puissance');

% Attendre que toutes les figures soient fermées avant de continuer
for i = 1:2
    waitfor(stockage(i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                              PARTIE 5.1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Données du problème :
Fe = 6000; % Fréquene d'échantillonnage
Rb = 3000;  % Débit binaire
Te = 1/Fe;  % Période d'échantillonnage
Tb = 1/Rb;  % Période binaire

% Parametres de la modulation
M = 8;                      % Ordre de modulation
l = log2(M);                % Nombre de bits codants par symbole
Ts = l * Tb;                % Période symbole
Rs = 1/Ts;                  % Débit symbole
Ns = Ts / Te;               % Nombre de bit par symbole
long = Nb * Ns / l;         % Nombre total d'échantillons dans le signal
T = long * Te;              % Durée du signal
attente = M*Ns;             % Retard du signal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Modulation Bande De Base 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mapping QPSK
symboles = PSK8(bits);
pDirac = kron(symboles, [1 zeros(1, Ns-1)]);

% Calcul du signal modulé par application du filtre de mise en forme
h = rcosdesign(alpha2, 8, Ns, 'sqrt');
signal_module =filter(h, 1, [pDirac zeros(1, attente)]);
signal_module = signal_module(attente+1 : end);

% Filtre de réception
h_r =  fliplr(h);
signal_4 = filter(h_r, 1, signal_module);

% Initialisation du vecteur temps
t = (0:length(signal_module)-1) * Te;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Chaine De Transmission
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TEB_4 = zeros(1,length(SNRdB));
TEB_theorique = (2/log2(M)) * qfunc(sqrt(2 *log2(M) * SNR) * sin(pi/M));

% Tableau pour stocker les figures affichees
nombre_figure = length(SNRdB) + 3;
stockage = gobjects(1, nombre_figure);

for i = 1:length(SNRdB)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                       Calcul du signal bruité
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Ajout du bruit
    Px = mean(abs(signal_module).^2);
    sigma_n_carre = (Px*Ns)/(2*log2(M)*SNR(i));
    sigma_n = sqrt(sigma_n_carre);
    nI = sigma_n * randn(1, length(signal_module));
    nQ = sigma_n * randn(1, length(signal_module));
    bruit_complexe = nI + 1j*nQ;
    signal_bruite = signal_module + bruit_complexe;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Démodulation bande de base
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    signal = filter(h_r, 1, signal_bruite);

    % Instants optimaux d'échantillonnage
    n0 = 1;

    % Démodulation personnalisée et calcul du TEB
    signal_echant = signal(n0:Ns:end); % z(n0 + mNs) m€N

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                           Démapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Demapping adapté au mapping utilisé
    BitsRecuperes = PSK8demap(signal_echant);

    % Calcul de l'erreur
    erreur = abs(bits - BitsRecuperes);

    % Calcul du TEB
    TEB_4(i) = mean(erreur);

    % Tracé des constellations en sortie de l'échantillonneur
    stockage(i) = scatterplot(signal_echant);
    title("Constellation en sortie de l'échantillonneur pour Eb/n0 = " + SNRdB(i) + " dB.");
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Tracés Demandés
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Vecteur temps
t = (0:length(signal_module)-1)/Fe;

% Tracé des constellations en sortie du mapping
stockage(nombre_figure-2) = scatterplot(symboles);
title('Constellation en sortie du mapping');

% Tracé du TEB
stockage(nombre_figure-1) = figure('Name', 'Taux d''erreur binaire');
semilogy(SNRdB, TEB_4);
legend('TEB simulé', 'Location', 'NorthWest');
title('Taux d''erreur binaire');
xlabel('SNR (dB)');
ylabel('TEB');
grid on;

% Tracé de comparaison des TEB théoriques et simulé
stockage(nombre_figure) = figure;
semilogy(SNRdB, TEB_4, 'b*-');
hold on;
semilogy(SNRdB, TEB_theorique, 'r--');
legend('TEB simulé', 'TEB théorique');
title('Taux d''erreur binaire');
xlabel('SNR (dB)');
ylabel('TEB');
grid on;

% Attendre que toutes les figures soient fermées avant de continuer
for i = 1:nombre_figure
    waitfor(stockage(i));
end
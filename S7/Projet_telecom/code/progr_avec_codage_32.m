%% Paramètres généraux
clear all
close all

% Paramètres du filtre de mise en forme
alpha = 0.35;

% Nombre de bits
N = 20000;

% Facteur de suréchantillonnage et fréquence d'échantillonnage
Ns = 6;

% Génération des bits
bits = randi(2, 1, N) - 1;

% Rapport signal sur bruit
EbN0_db = [-4:1:4];
EbN0 = 10.^(EbN0_db ./ 10);

% Codage convolutif
trellis = poly2trellis(7, [171 133]);

% Initialisation des TEB
TEB_hard = zeros(size(EbN0_db));
TEB_soft = zeros(size(EbN0_db));

for i = 1:length(EbN0_db)
    % Codage convolutif
    donnees_codees = convenc(bits, trellis);
    
    % Mapping QPSK
    bits_reshape=reshape(donnees_codees, 2, length(donnees_codees)/2);
    %symboles = pskmod(bits_reshape,4,pi/4,InputType='bit'); % !! ici la constellation n'est pas la bonne 
    % car on a bien 11 -> -1-j ; 00 -> 1+j MAIS 10 -> 1-j et 01 -> -1+j 
    % au lieu de 10 -> -1+j et 01 -> 1-j dans la norme DVB-S (le facteur
    % 0.7 n'est pas grave mais il faut que tous les 1 deviennent -1 ou -0.7
    % et tous les 0 deviennent +1 ou +0.7
    %je le change ici :
    symboles=(1-2*donnees_codees(1:2:end))+1j*(1-2*donnees_codees(2:2:end));
    
    % Mise en forme
    h_m1 = rcosdesign(alpha,6,Ns, 'sqrt');
    
    retard = (6 * Ns); %!! le retard n'est pas de 8Ns mais 6Ns, vous l'aviez défini plus bas comme 8Ns
    %filtre numérique : introduit retard delongueur de moitié de sa longueur
    %modulation = [kron(symboles, [1, zeros(1, Ns-1)]) zeros(1,length(h_m1))]; %!! nombre de zeros = retard = 6Ns 
    % alors que lenght(h_m1)=6Ns+1
    %Le filtre introduit un retard de span * Ns, or les premiers bits ne
    %peuvent pas être utilisés donc on rajoute des 0 et pour pouvoir obtenir toutes les 
    % décisions on rajouter des 0 pour obtenir les informations sur les derniers bits codés.

    modulation = [kron(symboles, [1, zeros(1, Ns-1)]) zeros(1,retard)]; 
    signalQPSK=filter(h_m1, 1,modulation);

    % Bruit AWGN
    Px = mean(abs(signalQPSK).^2);
    sigma2=((Px*Ns)/(2*2*EbN0(i)));
    bruit = sqrt(sigma2) * (randn(size(signalQPSK)) + 1i * randn(size(signalQPSK)));
    signal_bruite = signalQPSK + bruit;

    % Filtrage de réception
    signal_recu = filter(h_m1, 1, signal_bruite);

    % Échantillonnage des symboles après correction du retard
    demodulation=signal_recu(retard+1:Ns:end);
   
    % Décodage soft
    demodulation_soft_r=real(demodulation);
    demodulation_soft_i=imag(demodulation);
    demodulation_soft=zeros(1,2*length(demodulation));
    demodulation_soft(1:2:end)=demodulation_soft_r;
    demodulation_soft(2:2:end)=demodulation_soft_i;
    %On voit que 5 échantillons avant la fin les chemins survivant
    %appartiennent au même chemin pére donc ca ne sert à rien de faire le
    %decodage jusqu'au début

    % 5*k bits avant k la contrainte touss les hemins survivants ont le m^me chemin père, cpté n'est pas nécéssaire [d'utiliser ' ...
    % l']entierete de la trame pour sortir les premiers bits décdéz, on fonction dans la fenetre glissante de 5*k avant
    decoded_soft = vitdec(demodulation_soft, trellis, 30, 'trunc', 'unquant');

    % Décodage hard
    bits_recu_hard = zeros(1, 2 * length(demodulation));
    bits_recu_hard=demodulation_soft<0;
    bits_recu_hard = reshape(bits_recu_hard, 1, []);
    decoded_hard = vitdec(bits_recu_hard, trellis, 30, 'trunc', 'hard');

    % Calcul des TEB

    %Et ici pas besoin d'enlever des éléments de bits car vous avez ajouté
    %des zéros au début (autant que de retard) puis vous avez supprimé le
    %retard
    TEB_soft(i)=mean(bits~=decoded_soft);
    TEB_hard(i)=mean(bits~=decoded_hard);

    
end

% Tracé des TEB
figure;
semilogy(EbN0_db, TEB_soft, 'r', 'DisplayName', 'Soft');
hold on;
semilogy(EbN0_db, TEB_hard, 'b', 'DisplayName', 'Hard');
hold on ;
semilogy(EbN0_db,qfunc(sqrt(2*EbN0)), 'g', 'DisplayName', 'TEB théorique');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend;
grid on;
title('Comparaison des TEB avec décodage soft et hard');

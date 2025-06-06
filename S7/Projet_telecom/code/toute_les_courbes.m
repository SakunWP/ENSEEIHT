%% Paramètres généraux
clear all
close all

% Paramètres du filtre de mise en forme
alpha = 0.35;

% Nombre de bits
N = 188*80;

% Facteur de suréchantillonnage et fréquence d'échantillonnage
Ns = 5;

% Génération des bits
bits = randi(2, 1, N) - 1;

% Rapport signal sur bruit
EbN0_db = [-4:0.5:4];
EbN0 = 10.^(EbN0_db ./ 10);

% Codage convolutif
trellis = poly2trellis(7, [171 133]);

% Initialisation des TEB
TEB_rs = zeros(size(EbN0_db));
TEB_sans_rs = zeros(size(EbN0_db));

poinconnage=[1 1 0 1];


for i = 1:length(EbN0_db)

    % Codage Reed-Solomon
    enc=comm.RSEncoder(204, 188, BitInput=true);
    bits_rs=enc(bits.');
    
    % Codage convolutif
    donnees_codees = convenc(bits_rs', trellis);
    donnees_codees_p = convenc(bits_rs', trellis, poinconnage);
    donnees_codees_sans_rs = convenc(bits, trellis);
    
    % Mapping QPSK
    bits_reshape=reshape(donnees_codees, 2, length(donnees_codees)/2);
    symboles=(1-2*donnees_codees(1:2:end))+1j*(1-2*donnees_codees(2:2:end));

     % Mapping QPSK sans rs
    bits_reshape_sans_rs=reshape(donnees_codees_sans_rs, 2, length(donnees_codees_sans_rs)/2);
    symboles_sans_rs=(1-2*donnees_codees_sans_rs(1:2:end))+1j*(1-2*donnees_codees_sans_rs(2:2:end));

    %mapping QPSK poinconnage + rs
    bits_reshape_p=reshape(donnees_codees_p, 2, length(donnees_codees_p)/2);
    symboles_p=(1-2*donnees_codees_p(1:2:end))+1j*(1-2*donnees_codees_p(2:2:end));
    
    % Mise en forme
    h_m1 = rcosdesign(alpha,6,Ns, 'sqrt');
    
    retard = (6 * Ns); %chaque filtre introduit un retard egale à la moitié de sa longeur
    modulation = [kron(symboles, [1, zeros(1, Ns-1)]) zeros(1,retard)]; %les premiers bits ne
    %peuvent pas être utilisés donc on rajoute des 0
    modulation_sans_rs = [kron(symboles_sans_rs, [1, zeros(1, Ns-1)]) zeros(1,retard)]; 
    modulation_p = [kron(symboles_p, [1, zeros(1, Ns-1)]) zeros(1,retard)]; 
    signalQPSK=filter(h_m1, 1,modulation);
    signalQPSK_sans_rs=filter(h_m1, 1,modulation_sans_rs);
    signalQPSK_p=filter(h_m1, 1,modulation_p);

    % Bruit AWGN
    Px = mean(abs(signalQPSK).^2);
    sigma2=((Px*Ns)/(2*2*EbN0(i)));
    bruit = sqrt(sigma2) * (randn(size(signalQPSK)) + 1i * randn(size(signalQPSK)));
    signal_bruite = signalQPSK + bruit;

     % Bruit AWGNb sans rs
    Px_sans_rs = mean(abs(signalQPSK_sans_rs).^2);
    sigma2_sans_rs=((Px_sans_rs*Ns)/(2*2*EbN0(i)));
    bruit_sans_rs = sqrt(sigma2_sans_rs) * (randn(size(signalQPSK_sans_rs)) + 1i * randn(size(signalQPSK_sans_rs)));
    signal_bruite_sans_rs = signalQPSK_sans_rs + bruit_sans_rs;

    %AWGN rs + poinconnage
    Px_p = mean(abs(signalQPSK_p).^2);
    sigma2_p=((Px_p*Ns)/(2*2*EbN0(i)));
    bruit_p = sqrt(sigma2_p) * (randn(size(signalQPSK_p)) + 1i * randn(size(signalQPSK_p)));
    signal_bruite_p = signalQPSK_p + bruit_p;

    % Filtrage de réception
    signal_recu = filter(h_m1, 1, signal_bruite);
    signal_recu_sans_rs = filter(h_m1, 1, signal_bruite_sans_rs);
    signal_recu_p = filter(h_m1, 1, signal_bruite_p);

    % Échantillonnage des symboles après correction du retard
    demodulation=signal_recu(retard+1:Ns:end); %on élimine les 0 avec retar +1
    demodulation_sans_rs=signal_recu_sans_rs(retard+1:Ns:end);
    demodulation_p=signal_recu_p(retard+1:Ns:end);

    %Demodulation soft conv + rs
    demodulation_soft_r=real(demodulation);
    demodulation_soft_i=imag(demodulation);
    demodulation_soft=zeros(1,2*length(demodulation));
    demodulation_soft(1:2:end)=demodulation_soft_r;
    demodulation_soft(2:2:end)=demodulation_soft_i;

    % démodulation soft
    demodulation_soft_r_sans_rs=real(demodulation_sans_rs);
    demodulation_soft_i_sans_rs=imag(demodulation_sans_rs);
    demodulation_soft_sans_rs=zeros(1,2*length(demodulation_sans_rs));
    demodulation_soft_sans_rs(1:2:end)=demodulation_soft_r_sans_rs;
    demodulation_soft_sans_rs(2:2:end)=demodulation_soft_i_sans_rs;

    % DEcodage soft poinconnage
    demodulation_soft_r_p=real(demodulation_p);
    demodulation_soft_i_p=imag(demodulation_p);
    demodulation_soft_p=zeros(1,2*length(demodulation_p));
    demodulation_soft_p(1:2:end)=demodulation_soft_r_p;
    demodulation_soft_p(2:2:end)=demodulation_soft_i_p;

    % Décodage hard
    bits_recu_hard = zeros(1, 2 * length(demodulation));
    bits_recu_hard=demodulation_soft_sans_rs<0;
    bits_recu_hard = reshape(bits_recu_hard, 1, []);
    decoded_hard = vitdec(bits_recu_hard, trellis, 35, 'trunc', 'hard');
    
    % décodage soft
    decode_conv = vitdec(demodulation_soft, trellis, 35, 'trunc', 'unquant');
    decode_conv_sans_rs = vitdec(demodulation_soft_sans_rs, trellis, 35, 'trunc', 'unquant');
    decoded_soft_p = vitdec(demodulation_soft_p, trellis, 35, 'trunc', 'unquant', poinconnage);

    % desentrelacement
    denc= comm.RSDecoder(204, 188, BitInput=true);
    decode_rs=denc(decode_conv.');
    decode_rs_p = denc(decoded_soft_p.');


    %calcul teb
    TEB_rs(i)=mean(bits~=decode_rs');
    TEB_sans_rs(i)=mean(bits~=decode_conv_sans_rs);
    TEB_rs_p(i)= mean(bits ~= decode_rs_p');
    TEB_hard(i) = mean(bits ~= decoded_hard);


    
end

% Tracé des TEB
figure;
semilogy(EbN0_db, TEB_rs, 'r', 'DisplayName', 'Soft avec RS');
hold on;
semilogy(EbN0_db, TEB_sans_rs, 'b', 'DisplayName', 'Soft');
hold on;
semilogy(EbN0_db, TEB_rs_p, 'k', 'DisplayName', 'RS + poinconnage');
hold on;
semilogy(EbN0_db, TEB_hard, 'c', 'DisplayName', 'hard');
hold on;
semilogy(EbN0_db,qfunc(sqrt(2*EbN0)), 'g', 'DisplayName', 'TEB théorique');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend;
grid on;
title('Comparaison des TEB');

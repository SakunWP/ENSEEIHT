%% Paramètres généraux
clear all
close all
% Paramètres du filtre de mise en forme
alpha = 0.35;
% Nombre de bits
N = 188*80;
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
TEB_rs = zeros(size(EbN0_db));
for i = 1:length(EbN0_db)
 % Codage Reed-Solomon
 enc=comm.RSEncoder(204, 188, BitInput=true);
 bits_rs=enc(bits.');

 octets_rs = bitsToOctets(bits_rs);
 laceur = convdeintrlv(octets_rs,12,17);
 bits_rs= octetsToBits(laceur);
 bits_rs = transpose(bits_rs);
 
 % Codage convolutif
 donnees_codees = convenc(bits_rs', trellis);
 
 % Mapping QPSK
 bits_reshape=reshape(donnees_codees, 2, length(donnees_codees)/2);
 symboles=(1-2*donnees_codees(1:2:end))+1j*(1-2*donnees_codees(2:2:end));
 
 % Mise en forme
 h_m1 = rcosdesign(alpha,6,Ns, 'sqrt');
 
 retard = (6 * Ns);
 modulation = [kron(symboles, [1, zeros(1, Ns-1)]) zeros(1,retard)]; 
 signalQPSK=filter(h_m1, 1,modulation);
 % Bruit AWGN
 Px = mean(abs(signalQPSK).^2);
 sigma2= (Px*Ns)/(2*2*EbN0(i));
 bruit = sqrt(sigma2) * (randn(size(signalQPSK)) + 1i * randn(size(signalQPSK)));
 signal_bruite = signalQPSK + bruit;
 % Filtrage de réception
 signal_recu = filter(h_m1, 1, signal_bruite);
 % Échantillonnage des symboles après correction du retard
 demodulation=signal_recu(retard+1:Ns:end);
 demodulation_soft_r=real(demodulation);
 demodulation_soft_i=imag(demodulation);
 demodulation_soft=zeros(1,2*length(demodulation));
 demodulation_soft(1:2:end)=demodulation_soft_r;
 demodulation_soft(2:2:end)=demodulation_soft_i;
 
 decode_conv = vitdec(demodulation_soft, trellis, 30, 'trunc', 'unquant');

 %decentrelacement

 des = bitsToOctets(decode_conv);
 des2 =convdeintrlv(des,12,17);
 decode_conv = octetsToBits(des2);
 
 denc= comm.RSDecoder(204, 188, BitInput=true);
 decode_rs=denc(decode_conv.');
 TEB_rs(i)=mean(bits~=decode_rs');
 
end
% Tracé des TEB
figure;
semilogy(EbN0_db, TEB_rs, 'r', 'DisplayName', 'Soft avec RS');
hold on;
semilogy(EbN0_db,qfunc(sqrt(2*EbN0)), 'g', 'DisplayName', 'TEB théorique');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('TEB');
legend;
grid on;
title('Comparaison des TEB avec décodage soft et hard');
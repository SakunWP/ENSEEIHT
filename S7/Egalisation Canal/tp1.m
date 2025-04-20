% Script pour calculer le BER en modulation BPSK/QPSK dans des canaux avec ISI

close all;
clear all;

%% Paramètres de simulation
M = 4; % Modulation : 2 pour BPSK, 4 pour QPSK
N = 1000000; % Nombre de bits ou symboles transmis
Es_N0_dB = 0:3:30; % Valeurs de Eb/N0 en dB

% Paramètres du canal à trajets multiples
hc = [1 0.8*exp(1i*pi/3) 0.3*exp(1i*pi/6)]; % Coefficients du canal
Lc = length(hc); % Longueur du canal
ChannelDelay = 0; % Retard du canal

% Initialisation des erreurs pour chaque méthode d'égalisation
nErr_zfinf = zeros(1, length(Es_N0_dB));
nErr_mmse = zeros(1, length(Es_N0_dB));
nErr_Hat = zeros(1, length(Es_N0_dB));
nErr_Hat_mmse = zeros(1, length(Es_N0_dB));
nErr_MLSE = zeros(1, length(Es_N0_dB));

figure();
tiledlayout(ceil(length(Es_N0_dB)/2), 2);

for ii = 1:length(Es_N0_dB)
    % Génération des bits
    bits = rand(2, N) > 0.5;
    s = 1/sqrt(2) * ((1-2*bits(1, :)) + 1j*(1-2*bits(2, :))); % Modulation QPSK
    sigs2 = var(s);
    
    % Filtrage par le canal
    z = conv(hc, s);
    sig2b = 10^(-Es_N0_dB(ii)/10);
    n = sqrt(sig2b/2) * (randn(1, N+Lc-1) + 1j*randn(1, N+Lc-1)); % Bruit AWGN
    y = z + n; % Signal reçu avec bruit

    %% Égalisation ZF (Zero-Forcing)
    s_zf = filter(1, hc, y);
    bhat_zf = [real(s_zf(1:N)) < 0; imag(s_zf(1:N)) < 0];
    nErr_zfinf(ii) = sum(bits(:) ~= bhat_zf(:));
    
    %% Égalisation MMSE (Minimum Mean Square Error)
    deltac = zeros(1, 2 * Lc - 1);
    deltac(Lc) = 1;
    Nmmse = 200;
    [r, p, k] = residuez(fliplr(conj(hc)), (conv(hc, fliplr(conj(hc))) + (sig2b/sigs2) * deltac));
    [w_mmseinf] = ComputeRI(Nmmse, r, p, k);
    s_mmse = conv(w_mmseinf, y);
    bhat_mmse = [real(s_mmse(Nmmse:N+Nmmse-1)) < 0; imag(s_mmse(Nmmse:N+Nmmse-1)) < 0];
    nErr_mmse(ii) = sum(bits(:) ~= bhat_mmse(:));

    %% Égalisation FIR ZF
    Nw = 10;
    d = 5;
    H = toeplitz([hc(1) zeros(1,Nw-1)]',[hc, zeros(1,Nw-1)]);
    Ry = (conj(H)*H.');
    p = zeros(Nw+Lc-1,1);
    P = (H.'*inv((Ry))*conj(H));
    [alpha,dopt] = max(diag(abs(P)));
    p(dopt) = 1;
    Gamma = conj(H)*p;
    w_zf_fir = (inv(Ry)*Gamma).';
    shat = conv(w_zf_fir, y);
    shat = shat(dopt:end);
    bHat = [real(shat(1:N))<0; imag(shat(1:N))<0];
    nErr_Hat(ii) = sum(bits(:) ~= bHat(:));
    
    %% Égalisation FIR MMSE
    w_mmse_fir = inv(Ry + (sig2b/sigs2)*eye(size(Ry)))*Gamma;
    s_hat_mmse = conv(w_mmse_fir, y);
    s_hat_mmse = s_hat_mmse(dopt:end);
    bHat_mmse = [real(s_hat_mmse(1:N))<0; imag(s_hat_mmse(1:N))<0];
    nErr_Hat_mmse(ii) = sum(bits(:) ~= bHat_mmse(:));
    
    %% Égalisation MLSE (Maximum Likelihood Sequence Estimation)
    const = qammod((0:M-1)', M, 'gray', 'UnitAveragePower', true);
    tblen = 16;
    nsamp = 1;
    s_ml = mlseeq(y, hc, const, tblen, 'rst', nsamp, [], []);
    bhat_ml = [real(s_ml(1:N)) < 0; imag(s_ml(1:N)) < 0];
    nErr_MLSE(ii) = sum(bits(:) ~= bhat_ml(:));
    
    %% Affichage de la DSP
    nexttile;
    [dsp_r, f] = pwelch(y, [], [], [], 'twosided');
    plot(f, 10*log10(dsp_r));
    title(sprintf('DSP reception pour E_s/N_0 = %d dB', Es_N0_dB(ii)));
    xlabel('Fréquence');
    ylabel('DSP (dB)');
    grid on;
end

% Calcul du BER
simBer_zfinf = nErr_zfinf / N / log2(M);
simBer_mmse = nErr_mmse / N / log2(M);
simBer_Hat = nErr_Hat / N / log2(M);
simBer_Hat_mmse = nErr_Hat_mmse / N / log2(M);
simBer_MLSE = nErr_MLSE / N / log2(M);

% Tracé du BER
figure;
semilogy(Es_N0_dB, simBer_zfinf, 'bs-', 'Linewidth', 2);
hold on;
semilogy(Es_N0_dB, simBer_mmse, 'p-', 'Linewidth', 2);
semilogy(Es_N0_dB, simBer_Hat, 'g-', 'Linewidth', 2);
semilogy(Es_N0_dB, simBer_Hat_mmse, 'm-', 'Linewidth', 2);
semilogy(Es_N0_dB, simBer_MLSE, 'r-', 'Linewidth', 2);
grid on;
legend('ZF', 'MMSE', 'ZF RIF', 'MMSE RIF', 'MLSE');
xlabel('E_s/N_0 (dB)');
ylabel('BER');
title('Bit Error Rate pour QPSK en canal ISI avec égalisation');


% % Affichage de la réponse impulsionnelle de l'égaliseur MMSE
% figure;
% stem(real(w_mmseinf), 'r-');
% title('Réponse impulsionnelle MMSE');
% xlabel('Index temporel');
% ylabel('Amplitude');
% 
% % Constellation du signal reçu pour le bruit le plus faible
% figure;
% plot(real(y), imag(y), 'o');
% title('Constellation à la réception');
% xlabel('In-Phase');
% ylabel('Quadrature');
% grid on;
% axis equal;

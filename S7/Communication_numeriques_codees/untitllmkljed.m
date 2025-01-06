%% Paramètres généraux
bw = 33000;
alpha = 0.35;
Rs = bw / (1 + alpha);
Ts = 1 / Rs;
Rb = 2 * Rs;
N = 20;
Ns = 6;
Fe = 2 * bw; 
Te = 1 / Fe;
bits = randi([0, 1], 1, N);

% Mapping QPSK
bits_reshape = reshape(bits, 2, length(bits) / 2);
symboles = pskmod(bits_reshape, 4, pi/4, InputType='bit');

% Mise en forme
h_m1 = rcosdesign(alpha, 8, Ns);
modulation = kron(symboles.', [1 zeros(1, Ns - 1)]);
signalQPSK = filter(h_m1, 1, modulation);

% Signal reception
signal_recu = filter(h_m1, 1, signalQPSK);

% Correction du retard
delay = (8 * Ns) / 2;
signal_recu_corrige = signal_recu(delay + 1:end);

% Échantillonnage
demodulation = signal_recu_corrige(1:Ns:end);

% Décodage QPSK
detecte = pskdemod(demodulation, 4, pi/4, OutputType='bit');
detecte_reshape = reshape(detecte, 1, []);

% Calcul des erreurs
erreurs = bits ~= detecte_reshape;
TEB = sum(erreurs) / N;

disp(['TEB = ', num2str(TEB)]);


hold on
semilogy(EbN0,qfunc(sqrt(2*EbN0)), 'g')

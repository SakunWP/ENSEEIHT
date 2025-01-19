close all;

%% variables 
N = 16;
N_actif = 16;
nb_bits = 10000;

S=zeros(N, nb_bits);
%% modulateur 

    % Mapping
for i=1:N_actif
    S(i,:) = randi([0 1],1,nb_bits)*2 -1;
end    
    


    % filtrage
Xe = ifft(S,N);
Y = reshape(Xe, 1, nb_bits*N);
[pxx, f] = pwelch(Y, [], [], [], 16); 
dsp_avant_canal = pxx*16 / sum(pxx); 
nexttile
title('DSP entrée du canal');
plot(10*log(dsp_avant_canal))
xlabel('fréquence')
ylabel('dsp')
%% canal de transmission

h=[0.407, 0.815, 0.407];

canal = filter(h,1,Y);


%% DSP
[pxx, f] = pwelch(canal, [], [], [], 16); 
dsp_normalisee = pxx*16 / sum(pxx); 
%figure
nexttile
title('DSP sortie du canal');
plot(10*log(dsp_normalisee))
xlabel('fréquence')
ylabel('dsp')
%grid on

 
%% démodulation

signal_recu = reshape(canal,N,nb_bits);
symbols_recu = fft(signal_recu,N);

bits_recu = real(symbols_recu);

%% TEB
     Y_fin = [];
     for i=1:length(bits_recu)
        if real(bits_recu)>0
            Y_fin = [Y_fin 1];
        else
            Y_fin= [Y_fin -1];
        end
     end
     TEB = mean(S~=Y_fin,"all")

 %% Constellation

porteuse6 = symbols_recu(6, :);
porteuse15 = symbols_recu(15, :);


figure('Name','constellation porteuse 6')
scatter(real(porteuse6), imag(porteuse6))
xlabel('partie réel')
ylabel('partie imaginaire')


figure('Name','constellation porteuse 15')
scatter(real(porteuse15), imag(porteuse15))
xlabel('partie réel')
ylabel('partie imaginaire')

   %% module et phase

% Transformée de Fourier de la réponse impulsionnelle
H_f = fft(h, N); 
plage = (1:16); 

% Module et phase
module = abs(H_f);       % Amplitude
phase = angle(H_f);      % Phase

% Tracé du module
figure;
subplot(2, 1, 1);
plot(plage, module, 'b', 'LineWidth', 1.5);
title('Module de la réponse en fréquence du canal');
xlabel('Fréquence normalisée');
ylabel('|H(f)|');
grid on;

% Tracé de la phase
subplot(2, 1, 2);
plot(plage, phase, 'r', 'LineWidth', 1.5);
title('Phase de la réponse en fréquence du canal');
xlabel('Fréquence normalisée');
ylabel('Phase H(f) [rad]');
grid on;

     

    
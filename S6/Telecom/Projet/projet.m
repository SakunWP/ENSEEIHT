close all

%roll-off

alpha = 0.35;

%fréquene d'échantillonage
Fe = 24000 ; %Hz

Te= 1/Fe;

%debit binaire 
Rb= 3000; %bits/s

Tb= 1/Rb;

%fréquence porteuse 
Fp= 2000 %Hz

n=100;

Ts = 2*Tb;

Rs= 1/Ts

Ns= floor(Ts/Te);


%mapping  --------
bits = randi([0,1],[2*n,1])
%Symbol1 = 2*bit1 - 1
for i=1:n
    if bits(i)==1 && bits(i+1)==1
        symbol(i)= exp(1j*pi/4);
    elseif bits(i)==0 && bits(i+1)==1
        symbol(i)= exp(1j*3*pi/4);
    elseif bits(i)==0 && bits(i+1)==0
        symbol(i)= exp(1j*5*pi/4);
    elseif bits(i)==1 && bits(i+1)==0
        symbol(i)= exp(1j*7*pi/4);
    end
end

pDirac = kron(symbol,[1,zeros(1,Ns-1)]);
%l= length(pDirac);
%h = rcosdesign(alpha,floor(l/Ns)+1,Ns);
l=20;
h = rcosdesign(alpha, l, Ns, 'sqrt'); 
%g = conv(h,hr);
x = filter(h,1,pDirac);
%x= conv(pDirac,h,'same');
[DSP,f] = pwelch(x,[],[],[],Fe,'twosided','centered');
%plot(f,DSP)

x_I = real(x);
x_Q = imag(x);

% Échelle temporelle
t = (0:length(x)-1) * Te * 10000;

% Tracé des signaux I et Q
figure;
subplot(2, 1, 1);
plot(t, x_I);
title('Signal en phase (I)');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

subplot(2, 1, 2);
plot(t, x_Q);
title('Signal en quadrature (Q)');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

% Modulation en bande passante
mod_I = cos(2 * pi * Fp * t);
mod_Q = sin(2 * pi * Fp * t);
mod_signal = x_I .* mod_I - x_Q .* mod_Q;

% Tracé du signal modulé
figure;
plot(t, mod_signal);
title('Signal transmis sur fréquence porteuse');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

% Affichage de la DSP
figure;
plot(f, 10*log10(DSP));
title('DSP du signal filtré');
xlabel('Fréquence (Hz)');
ylabel('Densité spectrale de puissance (dB/Hz)');
grid on;





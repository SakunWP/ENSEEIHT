close all;

Fe = 24000; %Hz
Te = 1/Fe;
Rb = 3000; %bits/s
Tb = 1/Rb;
n = 1000;

%1 et 2
Ts = Tb;
Ns = floor(Ts/Te); % Ns = 8

bit = randi([0,1],[n,1]);
Symbol = zeros(1,length(bit));
Symbol(bit==1) = 1;
Symbol(bit==0) = -1;

pDirac = kron(Symbol,[1,zeros(1,Ns)]);

surech = zeros(1,Ns);
surech(1) = 1;

pDirac = kron(Symbol,surech);

h = ones(1,Ns);
hr = h;
g = conv(h,hr);

z = filter(g,1,pDirac);


% Question 1
temps = [0:Te:(length(z)-1)*Te];
figure(1);
plot(temps,z);
xlabel("Temps(s)");
ylabel("Amplitude");
title("Signal passé par le demodulateur bdb");
grid on;
temps2 = [0:Te:150*Te];
figure(2);
plot(temps2,z(1:151));
xlabel("Temps(s)");
ylabel("Amplitude");
title("Signal tronqué");
grid on;

% Question 2
%g
figure(3);
plot(g);
xlabel("Temps(s)");
ylabel("Amplitude");
title("Signal g");
grid on;
% Question 3
% n0 = 8 pour respecter le critere de Nyquist
% g(n0) /= 0 | g(n0 + mNs) = 0

% Question 4
%diagramme oeil
diagramme_oeil = reshape(z,Ns,floor(length(z)/Ns)) ; 
figure(4);
plot(diagramme_oeil);
xlabel("Temps(s)");
ylabel("Amplitude");
title("Diagramme de l'oeil");
grid on;

% Question 5

% Question 6

% Question 7 
n0 = Ns;
echantillons = z(n0:Ns:end);

% Question 8
bitDemap = ( sign(echantillons)+1 ) / 2; % sign(<0) = -1 | sign(0) = 0 | sign(>0) = 1
erreur = abs(bit-bitDemap');                 
TEB = mean(erreur)

% Question 9
n0 = 3;
echantillons = z(n0:Ns:end);

bitDemap = ( sign(echantillons)+1 ) / 2;
erreur = abs(bit-bitDemap');                 
TEB3 = mean(erreur)

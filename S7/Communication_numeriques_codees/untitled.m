%% Projet Canal
%% Paramètres
n1 = 2;
n2 = 3;
Ts2 = n2/3000;
Ts = n1/3000;
Te = 1/24000;
Ns = Ts/Te;
Ns2 = Ts2/Te;
fp = 2000;
N = 300;
Fe = 1/Te;
bits = randi(2, 1, N) - 1;

alpha = 0.35
Rs2=Rb/2; %%Debit symbole en fonction du débiit binaire

%% Mapping
% Mapping QPSK
bits1 = bit2int(bits', 2);
symboles = pskmod(bits1,4);


%% Mise en forme
h_m1 = rcosdesign(alpha, 10, Ns);
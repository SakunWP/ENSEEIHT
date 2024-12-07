clear all ; close all;

% Constantes
n_bits = 1000; 
bits = randi([0 1], n_bits, 1); 

Fe = 24000;
Te = 1/Fe; 
Rb = 3000; 
Tb = 1/Rb; 


%% 4. Etude de l'impact du bruit et du filtrage adapté, notion d'efficacité en puissance
% BRUIT
EbN0 = 0:8;

% Chaine 1 
figure('name', 'Chaine 1')

Ts = Tb;          
Ns = Fe * Ts;       
h = ones(1, Ns);   
hr1 = ones(1, Ns);  
n0 = Ns;          

% Sans bruit
    Symbol = (2*bits - 1)';
    pDirac = kron(Symbol, [1, zeros(1, Ns-1)]); 

    x1 = filter(h, 1, pDirac); 
    z1 = filter(hr1, 1, x1); 

    echantillon = z1(n0:Ns:end);
    bits_sortie1 = (sign(echantillon) + 1) / 2;
    TEB1 = mean(bits_sortie1' ~= bits);

    % Diagramme de l'oeil
    nexttile
    plot(reshape(z1,Ns,length(z1)/Ns));
    title('Diagramme de l''oeil');

    fprintf("TEB chaine 1 : " + TEB1 + "\n");

% Avec bruit
TEB1_bruit = zeros(1, length(EbN0));
z1_bruit = zeros(length(EbN0), length(z1));
for i = 1:length(EbN0)

    % Canal de propagation
    sigma2 = mean(x1.^2)*Ns/(2*10^(EbN0(i)/10));
    bruit = sqrt(sigma2)*randn(1, Ns*n_bits);
    r1 = x1 + bruit;

    z1_bruit(i,:) = filter(hr1, 1, r1);

    echantillon = z1_bruit(i,n0:Ns:end);
    bits_sortie = (sign(echantillon) + 1) / 2;
    TEB1_bruit(i) = mean(bits_sortie' ~= bits);
end

    nexttile
    plot(reshape(z1_bruit(1, :),Ns,length(z1_bruit(1, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 0');

    nexttile
    plot(reshape(z1_bruit(9, :),Ns,length(z1_bruit(9, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 8');

    % Pour Eb/N0 = 100
    EbN0100 = 100;
    sigma2 = mean(x1.^2)*Ns/(2*10^(EbN0100/10));
    bruit = sqrt(sigma2)*randn(1, Ns*n_bits);
    r1 = x1 + bruit;
    z1_bruit100 = filter(hr1, 1, r1);

    echantillon = z1_bruit100(n0:Ns:end);
    bits_sortie = (sign(echantillon) + 1) / 2;
    TEB1_bruit(i) = mean(bits_sortie' ~= bits);

    nexttile
    plot(reshape(z1_bruit100,Ns,length(z1_bruit100)/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 100');

    % TEB Obtenu et théorique
    nexttile
    TEB1_theorique = qfunc(sqrt(2*(10.^(EbN0/10))));
    semilogy(EbN0,TEB1_bruit)
    hold on
    semilogy(EbN0,TEB1_theorique)
    hold off
    title("Comparaison entre le TEB obtenu et le TEB théorique")
    legend("TEB obtenu","TEB théorique")
    xlabel("Eb/N0 (en dB)")
    ylabel("TEB")

% Chaine 2 
figure('name', 'Chaine 2')

Ts = Tb;           
Ns = Fe * Ts;     
h = ones(1, Ns);    
hr2 = ones(1, floor(Ns/2)); 
n0 = floor(Ns/2);       

% Sans bruit
    % Mapping
    Symbol = (2*bits - 1)';
    pDirac = kron(Symbol, [1, zeros(1, Ns-1)]);

    x2 = filter(h, 1, pDirac);
    z2 = filter(hr2, 1, x2);

    echantillon = z2(n0:Ns:end);
    bits_sortie2 = (sign(echantillon) + 1) / 2;
    TEB2 = mean(bits_sortie2' ~= bits);

    % Diagramme de l'oeil
    nexttile
    plot(reshape(z2,Ns,length(z2)/Ns));
    title('Diagramme de l''oeil');

    fprintf("TEB chaine 2 : " + TEB2 + "\n");

% Avec bruit
TEB2_bruit = zeros(1, length(EbN0));
z2_bruit = zeros(length(EbN0), length(z2));
for i = 1:length(EbN0)

    % Canal de propagation
    sigma2 = mean(x2.^2)*Ns/(2*10^(EbN0(i)/10));
    bruit = sqrt(sigma2)*randn(1, Ns*n_bits);
    r2 = x2 + bruit;

    z2_bruit(i, :) = filter(hr2, 1, r2);

    echantillon = z2_bruit(i,n0:Ns:end);
    bits_sortie = (sign(echantillon) + 1) / 2;
    TEB2_bruit(i) = mean(bits_sortie' ~= bits);
end

    % Diagramme de l'oeil pour deux valeurs Eb / N0 différentes
    nexttile
    plot(reshape(z2_bruit(1, :),Ns,length(z2_bruit(1, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 0');

    nexttile
    plot(reshape(z2_bruit(9, :),Ns,length(z2_bruit(9, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 8');

    % Pour Eb/N0 = 100
    EbN0100 = 100;
    sigma2 = mean(x2.^2)*Ns/(2*10^(EbN0100/10));
    bruit = sqrt(sigma2)*randn(1, Ns*n_bits);
    r2 = x2 + bruit;
    z2_bruit100 = filter(hr2, 1, r2);

    echantillon = z2_bruit100(n0:Ns:end);
    bits_sortie = (sign(echantillon) + 1) / 2;
    TEB2_bruit(i) = mean(bits_sortie' ~= bits);

    nexttile
    plot(reshape(z2_bruit100,Ns,length(z2_bruit100)/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 100');

    % TEB Obtenu et théorique
    nexttile
    TEB2_theorique = qfunc(sqrt(10.^(EbN0/10)));
    semilogy(EbN0,TEB2_bruit)
    hold on
    semilogy(EbN0,TEB2_theorique)
    hold off
    title("Comparaison entre le TEB obtenu et le TEB théorique")
    legend("TEB obtenu","TEB théorique")
    xlabel("Eb/N0 (en dB)")
    ylabel("TEB")
   

% Chaine 3 
figure('name', 'Chaine 3')

Ts = Tb;      
Ns = Fe * Ts;   
h = ones(1, Ns);
hr3 = ones(1, Ns); 
n0 = Ns;           

% Sans bruit
    % Mapping
    LUT = [-3, -1, 3, 1];
    Symbol = LUT(1+bi2de(reshape(bits, n_bits/2, 2), 'left-msb'));
    pDirac = kron(Symbol, [1, zeros(1, Ns-1)]);

    x3 = filter(h, 1, pDirac);
    z3 = filter(hr3, 1, x3);

    echantillon = z3(n0:Ns:end);
    symboles = zeros(1,length(echantillon));
    symboles(echantillon > 2 * Ns) = 3;
    symboles(echantillon >= 0 & echantillon <= 2 * Ns) = 1;
    symboles(echantillon < -2 * Ns) = -3;
    symboles(echantillon >= -2 * Ns & echantillon < 0) = -1;

    [~, rank] = ismember(symboles, LUT);
    bits_sortie3 = reshape(de2bi(rank-1, 'left-msb'),1,n_bits);
    TEB3 = mean(bits_sortie3' ~= bits);

    % Diagramme de l'oeil
    nexttile
    plot(reshape(z3,Ns,length(z3)/Ns));
    title('Diagramme de l''oeil');

    fprintf("TEB chaine 3 : " + TEB3 + "\n");

% Avec bruit
TEB3_bruit = zeros(1, length(EbN0));
z3_bruit = zeros(length(EbN0), length(z3));
for i = 1:length(EbN0)

    % Canal de propagation
    sigma2 = mean(x3.^2)*Ns/(4*10^(EbN0(i)/10));
    bruit = sqrt(sigma2)*randn(1, Ns*n_bits/2);
    r3 = x3 + bruit;

    z3_bruit(i, :) = filter(hr3, 1, r3);

    echantillon = z3_bruit(i,n0:Ns:end);
    symboles = zeros(1,length(echantillon));
    symboles(echantillon > 2 * Ns) = 3;
    symboles(echantillon >= 0 & echantillon <= 2 * Ns) = 1;
    symboles(echantillon < -2 * Ns) = -3;
    symboles(echantillon >= -2 * Ns & echantillon < 0) = -1;

    [~, rank] = ismember(symboles, LUT);
    bits_sortie = reshape(de2bi(rank-1, 'left-msb'),1,n_bits);
    TEB3_bruit(i) = mean(bits_sortie' ~= bits);
end

    % Diagramme de l'oeil pour deux valeurs Eb/N0 différentes
    nexttile
    plot(reshape(z3_bruit(1, :),Ns,length(z3_bruit(1, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 1');

    nexttile
    plot(reshape(z3_bruit(9, :),Ns,length(z3_bruit(9, :))/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 8');

    % Pour Eb/N0 = 100

    sigma2 = mean(x3.^2)*Ns/(4*10^(EbN0100/10));
    bruit = sqrt(sigma2)*randn(1, Ns*n_bits/2);
    r3 = x3 + bruit;

    z3_bruit100 = filter(hr3, 1, r3);

    echantillon = z3_bruit100(n0:Ns:end);
    symboles = zeros(1,length(echantillon));
    symboles(echantillon > 2 * Ns) = 3;
    symboles(echantillon >= 0 & echantillon <= 2 * Ns) = 1;
    symboles(echantillon < -2 * Ns) = -3;
    symboles(echantillon >= -2 * Ns & echantillon < 0) = -1;

    [~, rank] = ismember(symboles, LUT);
    bits_sortie = reshape(de2bi(rank-1, 'left-msb'),1,n_bits);
    TEB3_bruit100 = mean(bits_sortie' ~= bits);

    nexttile
    plot(reshape(z3_bruit100,Ns,length(z3_bruit100)/Ns));
    title('Diagramme de l''oeil pour Eb/N0 = 100');

    % TEB Obtenu et théorique
    nexttile
    TEB3_theorique = (3/4)*qfunc(sqrt((4/5)*(10.^(EbN0/10)))); 
    semilogy(EbN0,TEB3_bruit)
    hold on
    semilogy(EbN0,TEB3_theorique)
    hold off
    title("Comparaison entre le TEB obtenu et le TEB théorique")
    legend("TEB obtenu","TEB théorique")
    xlabel("Eb/N0 (en dB)")
    ylabel("TEB")

    figure;
    semilogy(EbN0,TEB1_bruit);
    hold on;
    semilogy(EbN0,TEB2_bruit);
    semilogy(EbN0,TEB3_bruit)
    legend("TEB1","TEB2","TEB3");

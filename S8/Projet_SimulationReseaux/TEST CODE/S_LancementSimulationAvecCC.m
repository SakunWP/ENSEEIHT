%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Script Simulation %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close all

%% Parametres simulation
% Parametres abstraction de la couche physique
PhyParam.Ncodes = 54; % Nombre de codes

% Parametres de l'abstraction de couche MAC 
MACParam.Transmission = 1; % Duree de transmission
MACParam.Traitement = 5; % Duree de traitement.
MACParam.Rand = 3; %  % Rand maximum - d_rand.
MACParam.NMaxTransmission = 10; %  Nombre max de transmission possible. 
% Scenario de traffic

CCParam.ChargeAvantOverload = 10; % Nombre de nouveaux utilisateurs par time slot avant la surcharge.
CCParam.ChargePendantOverload = 30; % Nombre de nouveaux utilisateurs par time slot durant la surcharge.
CCParam.ChargeApresOverload = 15; % Nombre de nouveaux utilisateurs par time slot apres la surcharge. 
dureeOverload = 200; % Duree en nombre de slots de la surcharge. 
ProfilTrafic = [CCParam.ChargeAvantOverload*ones(1,100) CCParam.ChargePendantOverload*ones(1,dureeOverload) CCParam.ChargeApresOverload*ones(1,300)]; % Generation du profil de trafic. 
idxSlotStats = 101:(101+dureeOverload); % indice des slots ou on calcule les stats. 
NbSlots = length(ProfilTrafic);

% Parametres du controle de charge
CCParam.paccessVar = 0.1; % Probabilite d'acces 
CCParam.NslotBarringMaxVar = 100; % Nombre de slots max ou l'utilisateur est bloque. 

% MonteCarlo
MonteCarlo = 10; % Nombre iteration de MonteCarlo
SaveThroughputSimulation = nan(MonteCarlo,NbSlots); %Throughput simulations
%---- A remplir ------
% metriques etudiees.... 
TauxRefusConnection = 0; %Taux de refus de connection pendant l'overload
SaveTempsPasse = 0; %Temps necessaire pour se connecter
Refus = zeros(1,3);
NSlots = zeros(1,3);
RefusOptimal = zeros(5,9);
%----------------------


%% Simulateur
for j = 1:9
    CCParam.paccess = j*CCParam.paccessVar;
    % CCParam.paccess = 5*CCParam.paccessVar;
    for i = 1:3
        CCParam.NslotBarringMax = CCParam.NslotBarringMaxVar*i;
        % CCParam.NslotBarringMax = CCParam.NslotBarringMaxVar*2;
        if [i,j] == [1,6] % Choix du couple
        
        for k = 1:MonteCarlo
            fprintf('Iter : %d \n',k);
            [SaveThroughputSimulation(k,:),Utilisateurs,SaveTempsPasse,TauxRefusConnection] = F_SimulateurAvecCC(ProfilTrafic,PhyParam,MACParam,CCParam,idxSlotStats);
        
        end
        
        %% Détection meilleure valeur

        RefusOptimal(i,j) = 1-TauxRefusConnection;
        [Valeur, indice] = min(RefusOptimal,[], "all");
        

        %% Plot
        
        Refus(1,i) = 1-TauxRefusConnection;

        Temps(1,i) = SaveTempsPasse;

        NSlots(1,i) = CCParam.NslotBarringMaxVar*i;

        AverageThroughput = mean(SaveThroughputSimulation,1);

        figure
        plot(AverageThroughput);
        title(['Pacces = ', num2str(CCParam.paccess), ', NslotBarring = ', num2str(CCParam.NslotBarringMax)]);
        xlabel('Time slots','interpreter','latex');
        ylabel('Throughput station de base','interpreter','latex');
        grid on;
        end
    end
end
    
figure
scatter(NSlots,Refus);
title("Probabilités d'accès =", CCParam.paccess);
xlabel('NSlotBarring','interpreter','latex');
ylabel('Taux de Refus','interpreter','latex');
grid on;

figure
scatter(NSlots,Temps);
title("Probabilités d'accès =", CCParam.paccess);
xlabel('NSlotBarring','interpreter','latex');
ylabel('Temps moyen passé dans le système','interpreter','latex');
grid on;



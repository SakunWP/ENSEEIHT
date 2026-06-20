function [ThroughputSlots,Utilisateurs,TempsConnection,TauxConnection] = F_SimulateurAvecCC(ProfilTrafic,PhyParam,MACParam,CCParam,idxSlotStats)
% ProfilTrafic : Profil de trafic, nombre de nouveaux utilisateurs par time slot
% PhyParam : Parametres de couche physique
% MACParam : Parametres de couche MAC
% CCParam : Parameters de controle de charge
% idxSlotStats : indice des slots ou on calcule les stats.
NbSlots = length(ProfilTrafic); % Nombre de time slots simules.
Utilisateurs = zeros(sum(ProfilTrafic),6); % Matrice Utilisateurs, attention differente de la precedente..
idxArriveeUtilisateurs = 1; % Pour remplir la matrice utilisateurs.
% Colonne numero 1 - Time slot actuel
% Colonne numero 2 - Flag Stats : On est en overload ou pas (1 ou 0) / On calcule des stats ou pas (c'est pareil)
% Colonne numero 3 - Time slot d'arrivee dans le systeme
% Colonne numero 4 - Time slot sortie du systeme
% Colonne numero 5 - Nombre de transmissions
% Colonne numero 6 - Bool Reussite Transmission

for Slot = 1:NbSlots
    
    if min(abs(idxSlotStats-Slot)) == 0
        FlagStats = 1;
    else
        FlagStats = 0;
    end
    
    % Arrivee des nouveaux utilisateurs
    Utilisateurs(idxArriveeUtilisateurs:(idxArriveeUtilisateurs+ProfilTrafic(Slot)-1),1) = Slot;
    Utilisateurs(idxArriveeUtilisateurs:(idxArriveeUtilisateurs+ProfilTrafic(Slot)-1),2) = FlagStats;
    Utilisateurs(idxArriveeUtilisateurs:(idxArriveeUtilisateurs+ProfilTrafic(Slot)-1),3) = Slot;
    idxArriveeUtilisateurs = idxArriveeUtilisateurs + ProfilTrafic(Slot);
    
    % Controle de charge
    
    %Ici il y avait un if mais j'ai supprimé

    Utilisateurs = ApplicationControleDeCharge(Utilisateurs,Slot,CCParam);
    
    
    % Simulation des transmissions
    
    [Utilisateurs, ThroughputSlots(Slot)] = SimulationTransmission(Utilisateurs,Slot,PhyParam,MACParam);
    
    
    % ---- Stats ---- %

    TempsConnection = 0;
    TauxConnection = 0;

    for i=1:sum(ProfilTrafic)
        if Utilisateurs(i,4) ~= 0
            TempsConnectionUser = (Utilisateurs(i,4)-Utilisateurs(i,3));
            TempsConnection = TempsConnection + TempsConnectionUser;
        end
        if i>=1001 && i<=7015
            Taux = Utilisateurs(i,6);
            TauxConnection = TauxConnection + Taux;
        end
    end

    TempsConnection = TempsConnection/11500;
    TauxConnection = TauxConnection/(7015-1001);


end
    function [Utilisateurs, ThroughputSlot] = SimulationTransmission(Utilisateurs,Slot,PhyParam,MACParam)

        IdxUtilisateursEnTransmission = find((Utilisateurs(:,1)-Slot) == 0);
        NbRequeteTransmisesDurantSlot = length(IdxUtilisateursEnTransmission);
        PLRSlot = 1 - exp(-NbRequeteTransmisesDurantSlot/PhyParam.Ncodes);

        ThroughputSlot = 0;

        for k = 1:length(IdxUtilisateursEnTransmission)
            % ---- A remplir ----
            idxU = IdxUtilisateursEnTransmission(k);
            ProbaSucces = rand();
            if ProbaSucces > PLRSlot
                ThroughputSlot = ThroughputSlot + 1;
                Utilisateurs(idxU, 4) = Utilisateurs(idxU, 1);
                Utilisateurs(idxU, 5) = Utilisateurs(idxU, 5) + 1;
                Utilisateurs(idxU, 6) = 1;
            else
                %ProbaImpatience = 0.07;
                if Utilisateurs(idxU, 5) < MACParam.NMaxTransmission && Slot <= NbSlots-7
                    DecalageRand = randi(MACParam.Rand);
                    Utilisateurs(idxU, 1) = Utilisateurs(idxU, 1) + MACParam.Transmission+MACParam.Traitement+DecalageRand;
                    Utilisateurs(idxU, 5) = Utilisateurs(idxU, 5) + 1;
                end
            end
        end
    end

    function Utilisateurs = ApplicationControleDeCharge(Utilisateurs,Slot,CCParam)
        
        IdxUtilisateursEnTransmission = find((Utilisateurs(:,1)-Slot) == 0);
        for k = 1:length(IdxUtilisateursEnTransmission)
            idxU = IdxUtilisateursEnTransmission(k);
            if rand() > CCParam.paccess
            Decalage = randi([1, CCParam.NslotBarringMax]);
            Utilisateurs(idxU, 1) = Slot + Decalage;
            end
        end
    end
end
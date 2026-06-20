function ThroughputSlots = F_SimulateurSansCC(ProfilTrafic,PhyParam,MACParam)

% ------- Param?tres -----------
% ProfilTrafic : Le profil de trafic, ProfilTrafic(k) est le nombre d'utilisateurs qui transmettent pour la premiere fois au slot k.
% PhyParam : Les parametres couche physique.
% MACParam : Parametres couche MAC. 



NbSlots = length(ProfilTrafic); % Nombre de slots simules.
MatriceUtilisateur = zeros(MACParam.NMaxTransmission,NbSlots); % Matrice permettant de stocker les utilisateurs. 
ThroughputSlots = zeros(1,NbSlots); % Debit par time slot. 

for Slot = 1:NbSlots-8
    
    % Arrivee des nouveaux utilisateurs
    %------- A Remplir ------%
    MatriceUtilisateur(1,Slot) = ProfilTrafic(Slot);
    %------------------------%
    % Simulation des transmissions
    [MatriceUtilisateur, ThroughputSlots(Slot)] = SimulationTransmission(MatriceUtilisateur,Slot,NbSlots,PhyParam,MACParam);
    
end


end

function [MatriceUtilisateur, ThroughputSlot] = SimulationTransmission(MatriceUtilisateur,Slot,NbSlots,PhyParam,MACParam)

NbRequeteTransmisesDurantSlot = sum(MatriceUtilisateur(:,Slot)); 
PLRSlot = 1 - exp(-NbRequeteTransmisesDurantSlot/PhyParam.Ncodes); % PLR du slot

ThroughputSlot = 0;
for k = 1:MACParam.NMaxTransmission
    
    if(MatriceUtilisateur(k,Slot) > 0)
        for l = 1:MatriceUtilisateur(k,Slot) % Boucle sur tous les utilisateurs qui vont transmettre
            
            %--------- A Remplir -------%    
            Proba = rand();
            if Proba > PLRSlot
                NbRequeteTransmisesDurantSlot = NbRequeteTransmisesDurantSlot + 1;
                if 23 - NbRequeteTransmisesDurantSlot <= MACParam.NMaxTransmission
                MatriceUtilisateur(k, MACParam.Transmission+MACParam.Traitement+randi(1,MACParam.Rand)+Slot) = MatriceUtilisateur(k, MACParam.Transmission+MACParam.Traitement+randi(1,MACParam.Rand)+Slot) - 1 ;
                ThroughputSlot = ThroughputSlot + 1;
                end
            end
           
            %----------------------------%
        end    
    end    
end

end
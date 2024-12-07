% Fonction matrice_inertie (exercice_2.m)

function [M_inertie,C] = matrice_inertie(E,G_norme_E) 
    
    PIi=G_norme_E;
    gpi=sum(PIi);
    xi=E(:,1);
    yi=E(:,2);
    x_barre=(1/gpi)*sum(PIi.*xi);
    y_barre=(1/gpi)*sum(PIi.*yi);
    M_inertie=zeros(2);
    M_inertie(1,1)= sum(PIi.*((xi-x_barre).*(xi-x_barre)));
    M_inertie(1,2)= sum(PIi.*((xi-x_barre).*(yi-y_barre)));
    M_inertie(2,1)= sum(PIi.*((xi-x_barre).*(yi-y_barre)));
    M_inertie(2,2)= sum(PIi.*((yi-y_barre).*(yi-y_barre)));
    C=sum(E.*G_norme_E)/sum(G_norme_E);
    M_inertie=M_inertie/gpi;



end
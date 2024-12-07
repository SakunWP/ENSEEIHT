% Fonction calcul_proba (exercice_2.m)

function [x_min,x_max,probabilite] = calcul_proba(E_nouveau_repere,p)
    
    s=0;
    for k=0:(length(E_nouveau_repere)-1)
        c=nchoosek(length(E_nouveau_repere),k);
        s=s+c*(p^k)*(1-p)^(length(E_nouveau_repere)-k);
    end
    
    x_min=min(E_nouveau_repere(:,1));
    x_max=max(E_nouveau_repere(:,1));
    probabilite=1-s;


    
end
% fonction calcul_bon_partitionnement (pour l'exercice 1)

function meilleur_pourcentage_partitionnement = calcul_bon_partitionnement(Y_pred,Y)

    permutation=perms([1 2 3]);
    pr=0;
    for j=1:permutation
        for i=1:length(Y)
            if Y_pred(i)==Y(i)
                pr=pr+1;
            end
        end
    end
    meilleur_pourcentage_partitionnement=pr;

end
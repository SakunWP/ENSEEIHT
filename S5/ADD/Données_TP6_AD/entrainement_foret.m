% fonction entrainement_foret (pour l'exercice 2)

function foret = entrainement_foret(X,Y,nb_arbres,proportion_individus)

       nb_individus=rand(proportion_individus*length(Y));
       nb_variables_split=round(sqrt(size(X,2)));
       foret=cell(1,nb_arbres);
       for i=1:nb_arbres
           indices_aleatoires= randperm(length(Y));
           X_a=X(indices_aleatoires);
           Y_a=Y(indices_aleatoires);
       end
        
end

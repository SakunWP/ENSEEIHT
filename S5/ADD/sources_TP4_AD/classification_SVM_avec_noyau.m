% fonction classification_SVM_avec_noyau (pour l'exercice 2)

function Y_pred = classification_SVM_avec_noyau(X,sigma,X_VS,Y_VS,Alpha_VS,c)
    
    c1=0;
    emplacements= find(emplacement_X_VS==1);
    for j=1:length(Y)
        c1=c1+Alpha_VS*Y_VS(j)*K(j,emplacements(1));
    end
    Y_pred=sign(c1-c);

end
% fonction qualite_classification (pour l'exercice 2)

function [pourcentage_bonnes_classifications_total,pourcentage_bonnes_classifications_fibrome, ...
          pourcentage_bonnes_classifications_melanome] = qualite_classification(Y_pred,Y)

    v_class=zeros(size(Y,1),1);
    v_class(Y_pred==Y)=1;
    %v_class(Y_pred2 ~=Y)=0;
    v_class_fibrome=v_class(1:size(Y,1)/2);
    s_f=sum(v_class_fibrome);
    v_class_m=v_class(size(Y,1)/2:end);
    s_m=sum(v_class_m);
    s=sum(v_class);
    pourcentage_bonnes_classifications_total=s/size(Y,1);
    pourcentage_bonnes_classifications_fibrome=100*s_f/size(v_class_fibrome,1);
    pourcentage_bonnes_classifications_melanome=100*s_m/size(v_class_m,1);


end
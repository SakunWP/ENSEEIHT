% fonction estim_param_SVM_noyau (pour l'exercice 2)

function [X_VS,Y_VS,Alpha_VS,c,code_retour] = estim_param_SVM_noyau(X,Y,sigma)

    K=zeros(size(Y));
    for i=1:length(Y)
        for j=1:length(Y)
            K(i,j)=exp(-(X(i,1)-X(j,1)^2+X(i,2)-X(j,2)^2)/(2*sigma*sigma));
        end
    end
    H=diag(Y)*K*diag(Y);
    f=-ones(size(Y)); 
    Aeq= Y';
    beq= 0; 
    lb= zeros(size(Y)); 
    [alpha,~,code_retour]= quadprog(H,f,[],[],Aeq,beq,lb,[]);
    emplacement_X_VS= (alpha>1e-6);
    X_VS=X(emplacement_X_VS,:);
    Y_VS=Y(emplacement_X_VS);
    Alpha_VS=alpha(emplacement_X_VS);
    
    X_VS_plus_1=X_VS(Y_VS==1,:);
    Y_VS_plus_1= Y_VS(Y_VS==1);
    c=-Y_VS_plus_1(1);
    emplacements= find(emplacement_X_VS==1);
    for j=1:length(Y)
        c=c+Alpha_VS*Y_VS(j)*K(j,emplacements(1));
    end

end

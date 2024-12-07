% fonction estim_param_SVM_dual (pour l'exercice 1)

function [X_VS,w,c,code_retour] = estim_param_SVM_dual(X,Y)

    H=diag(Y)*(X*X')*diag(Y);
    f=-ones(size(Y)); %+sum(alph_i1)
    Aeq= Y'; %sum(alph_i*y_i)=0 y_i
    beq= 0; % sum(alph_i*y_i)=0
    lb= zeros(size(Y)); %alpha_i>=0 forall_i [1,n]
    [alpha,~,code_retour]= quadprog(H,f,[],[],Aeq,beq,lb,[]);
    emplacement_X_VS= (alpha>1e-6);
    X_VS=X(emplacement_X_VS,:);
    Y_VS=Y(emplacement_X_VS);
    Alpha_VS=alpha(emplacement_X_VS);
    w=X_VS'*diag(Y_VS)*Alpha_VS;
    X_VS_plus_1=X_VS(Y_VS==1,:);
    Y_VS_plus_1= Y_VS(Y_VS==1);
    c=X_VS_plus_1(1,:)*w-Y_VS_plus_1(1);

end

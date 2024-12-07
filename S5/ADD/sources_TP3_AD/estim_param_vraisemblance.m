% fonction estim_param_vraisemblance (pour l'exercice 1)

function [mu,Sigma] = estim_param_vraisemblance(X)
    mu=[mean(X(:,1)) mean(X(:,2))];
    n=length(X);
    Xc=[X(:,1)-mean(X(:,1)) X(:,2)-mean(X(:,2))];
    Sigma=(1/n)*(Xc'*Xc);


end
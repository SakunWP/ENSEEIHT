% fonction modelisation_vraisemblance (pour l'exercice 1)

function modele_V = modelisation_vraisemblance(X,mu,Sigma)
    modele_V=zeros(length(X),1);
    for i=1:length(X)
        x=X(i,:)-mu;
        modele_V(i)=1/(2*pi*sqrt(det(Sigma)))*exp((-1/2)*x*inv(Sigma)*x');
    end

end
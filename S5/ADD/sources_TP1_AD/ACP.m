% function ACP (pour exercice_2.m)

function [C,bornes_C,coefficients_RVG2gris] = ACP(X)

    X_centre=X-mean(X);
    sigma=(X_centre'*X_centre)/length(X);
    [W,D]=eig(sigma);
    [vp,perm]=sort(diag(D), 'descend');
    W=W(:,perm);
    C=X*W;
    min_c=min(C(:));
    max_c=max(C(:));
    bornes_C=[min_c,max_c]
    coefficients_RVG2gris=W(:,1)./sum(W(:,1))
end

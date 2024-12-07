% function correlation_contraste (pour exercice_1.m)

function [correlation,contraste] = correlation_contraste(X)

    X_centre=X-mean(X);
    sigma=(X_centre'*X_centre)/length(X);
    correlation=[sigma(2,1)/sqrt(sigma(1,1)*sigma(2,2)), sigma(1,3)/sqrt(sigma(1,1)*sigma(3,3)),sigma(3,2)/sqrt(sigma(2,2)*sigma(3,3))]
    contraste=[sigma(1,1)/(sigma(1,1)+sigma(2,2)+sigma(3,3)),sigma(2,2)/(sigma(1,1)+sigma(2,2)+sigma(3,3)),sigma(3,3)/(sigma(1,1)+sigma(2,2)+sigma(3,3))]

    
end

function bits = octetsToBits(octets)
    % Vérifier que les octets sont des entiers entre 0 et 255
    if any(octets < 0) || any(octets > 255)
        error('Les octets doivent être des entiers compris entre 0 et 255.');
    end
    
    % Conversion des octets en bits
    % Utiliser la fonction de2bi pour convertir chaque entier en vecteur binaire
    bitsMatrix = de2bi(octets, 8, 'left-msb');
    
    % Convertir la matrice en un vecteur ligne
    bits = bitsMatrix';
    bits = bits(:)';
end

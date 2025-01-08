function octets = bitsToOctets(bits)
    % Vérifier que le nombre de bits est un multiple de 8
    if mod(length(bits), 8) ~= 0
        error('Le nombre de bits doit être un multiple de 8.');
    end
    
    % Reshape des bits en matrice de 8 colonnes
    bitsReshape = reshape(bits, 8, []).';
    
    % Conversion des bits en octets
    % Utiliser la fonction bi2de pour convertir chaque ligne en un entier
    octets = bi2de(bitsReshape, 'left-msb');
end

function out = UserDefined_convintrlv(x, nRows, slope)
    % Ajout des zéros nécessaires pour gérer le retard total de l'entrelaceur
    zeros_to_be_padded = zeros(1, nRows * (nRows - 1) * slope); % Zéros à ajouter
    if iscolumn(x)
        % Si x est un vecteur colonne, convertissez zeros_to_be_padded en colonne
        zeros_to_be_padded = zeros_to_be_padded.';
    end
    x = [x; zeros_to_be_padded]; % Concaténation
    out = convintrlv(x, nRows, slope); % Entrelacement standard
end
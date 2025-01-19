function out = UserDefined_convdeintrlv(x, nRows, slope)
    % Retirer les zéros introduits par l'entrelaceur
    zeros_to_be_removed = nRows * (nRows - 1) * slope;
    temp_out = convdeintrlv(x, nRows, slope); % Désentrelacement standard
    if iscolumn(temp_out)
        % Si temp_out est un vecteur colonne, ajustez la suppression des zéros
        out = temp_out(zeros_to_be_removed + 1:end);
    else
        % Si temp_out est un vecteur ligne
        out = temp_out(zeros_to_be_removed + 1:end);
    end
end
function reponse = isEulerien(Graphe)
   
    deg = sum(Graphe, 2); % Somme des lignes pour obtenir les degrés

    if isConnexe(Graphe)
        % Compter les sommets de degré impair
        deg_impaire = sum(mod(deg, 2) == 1);

        % Un graphe est eulérien si tous les degrés sont pairs
        if deg_impaire == 0 || deg_impaire ==2
            reponse = true; % Graphe eulérien
        else
            reponse = false; % Pas eulérien
        end
    else
        % Si le graphe n'est pas connexe, il n'est pas eulérien
        reponse = false;
    end
end
function is_connected = isConnexe(A)
    % checkConnectivity Vérifie si un graphe est connexe
    % Entrée:
    %   - A : Matrice d'adjacence (carrée et symétrique pour les graphes non orientés)
    % Sortie:
    %   - is_connected : Booléen, true si le graphe est connexe, false sinon

    % Nombre de sommets
    n = size(A, 1);
    
    % Initialiser un tableau pour suivre les sommets visités
    visited = false(1, n);

    % Commencer une exploration (DFS ou BFS) à partir du premier sommet
    visited = exploreGraph(1, A, visited);
    
    % Si tous les sommets ont été visités, le graphe est connexe
    is_connected = all(visited);
end

function visited = exploreGraph(node, A, visited)
    % exploreGraph Explore récursivement le graphe à partir d'un nœud donné
    % Entrée:
    %   - node : Nœud actuel
    %   - A : Matrice d'adjacence
    %   - visited : Tableau des sommets visités
    % Sortie:
    %   - visited : Tableau mis à jour des sommets visités
    
    % Marquer le nœud actuel comme visité
    visited(node) = true;

    % Parcourir les voisins du nœud actuel
    neighbors = find(A(node, :) > 0); % Indices des voisins

    for neighbor = neighbors
        if ~visited(neighbor)
            visited = exploreGraph(neighbor, A, visited);
        end
    end
end

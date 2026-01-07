import networkx as nx
import matplotlib.pyplot as plt

# 1. Créer un graphe en ligne (Path Graph) avec 10 nœuds
N = 10
G = nx.path_graph(N) 

# 2. Attribuer les valeurs fixes (Pire cas : information à une extrémité)
values = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100] 
for i, value in enumerate(values):
    G.nodes[i]['val'] = float(value)
    G.nodes[i]['mailbox'] = [] # Pour stocker les messages reçus sans les écraser

# Séquence d'ordre pour les nœuds
seq = [2, 5, 3, 9, 0, 8, 1, 4, 7, 6]

# Paramètres de l'algorithme
T = 5   
R = 2   
total_steps = 1000 

# Historique pour l'analyse
history = {i: [] for i in range(N)}

# 3. Boucle principale
for t in range(1, total_steps + 1):
    
    # Étape A : Diffusion (Broadcast)
    if t % T == 0:
        for i in seq:  # Utiliser la séquence pour l'ordre
            current_val = G.nodes[i]['val']
            # Dans une ligne, neighbors(i) renvoie 1 ou 2 voisins max
            for neighbor in G.neighbors(i):
                G.nodes[neighbor]['mailbox'].append(current_val)
        print(f"Pas {t}: Diffusion générale sur la ligne.")

    # Étape B : Réception et Mise à jour (else if)
    else:
        for i in seq:  # Utiliser la séquence pour l'ordre
            if G.nodes[i]['mailbox']:
                # On récupère la valeur reçue (R_VAL)
                r_val = G.nodes[i]['mailbox'].pop(0)
                
                # Mise à jour selon l'algorithme de la photo : (val + R_VAL) / R
                G.nodes[i]['val'] = (G.nodes[i]['val'] + r_val) / R

    # Enregistrement des valeurs pour le graphique
    for i in range(N):
        history[i].append(G.nodes[i]['val'])

# --- Résultats et Visualisation ---

print("\nValeurs finales après simulation :")
for node in G.nodes():
    print(f"Nœud {node}: {G.nodes[node]['val']:.4f}")

# Affichage de la convergence
plt.figure(figsize=(10, 5))
for node in range(N):
    plt.plot(history[node], label=f"Nœud {node}")

plt.title("Convergence de l'algorithme sur une topologie en ligne")
plt.xlabel("Temps (itérations)")
plt.ylabel("Valeur (val)")
plt.legend(loc='upper right', fontsize='small')
plt.grid(True)
plt.show()
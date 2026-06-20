import networkx as nx
import matplotlib.pyplot as plt
import numpy as np

# 1. Créer un graphe en ligne (Path Graph) avec 10 nœuds
N = 10
G = nx.path_graph(N) 

# 2. Attribuer les valeurs fixes
values = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100] 
target_val = sum(values) / N  # La moyenne (55.0)
for i, value in enumerate(values):
    G.nodes[i]['val'] = float(value)
    G.nodes[i]['mailbox'] = []

# Séquence d'ordre pour les nœuds
seq = [2, 5, 3, 9, 0, 8, 1, 4, 7, 6]

# Paramètres de l'algorithme
T = 5   
seuil = 0.1
total_steps = 3000 # Augmenté pour être sûr d'atteindre le seuil
convergence_time = None

# Historique pour l'analyse
history = {i: [] for i in range(N)}

# 3. Boucle principale
for t in range(1, total_steps + 1):
    
    # Étape A : Diffusion (Broadcast)
    if t % T == 0:
        for i in seq:
            current_val = G.nodes[i]['val']
            for neighbor in G.neighbors(i):
                G.nodes[neighbor]['mailbox'].append(current_val)

    # Étape B : Réception et Mise à jour
    else:
        for i in seq:
            if G.nodes[i]['mailbox']:
                r_val = G.nodes[i]['mailbox'].pop(0)
                G.nodes[i]['val'] = (G.nodes[i]['val'] + r_val) / 2

    # Enregistrement des valeurs
    current_vals = []
    for i in range(N):
        val = G.nodes[i]['val']
        history[i].append(val)
        current_vals.append(val)

    # --- VERIFICATION DE LA CONVERGENCE ---
    # On calcule l'écart max par rapport à la moyenne
    diff_max = max([abs(v - target_val) for v in current_vals])
    
    if diff_max <= seuil and convergence_time is None:
        convergence_time = t
        # On peut choisir de s'arrêter ici avec 'break' ou continuer pour le graph

# --- Résultats et Visualisation ---

if convergence_time:
    print(f"Temps de convergence atteint à t = {convergence_time}")
    print(f"Soit {convergence_time // T} cycles complets.")
else:
    print(" Le seuil n'a pas été atteint dans le temps imparti.")

# Affichage de la convergence
plt.figure(figsize=(10, 6))
for node in range(N):
    plt.plot(history[node], label=f"Nœud {node}")

# Ligne horizontale pour la moyenne et le seuil
plt.axhline(y=target_val, color='black', linestyle='--', alpha=0.5, label='Moyenne (55)')
if convergence_time:
    plt.axvline(x=convergence_time, color='red', linestyle=':', label=f'Convergence (t={convergence_time})')

plt.title(f"Convergence (Seuil={seuil}) - Topologie en ligne")
plt.xlabel("Temps (itérations)")
plt.ylabel("Valeur (val)")
plt.legend(loc='upper right', fontsize='x-small')
plt.grid(True)
plt.show()
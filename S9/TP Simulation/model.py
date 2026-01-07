import numpy as np
import itertools
import random

def get_lambda_2_for_seq(sequence, N):
    P = np.eye(N)
    for i in sequence:
        Ei = np.eye(N)
        neighbors = [j for j in [i-1, i+1] if 0 <= j < N]
        for j in neighbors:
            Ei[j, j] = 0.5
            Ei[j, i] = 0.5
        P = Ei @ P
    
    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))
    return eigenvalues[-2]

N = 10
nb_tests = 1000000 # On teste 10 000 séquences aléatoires
best_l2 = -1
worst_l2 = 2
best_seq = []
worst_seq = []

print(f"Recherche du pire cas sur {nb_tests} séquences...")

for _ in range(nb_tests):
    seq = list(range(N))
    random.shuffle(seq)
    l2 = get_lambda_2_for_seq(seq, N)
    
    if l2 > best_l2: # Le plus lent (Pire cas)
        best_l2 = l2
        worst_seq = seq
    if l2 < worst_l2: # Le plus rapide (Meilleur cas)
        worst_l2 = l2
        best_seq = seq

print(f"\n--- RÉSULTATS ---")
print(f"Pire séquence (lambda_2 max = {best_l2:.4f}) : {worst_seq}")
print(f"Meilleure séquence (lambda_2 min = {worst_l2:.4f}) : {best_seq}")
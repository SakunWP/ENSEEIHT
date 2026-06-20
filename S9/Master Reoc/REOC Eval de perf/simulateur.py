import random
import math


def _sample_dt_and_event(rates):
    Delta_X = sum(rates.values())
    if Delta_X == 0:
        return None, None
    dt = random.expovariate(Delta_X)
    u = random.uniform(0, Delta_X)
    cumulative = 0.0
    for e, r in rates.items():
        cumulative += r
        if u < cumulative:
            return dt, e
    return dt, None


def simulate_closed_network(lambda_H, mu_H, mu_R, mu_D, C, N, p, max_time=50000):
    X = {'T': N, 'H': 0, 'R': 0, 'D': 0}
    time = 0.0
    A = {'T': 0.0, 'H': 0.0, 'R': 0.0, 'D': 0.0}
    time_T_empty = 0.0
    completions = {'R': 0}

    while time < max_time:
        rates = {
            'T_to_H': lambda_H if X['T'] > 0 else 0.0,
            'H_to_R': mu_H if X['H'] > 0 else 0.0,
            'R_to_T': p * mu_R * min(X['R'], C),
            'R_to_D': (1 - p) * mu_R * min(X['R'], C),
            'D_to_R': mu_D if X['D'] > 0 else 0.0
        }

        dt, event = _sample_dt_and_event(rates)
        if dt is None:
            break

        # Accumulateurs temporels (avant transition)
        for node in X:
            A[node] += X[node] * dt
        if X['T'] == 0:
            time_T_empty += dt
        time += dt

        # Transitions d'état
        if event == 'T_to_H':
            X['T'] -= 1
            X['H'] += 1
        elif event == 'H_to_R':
            X['H'] -= 1
            X['R'] += 1
        elif event == 'R_to_T':
            X['R'] -= 1
            X['T'] += 1
            completions['R'] += 1
        elif event == 'R_to_D':
            X['R'] -= 1
            X['D'] += 1
        elif event == 'D_to_R':
            X['D'] -= 1
            X['R'] += 1

    mean_X = {node: A[node] / time for node in A}
    p_reject = time_T_empty / time
    throughput = completions['R'] / time
    mean_system_population = mean_X['H'] + mean_X['R'] + mean_X['D']
    mean_sojourn_time = mean_system_population / throughput if throughput > 0 else 0

    return {
        'mean_number_H': mean_X['H'],
        'mean_number_R': mean_X['R'],
        'mean_number_D': mean_X['D'],
        'p_reject': p_reject,
        'throughput': throughput,
        'mean_sojourn_time': mean_sojourn_time
    }


def simulate_open_network(lambda_H, mu_H, mu_R, mu_D, C, p, max_time=100000):
    X = {'H': 0, 'R': 0, 'D': 0}
    time = 0.0
    A = {'H': 0.0, 'R': 0.0, 'D': 0.0}
    completions = 0

    while time < max_time:
        rates = {
            'External_to_H': lambda_H,
            'H_to_R': mu_H if X['H'] > 0 else 0.0,
            'R_to_Out': p * mu_R * min(X['R'], C),
            'R_to_D': (1 - p) * mu_R * min(X['R'], C),
            'D_to_R': mu_D if X['D'] > 0 else 0.0
        }

        dt, event = _sample_dt_and_event(rates)
        if dt is None:
            break

        for node in X:
            A[node] += X[node] * dt
        time += dt

        # Transitions (logique inchangée)
        if event == 'External_to_H':
            X['H'] += 1
        elif event == 'H_to_R':
            X['H'] -= 1
            X['R'] += 1
        elif event == 'R_to_Out':
            X['R'] -= 1
            completions += 1
        elif event == 'R_to_D':
            X['R'] -= 1
            X['D'] += 1
        elif event == 'D_to_R':
            X['D'] -= 1
            X['R'] += 1

    mean_X = {node: A[node] / time for node in A}
    throughput = completions / time
    mean_sojourn_time = sum(mean_X.values()) / throughput if throughput > 0 else 0

    return mean_sojourn_time, mean_X['H'], mean_X['R'], mean_X['D']


def get_analytical_approximations(lambda_H, mu_H, mu_R, mu_D, C, p):
    """Calcule trois approximations analytiques pour le système ouvert.

    - Approx 1 : modèle M/M/C pour la station R (threads infinis)
    - Approx 2 : ressource unique équivalente (capacité fusionnée)
    - Approx 3 : modèle M/M/inf (ressources infinies)
    """
    # Taux effectifs entrant dans chaque station
    gamma_H = lambda_H
    gamma_R = lambda_H / p
    gamma_D = lambda_H * (1 - p) / p

    # Stations H et D -> M/M/1
    rho_H = gamma_H / mu_H
    rho_D = gamma_D / mu_D
    if rho_H >= 1 or rho_D >= 1:
        return None, None, None

    N_H = rho_H / (1 - rho_H)
    N_D = rho_D / (1 - rho_D)

    # Approximation 1 : Erlang-C pour R (M/M/C)
    rho_R_1 = gamma_R / (C * mu_R)
    if rho_R_1 < 1:
        num = ((C * rho_R_1) ** C / math.factorial(C)) * (1 / (1 - rho_R_1))
        den = sum(((C * rho_R_1) ** k / math.factorial(k)) for k in range(C)) + num
        P_queue = num / den
        N_R_1 = C * rho_R_1 + (P_queue * rho_R_1 / (1 - rho_R_1))
        T_1 = (N_H + N_R_1 + N_D) / lambda_H
        approx1 = (T_1, N_H, N_R_1, N_D)
    else:
        approx1 = (float('inf'),) * 4

    # Approximation 2 : ressource unique (capacité totale = C * mu_R)
    rho_R_2 = gamma_R / (C * mu_R)
    if rho_R_2 < 1:
        N_R_2 = rho_R_2 / (1 - rho_R_2)
        T_2 = (N_H + N_R_2 + N_D) / lambda_H
        approx2 = (T_2, N_H, N_R_2, N_D)
    else:
        approx2 = (float('inf'),) * 4

    # Approximation 3 : ressources infinies (M/M/inf)
    N_R_3 = gamma_R / mu_R
    T_3 = (N_H + N_R_3 + N_D) / lambda_H
    approx3 = (T_3, N_H, N_R_3, N_D)

    return approx1, approx2, approx3


# BLOC D'EXÉCUTION PRINCIPAL
if __name__ == "__main__":
    print("=== EXÉCUTION DE LA QUESTION 1(a) ===")
    result_q1 = simulate_closed_network(
        lambda_H=2, mu_H=1, mu_R=1, mu_D=1, C=1, N=1, p=1.0, max_time=100000
    )
    print(f"Probabilité de rejet : {result_q1['p_reject']:.4f} (Théorique: 2/3)")
    print(f"Temps de séjour moyen : {result_q1['mean_sojourn_time']:.4f} sec (Théorique: 2.0 sec)\n")

    print("=== EXÉCUTION DE LA QUESTION 2 (Génération du tableau...) ===")
    params = {'lambda_H': 1, 'mu_H': 10, 'mu_R': 1, 'mu_D': 10, 'C': 5}
    scenarios = [
        {'id': 'a', 'N': 15, 'p': 0.5}, {'id': 'b', 'N': 15, 'p': 0.22},
        {'id': 'c', 'N': 30, 'p': 0.5}, {'id': 'd', 'N': 30, 'p': 0.22}
    ]

    results = {}
    for s in scenarios:
        res_closed = simulate_closed_network(**params, N=s['N'], p=s['p'], max_time=100000)
        res_open = simulate_open_network(**params, p=s['p'], max_time=100000)
        app1, app2, app3 = get_analytical_approximations(**params, p=s['p'])

        results[s['id']] = {
            'closed_B': res_closed['mean_sojourn_time'],
            'closed_P_rej': res_closed['p_reject'] * 100,
            'open_B': res_open[0],
            'app1_B': app1[0] if app1 else float('inf'),
            'app2_B': app2[0] if app2 else float('inf'),
            'app3_B': app3[0] if app3 else float('inf')
        }

    def fmt(val):
        return "$\\infty$" if val == float('inf') else f"{val:.3f}"

    latex_table = f"""
\\begin{{center}}
\\renewcommand{{\\arraystretch}}{{1.3}}
\\begin{{tabular}}{{|l|c|c|c|c|}}
\\hline
\\textbf{{Mean Sojourn Time ($\\bar{{B}}$)}} & \\textbf{{(a) $N=15, p=0.5$}} & \\textbf{{(b) $N=15, p=0.22$}} & \\textbf{{(c) $N=30, p=0.5$}} & \\textbf{{(d) $N=30, p=0.22$}} \\\
\\hline
Closed Network  & {fmt(results['a']['closed_B'])} s & {fmt(results['b']['closed_B'])} s & {fmt(results['c']['closed_B'])} s & {fmt(results['d']['closed_B'])} s \\\
Open Network  & {fmt(results['a']['open_B'])} s & {fmt(results['b']['open_B'])} s & {fmt(results['c']['open_B'])} s & {fmt(results['d']['open_B'])} s \\\
Approx 1 (Inf. threads) & {fmt(results['a']['app1_B'])} s & {fmt(results['b']['app1_B'])} s & {fmt(results['c']['app1_B'])} s & {fmt(results['d']['app1_B'])} s \\\
Approx 2 (Single res.) & {fmt(results['a']['app2_B'])} s & {fmt(results['b']['app2_B'])} s & {fmt(results['c']['app2_B'])} s & {fmt(results['d']['app2_B'])} s \\\
Approx 3 (Inf. res.) & {fmt(results['a']['app3_B'])} s & {fmt(results['b']['app3_B'])} s & {fmt(results['c']['app3_B'])} s & {fmt(results['d']['app3_B'])} s \\\
\\hline
\\textbf{{Reject. Prob. (Closed)}} & {fmt(results['a']['closed_P_rej'])} \\% & {fmt(results['b']['closed_P_rej'])} \\% & {fmt(results['c']['closed_P_rej'])} \\% & {fmt(results['d']['closed_P_rej'])} \\% \\\
\\hline
\\end{{tabular}}
\\end{{center}}
"""
    print(latex_table)
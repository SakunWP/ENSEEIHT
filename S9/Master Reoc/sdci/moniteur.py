import requests
import time
import json



GI_IP = "172.17.0.3"
GI_PORT = "8181"
HEALTH_URL = f"http://{GI_IP}:{GI_PORT}/health"

SEUIL_DECLENCHEMENT = 20.0 # Seuil pour mettre en place une option d'adaptation
INTERVALLE_SURVEILLANCE = 3# Temps entre chaque check


def action():
    api_url = "http://127.0.0.1:5001/restapi/compute/dc1/gi_secours"
    payload = {
        "image": "gi_vnf",
        "network": "(id=vnf-eth0)"
    }
    headers = {"Content-Type": "application/json"}
    requests.put(api_url, data=json.dumps(payload), headers=headers)


def start_monitoring():
    print(f"INFO: [MONITOR] Démarrage de la surveillance sur {HEALTH_URL}...")
    print(f"INFO: [MONITOR] Seuil d'alerte configuré à {SEUIL_DECLENCHEMENT}% de charge CPU.\n")
    
    while True:
        try:
            response = requests.get(HEALTH_URL, timeout=2)
            
            if response.status_code == 200:
                data = response.json()
                
                charge_actuelle = data.get("currentLoad", 0) 
                
                print(f"DEBUG:[MONITOR] Charge CPU de la GI principale : {charge_actuelle:.2f}%")

                if float(charge_actuelle) >= SEUIL_DECLENCHEMENT:
                    print("INFO: [ANALYZE]  ALERTE : Surcharge CPU détectée ! La GI sature.")
                    
                    print("INFO: [PLAN] Décision prise : Déploiement d'une VNF de secours (Scale-out).")
                    
                    # On effectue l'action d'adaptation
                    action()

                    print("INFO: [EXECUTE] Action Mise en place. FIN")
                    break  
                    
            else:
                print(f"ERROR: [MONITOR] ⚠️ La GI a répondu avec une erreur {response.status_code}")

        except requests.exceptions.RequestException:
            print("EROOR: [MONITOR] Impossible de joindre la GI (Réseau coupé ou GI crashée).")

        # On attend avant la prochaine vérification pour ne pas spammer la Gateway
        time.sleep(INTERVALLE_SURVEILLANCE)

if __name__ == "__main__":
    start_monitoring()
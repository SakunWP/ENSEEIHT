#!/bin/bash
cd /serveur
echo "[ENTRYPOINT] Lancement du serveur Node.js"

node server.js \
  --local_ip "0.0.0.0" \
  --local_port "8080" \
  --local_name "srv" &

echo "[ENTRYPOINT] Serveur démarré (PID: $!)" 
cd /app

node application.js \
    --remote_ip "127.0.0.1" \
    --remote_port 8080 \
    --device_name "dev1" \
    --send_period 5000 &
echo "[ENTRYPOINT] app démarrée (PID: $!)" 
echo "[ENTRYPOINT] Ouverture d'un shell interactif." 

/bin/bash

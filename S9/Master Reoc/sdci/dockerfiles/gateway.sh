#!/bin/bash
cd /gateway
echo "[ENTRYPOINT] Lancement de la gateway"

node gateway.js \
    --local_ip "0.0.0.0" \
    --local_port 8181 \
    --local_name $local_name \
    --remote_ip "10.0.0.5" \
    --remote_port 8080 \
    --remote_name "srv" \
    --drop_rate "${DROP_RATE:-0.1}" &

echo "[ENTRYPOINT] gateway démarée (PID: $!)"

/bin/bash
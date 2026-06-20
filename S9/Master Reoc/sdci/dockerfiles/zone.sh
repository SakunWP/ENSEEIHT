#!/bin/bash
cd /gateway
echo "[ENTRYPOINT] Lancement de la gateway"

cd /gateway
echo "[ENTRYPOINT] Lancement de la gateway"

node gateway.js \
    --local_ip "0.0.0.0" \
    --local_port 8282 \
    --local_name $local_name \
    --remote_ip $remote_ip \
    --remote_port 8181 \
    --remote_name $remote_name \
    --drop_rate "${DROP_RATE:-0.1}" &


echo "[ENTRYPOINT] gateway démarée (PID: $!)"


cd /device
echo "[ENTRYPOINT] Lancement du device"


node device.js \
    --local_ip "127.0.0.1" \
    --local_port 9001 \
    --local_name "dev1" \
    --remote_ip "127.0.0.1" \
    --remote_port 8282 \
    --remote_name $local_name \
    --send_period 3000 &


echo "[ENTRYPOINT] device démaré (PID: $!)"

/bin/bash
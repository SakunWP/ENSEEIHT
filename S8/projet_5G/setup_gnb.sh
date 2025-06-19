#!/bin/bash

# Nouvelles valeurs
NEW_INTERFACE="enp1s0f0"
NEW_IP="192.168.20.3/24"
DEV_NAME="enp1s0f0"             # Interface réseau connectée au cœur
IP_GNB="192.168.20.3"         # IP de la gNB
IP_CORE="192.168.20.1"        # IP du cœur
CONF_SOURCE="/home/tls-sec/openairinterface5g/targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf"
CONF_DEST="/home/tls-sec/openairinterface5g/cmake_targets/ran_build/build/gnb.sa.band78.fr1.106PRB.usrpb210.conf"


# Compilation de la gNB
echo "=== Compilation de la gNB ==="
cd /home/tls-sec/openairinterface5g/cmake_targets || exit 1
./build_oai -w USRP --nrUE --gNB -c

# Configuration réseau
echo "=== Configuration réseau ==="
sudo ip link set dev "$DEV_NAME" up
sudo ethtool -p "$DEV_NAME"
sudo ip a add "$IP_GNB/24" dev "$DEV_NAME"
ping -c 3 "$IP_CORE"

# Route vers réseau docker du cœur
sudo ip route add 192.168.70.128/26 via "$IP_CORE"

# Préparation du fichier de configuration
echo "=== Préparation du fichier de configuration ==="
cd /home/tls-sec/openairinterface5g/cmake_targets/ran_build/build || exit 1
cp "$CONF_SOURCE" "$CONF_DEST"

# Remplacer les interfaces
sed -i "s/^ *GNB_INTERFACE_NAME_FOR_NG_AMF *= *\".*\";/GNB_INTERFACE_NAME_FOR_NG_AMF = \"$NEW_INTERFACE\";/" "$CONFIG_FILE"
sed -i "s/^ *GNB_INTERFACE_NAME_FOR_NGU *= *\".*\";/GNB_INTERFACE_NAME_FOR_NGU = \"$NEW_INTERFACE\";/" "$CONFIG_FILE"

# Remplacer les adresses IP
sed -i "s/^ *GNB_IPV4_ADDRESS_FOR_NG_AMF *= *\".*\";/GNB_IPV4_ADDRESS_FOR_NG_AMF = \"$NEW_IP\";/" "$CONFIG_FILE"
sed -i "s/^ *GNB_IPV4_ADDRESS_FOR_NGU *= *\".*\";/GNB_IPV4_ADDRESS_FOR_NGU = \"$NEW_IP\";/" "$CONFIG_FILE"

# Lancement de la gNB
echo "=== Lancement de la gNB ==="
./nr-softmodem -O "$CONF_DEST" --sa -E --continuous-tx


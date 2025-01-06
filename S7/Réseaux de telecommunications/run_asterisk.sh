#!/bin/bash



# Lancer le conteneur
echo "Lancement du conteneur Asterisk..."
docker run -d --name asterisk \
  -p 5060:5060/udp \
  -p 5060:5060/tcp \
  -p 10000-20000:10000-20000/udp \
  andrius/asterisk

echo "Conteneur Asterisk démarré avec succès."


#!/bin/bash
set -e

# Simple attente de 30 secondes pour laisser MySQL démarrer
echo "Attente du démarrage de MySQL (30 secondes)..."
sleep 30

# Exécuter le script d'entrée original de WordPress en arrière-plan
docker-entrypoint.sh "$@" &
WORDPRESS_PID=$!

# Attendre que WordPress soit prêt avant d'initialiser
sleep 20

# Exécuter le script d'initialisation si ce n'est pas déjà fait
if [ ! -f /var/www/html/.initialized ]; then
    echo "Première exécution - lancement de l'initialisation..."
    /usr/local/bin/init-wordpress.sh || true
fi

# Attendre le processus WordPress
wait $WORDPRESS_PID
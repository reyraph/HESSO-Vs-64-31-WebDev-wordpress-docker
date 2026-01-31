#!/bin/bash
set -e

# Fonction pour attendre que la base de données soit prête
wait_for_db() {
    echo "Attente de la disponibilité de la base de données..."
    while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
        sleep 1
    done
    echo "Base de données disponible!"
}

# Attendre que la base de données soit prête
wait_for_db

# Exécuter le script d'entrée original de WordPress
docker-entrypoint.sh "$@" &
WORDPRESS_PID=$!

# Attendre un peu que WordPress démarre
sleep 15

# Exécuter le script d'initialisation si ce n'est pas déjà fait
if [ ! -f /var/www/html/.initialized ]; then
    echo "Première exécution détectée - lancement de l'initialisation..."
    /usr/local/bin/init-wordpress.sh
fi

# Attendre le processus WordPress
wait $WORDPRESS_PID

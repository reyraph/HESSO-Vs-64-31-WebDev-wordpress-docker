#!/bin/bash
# Script d'initialisation WordPress - Installation des plugins et configuration de base

# Attendre que WordPress soit prêt
sleep 10

# Vérifier si WordPress est installé
if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
    echo "WordPress n'est pas encore installé. Attente de l'installation..."
    exit 0
fi

echo "=== Début de l'initialisation WordPress ==="

# Installer les plugins essentiels (modifiez cette liste selon vos besoins)
PLUGINS=(
    "classic-editor"           # Éditeur classique
    "duplicate-post"           # Dupliquer les articles/pages
    "contact-form-7"           # Formulaires de contact
    "all-in-one-wp-migration"  # Migration et sauvegarde
    "wpforms-lite"             # Création de formulaires
	"advanced-custom-fields"   # Advenced Custom Fields
	"wp-graphql"               # API with GraphQL
	"wpgraphql-acf"            # GraphQL for ACF
	"wpgraphql-ide"            # New interface for GraphQL
)

echo "Installation des plugins..."
for plugin in "${PLUGINS[@]}"; do
    if ! wp plugin is-installed "$plugin" --allow-root --path=/var/www/html; then
        echo "Installation de $plugin..."
        wp plugin install "$plugin" --activate --allow-root --path=/var/www/html
    else
        echo "$plugin est déjà installé"
    fi
done

# Activer tous les plugins installés
wp plugin activate --all --allow-root --path=/var/www/html

# Configuration de base WordPress
echo "Configuration de WordPress..."

# Définir les permaliens en mode "nom de l'article"
wp rewrite structure '/%postname%/' --allow-root --path=/var/www/html

# Désactiver les commentaires par défaut pour les nouveaux articles
wp option update default_comment_status 'closed' --allow-root --path=/var/www/html

# Définir le fuseau horaire
wp option update timezone_string 'Europe/Zurich' --allow-root --path=/var/www/html

# Créer un fichier marqueur pour indiquer que l'initialisation est terminée
touch /var/www/html/.initialized

echo "=== Initialisation WordPress terminée ==="

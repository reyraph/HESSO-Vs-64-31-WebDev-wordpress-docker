#!/bin/bash
# Script de sauvegarde de la configuration WordPress

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="wordpress_config_${TIMESTAMP}"

echo "=== Sauvegarde de la configuration WordPress ==="

mkdir -p "$BACKUP_DIR"

# Vérifier que le container WordPress est en cours d'exécution
if ! docker ps | grep -q wordpress_app; then
    echo "❌ Erreur: Le container WordPress n'est pas en cours d'exécution"
    exit 1
fi

echo "📦 Export de la base de données..."
docker exec wordpress_db mysqldump -u wordpress_user -pwordpress_pass_2024 wordpress_db > "$BACKUP_DIR/${BACKUP_FILE}.sql"

echo "📦 Compression de la base de données..."
gzip "$BACKUP_DIR/${BACKUP_FILE}.sql"

echo "📦 Export de la liste des plugins installés..."
docker exec wordpress_app wp plugin list --allow-root --path=/var/www/html --format=json > "$BACKUP_DIR/plugins_list.json" 2>/dev/null || echo "[]" > "$BACKUP_DIR/plugins_list.json"

echo "📦 Export de la liste des thèmes installés..."
docker exec wordpress_app wp theme list --allow-root --path=/var/www/html --format=json > "$BACKUP_DIR/themes_list.json" 2>/dev/null || echo "[]" > "$BACKUP_DIR/themes_list.json"

echo "📦 Export des options WordPress..."
docker exec wordpress_app wp option get blogname --allow-root --path=/var/www/html > "$BACKUP_DIR/wp_blogname.txt" 2>/dev/null || echo "Mon Site WordPress" > "$BACKUP_DIR/wp_blogname.txt"
docker exec wordpress_app wp option get siteurl --allow-root --path=/var/www/html > "$BACKUP_DIR/wp_siteurl.txt" 2>/dev/null || echo "http://localhost:8080" > "$BACKUP_DIR/wp_siteurl.txt"

echo ""
echo "✅ Sauvegarde terminée!"
echo ""
echo "📁 Fichiers créés dans $BACKUP_DIR:"
echo "   - ${BACKUP_FILE}.sql.gz (base de données)"
echo "   - plugins_list.json (liste des plugins)"
echo "   - themes_list.json (liste des thèmes)"
echo "   - wp_*.txt (configuration WordPress)"
echo ""
echo "📝 Pour versionner sur Git:"
echo "   git add $BACKUP_DIR/"
echo "   git commit -m 'Sauvegarde configuration WordPress - ${TIMESTAMP}'"
echo "   git push"
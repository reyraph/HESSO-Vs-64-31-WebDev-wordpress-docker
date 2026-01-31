#!/bin/bash
# Script de restauration de la configuration WordPress
# Ce script permet de restaurer une configuration WordPress sauvegardée

set -e

BACKUP_DIR="./backups"

echo "=== Restauration de la configuration WordPress ==="

# Vérifier que le dossier de backup existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Erreur: Le dossier $BACKUP_DIR n'existe pas"
    exit 1
fi

# Lister les sauvegardes disponibles
echo "📁 Sauvegardes disponibles:"
ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null || {
    echo "❌ Aucune sauvegarde trouvée dans $BACKUP_DIR"
    exit 1
}

echo ""
echo "Entrez le nom du fichier de sauvegarde à restaurer (sans le chemin):"
echo "Ou appuyez sur Entrée pour utiliser la plus récente"
read -r BACKUP_FILE

# Si aucun fichier spécifié, prendre le plus récent
if [ -z "$BACKUP_FILE" ]; then
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/*.sql.gz | head -n 1 | xargs basename)
    echo "Utilisation de la sauvegarde la plus récente: $BACKUP_FILE"
fi

# Vérifier que le fichier existe
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "❌ Erreur: Le fichier $BACKUP_DIR/$BACKUP_FILE n'existe pas"
    exit 1
fi

# Vérifier que les containers sont en cours d'exécution
if ! docker ps | grep -q wordpress_app; then
    echo "❌ Erreur: Le container WordPress n'est pas en cours d'exécution"
    echo "   Lancez d'abord: docker-compose up -d"
    exit 1
fi

echo ""
echo "⚠️  ATTENTION: Cette opération va écraser la configuration actuelle de WordPress"
echo "Voulez-vous continuer? (o/N)"
read -r CONFIRM

if [ "$CONFIRM" != "o" ] && [ "$CONFIRM" != "O" ]; then
    echo "Restauration annulée"
    exit 0
fi

echo ""
echo "📦 Décompression de la sauvegarde..."
gunzip -c "$BACKUP_DIR/$BACKUP_FILE" > /tmp/restore.sql

echo "📦 Restauration de la base de données..."
docker exec -i wordpress_db mysql -u wordpress_user -pwordpress_pass_2024 wordpress_db < /tmp/restore.sql

echo "🔄 Nettoyage du cache WordPress..."
docker exec wordpress_app wp cache flush --allow-root --path=/var/www/html 2>/dev/null || true

echo "🔄 Mise à jour des permaliens..."
docker exec wordpress_app wp rewrite flush --allow-root --path=/var/www/html 2>/dev/null || true

# Nettoyer le fichier temporaire
rm /tmp/restore.sql

echo ""
echo "✅ Restauration terminée!"
echo ""
echo "🌐 Accédez à WordPress sur: http://localhost:8080"
echo ""
echo "💡 Si vous avez des problèmes:"
echo "   - Redémarrez les containers: docker-compose restart"
echo "   - Vérifiez les logs: docker-compose logs -f"

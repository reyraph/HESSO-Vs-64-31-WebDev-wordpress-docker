# Makefile pour WordPress Docker
# Simplifie les commandes courantes

.PHONY: help start stop restart logs clean backup restore build status shell db-shell wp-cli

# Commande par défaut
.DEFAULT_GOAL := help

help: ## Affiche cette aide
	@echo "=== WordPress Docker - Commandes disponibles ==="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

start: ## Démarre l'environnement WordPress
	@echo "🚀 Démarrage de WordPress..."
	docker-compose up -d
	@echo "✅ WordPress démarré sur http://localhost:8080"
	@echo "⏱️  Attendez 30 secondes pour l'initialisation complète"

stop: ## Arrête l'environnement WordPress
	@echo "🛑 Arrêt de WordPress..."
	docker-compose down
	@echo "✅ WordPress arrêté"

restart: ## Redémarre l'environnement WordPress
	@echo "🔄 Redémarrage de WordPress..."
	docker-compose restart
	@echo "✅ WordPress redémarré"

logs: ## Affiche les logs en temps réel
	@echo "📋 Logs WordPress (Ctrl+C pour quitter)..."
	docker-compose logs -f

status: ## Affiche le statut des containers
	@echo "📊 Statut des containers:"
	@docker-compose ps

build: ## Reconstruit les images Docker
	@echo "🔨 Reconstruction des images..."
	docker-compose build --no-cache
	@echo "✅ Images reconstruites"

clean: ## Arrête et supprime TOUT (⚠️ PERTE DE DONNÉES!)
	@echo "⚠️  ATTENTION: Cette commande va supprimer TOUTES les données!"
	@echo "Tapez 'oui' pour confirmer:"
	@read -p "" confirm; \
	if [ "$$confirm" = "oui" ]; then \
		echo "🗑️  Suppression de tout..."; \
		docker-compose down -v; \
		echo "✅ Environnement réinitialisé"; \
	else \
		echo "❌ Annulé"; \
	fi

backup: ## Crée une sauvegarde de la configuration
	@echo "💾 Création d'une sauvegarde..."
	./backup.sh

restore: ## Restaure une configuration sauvegardée
	@echo "🔄 Restauration d'une sauvegarde..."
	./restore.sh

shell: ## Ouvre un shell dans le container WordPress
	@echo "🐚 Ouverture du shell WordPress..."
	@echo "Tapez 'exit' pour quitter"
	docker exec -it wordpress_app bash

db-shell: ## Ouvre un shell MySQL
	@echo "🗄️  Ouverture du shell MySQL..."
	@echo "Tapez 'exit' pour quitter"
	docker exec -it wordpress_db mysql -u wordpress_user -pwordpress_pass_2024 wordpress_db

wp-cli: ## Exemples de commandes WP-CLI utiles
	@echo "=== Commandes WP-CLI utiles ==="
	@echo ""
	@echo "Lister les plugins:"
	@echo "  docker exec wordpress_app wp plugin list --allow-root"
	@echo ""
	@echo "Installer un plugin:"
	@echo "  docker exec wordpress_app wp plugin install nom-plugin --activate --allow-root"
	@echo ""
	@echo "Créer un utilisateur:"
	@echo "  docker exec wordpress_app wp user create username email@example.com --role=editor --allow-root"
	@echo ""
	@echo "Vider le cache:"
	@echo "  docker exec wordpress_app wp cache flush --allow-root"
	@echo ""
	@echo "Mettre à jour WordPress:"
	@echo "  docker exec wordpress_app wp core update --allow-root"
	@echo ""

# Alias pratiques
up: start
down: stop

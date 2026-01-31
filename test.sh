#!/bin/bash
# Script de vérification de l'installation WordPress Docker
# Ce script teste que tous les éléments sont correctement configurés

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   🔍 Vérification de l'environnement WordPress Docker         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Compteur de tests
TESTS_TOTAL=0
TESTS_OK=0
TESTS_FAIL=0

# Fonction pour afficher un test réussi
test_ok() {
    echo "  ✅ $1"
    ((TESTS_OK++))
    ((TESTS_TOTAL++))
}

# Fonction pour afficher un test échoué
test_fail() {
    echo "  ❌ $1"
    ((TESTS_FAIL++))
    ((TESTS_TOTAL++))
}

# Fonction pour afficher une section
section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 1. Vérification de Docker
section "1. Prérequis système"

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    test_ok "Docker installé (version $DOCKER_VERSION)"
else
    test_fail "Docker n'est pas installé"
fi

if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | cut -d ' ' -f4 | cut -d ',' -f1)
    test_ok "Docker Compose installé (version $COMPOSE_VERSION)"
else
    test_fail "Docker Compose n'est pas installé"
fi

# 2. Vérification de la structure des fichiers
section "2. Structure du projet"

FILES=("docker-compose.yml" "backup.sh" "restore.sh" "Makefile" "README.md" "QUICKSTART.md")
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        test_ok "Fichier $file présent"
    else
        test_fail "Fichier $file manquant"
    fi
done

DIRS=("wordpress" "backups" "uploads" "themes")
for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        test_ok "Dossier $dir/ présent"
    else
        test_fail "Dossier $dir/ manquant"
    fi
done

# 3. Vérification des permissions
section "3. Permissions des scripts"

SCRIPTS=("backup.sh" "restore.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        test_ok "Script $script exécutable"
    else
        test_fail "Script $script non exécutable (utilisez: chmod +x $script)"
    fi
done

# 4. Vérification des containers (si lancés)
section "4. État des containers Docker"

if docker ps | grep -q wordpress_app; then
    test_ok "Container WordPress est en cours d'exécution"
    
    # Vérifier la santé du container
    WORDPRESS_STATUS=$(docker inspect --format='{{.State.Health.Status}}' wordpress_app 2>/dev/null)
    if [ "$WORDPRESS_STATUS" = "healthy" ] || [ -z "$WORDPRESS_STATUS" ]; then
        test_ok "Container WordPress fonctionne correctement"
    else
        test_fail "Container WordPress a un problème de santé: $WORDPRESS_STATUS"
    fi
else
    echo "  ⚠️  Container WordPress n'est pas démarré (normal si 1ère installation)"
fi

if docker ps | grep -q wordpress_db; then
    test_ok "Container MySQL est en cours d'exécution"
    
    # Vérifier la santé de la base de données
    DB_HEALTH=$(docker inspect --format='{{.State.Health.Status}}' wordpress_db 2>/dev/null)
    if [ "$DB_HEALTH" = "healthy" ]; then
        test_ok "Base de données MySQL en bonne santé"
    else
        test_fail "Base de données MySQL a un problème: $DB_HEALTH"
    fi
else
    echo "  ⚠️  Container MySQL n'est pas démarré (normal si 1ère installation)"
fi

# 5. Vérification de l'accès web (si lancé)
section "5. Accessibilité web"

if docker ps | grep -q wordpress_app; then
    # Attendre un peu que le serveur soit prêt
    sleep 2
    
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|301\|302"; then
        test_ok "Site WordPress accessible sur http://localhost:8080"
    else
        test_fail "Site WordPress non accessible sur http://localhost:8080"
    fi
else
    echo "  ⚠️  Test d'accessibilité ignoré (containers non démarrés)"
fi

# 6. Vérification de WP-CLI (si lancé)
section "6. Outils WordPress"

if docker ps | grep -q wordpress_app; then
    if docker exec wordpress_app wp --version --allow-root &> /dev/null; then
        WP_CLI_VERSION=$(docker exec wordpress_app wp --version --allow-root 2>/dev/null | cut -d ' ' -f2)
        test_ok "WP-CLI installé dans le container (version $WP_CLI_VERSION)"
    else
        test_fail "WP-CLI non accessible dans le container"
    fi
else
    echo "  ⚠️  Test WP-CLI ignoré (containers non démarrés)"
fi

# 7. Vérification de Git
section "7. Configuration Git"

if [ -d ".git" ]; then
    test_ok "Repository Git initialisé"
    
    REMOTE=$(git remote get-url origin 2>/dev/null)
    if [ -n "$REMOTE" ]; then
        test_ok "Remote Git configuré: $REMOTE"
    else
        echo "  ⚠️  Remote Git non configuré (configurez avec: git remote add origin URL)"
    fi
else
    echo "  ⚠️  Git non initialisé (initialisez avec: git init)"
fi

# Résultats finaux
section "📊 Résultats"

echo ""
echo "  Tests réussis: $TESTS_OK / $TESTS_TOTAL"
echo "  Tests échoués: $TESTS_FAIL / $TESTS_TOTAL"
echo ""

if [ $TESTS_FAIL -eq 0 ]; then
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  ✅ Tous les tests sont passés! Votre environnement est prêt ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Prochaines étapes:"
    echo "  1. Si pas encore fait: docker-compose up -d"
    echo "  2. Accédez à WordPress: http://localhost:8080"
    echo "  3. Configurez WordPress selon vos besoins"
    echo "  4. Sauvegardez: ./backup.sh"
    echo "  5. Versionnez sur Git: git add . && git commit && git push"
    exit 0
else
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  ⚠️  Certains tests ont échoué                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Consultez les erreurs ci-dessus et corrigez-les avant de continuer."
    echo "Pour plus d'aide, consultez README.md ou QUICKSTART.md"
    exit 1
fi

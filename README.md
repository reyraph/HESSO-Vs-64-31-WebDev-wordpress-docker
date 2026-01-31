# WordPress Docker - Environnement de développement pour étudiants

Ce projet fournit un environnement WordPress complet et pré-configuré utilisant Docker, spécialement conçu pour l'enseignement et l'apprentissage du développement web.

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Architecture du projet](#architecture-du-projet)
- [Installation et démarrage](#installation-et-démarrage)
- [Configuration initiale](#configuration-initiale)
- [Modification et personnalisation](#modification-et-personnalisation)
- [Sauvegarde et versionnement](#sauvegarde-et-versionnement)
- [Restauration](#restauration)
- [Commandes utiles](#commandes-utiles)
- [Résolution de problèmes](#résolution-de-problèmes)

## 🔧 Prérequis

Avant de commencer, assurez-vous d'avoir installé sur votre machine:

- **Docker Desktop** (version 20.10 ou supérieure)
  - Windows/Mac: [Télécharger Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Linux: [Instructions d'installation](https://docs.docker.com/engine/install/)
- **Docker Compose** (inclus avec Docker Desktop)
- **Git** pour cloner et versionner le projet
- Au moins **2 Go d'espace disque** disponible

### Vérification de l'installation

```bash
docker --version
docker-compose --version
```

## 🏗️ Architecture du projet

Le projet utilise deux containers Docker:

1. **Container WordPress** (`wordpress_app`)
   - Image personnalisée basée sur WordPress officiel
   - Serveur Apache
   - PHP 8.x
   - WP-CLI (WordPress Command Line Interface)
   - Plugins pré-installés

2. **Container MySQL** (`wordpress_db`)
   - Base de données MySQL 8.0
   - Données persistantes

### Structure des fichiers

```
wordpress-docker-etudiant/
├── docker-compose.yml          # Configuration des services Docker
├── wordpress/
│   ├── Dockerfile              # Image WordPress personnalisée
│   ├── docker-entrypoint.sh    # Script de démarrage
│   └── init-wordpress.sh       # Script d'initialisation
├── uploads/                    # Médias WordPress (images, fichiers)
├── themes/                     # Thèmes personnalisés (optionnel)
├── backups/                    # Sauvegardes de configuration
│   ├── plugins_list.json       # Liste des plugins installés
│   ├── themes_list.json        # Liste des thèmes installés
│   └── *.sql.gz               # Dumps de la base de données
├── backup.sh                   # Script de sauvegarde
├── restore.sh                  # Script de restauration
├── .gitignore                  # Fichiers à exclure de Git
└── README.md                   # Ce fichier

```

## 🚀 Installation et démarrage

### 1. Cloner le projet

```bash
git clone <URL_DU_REPO>
cd wordpress-docker-etudiant
```

### 2. Lancer l'environnement

```bash
docker-compose up -d
```

Cette commande va:
- Télécharger les images Docker nécessaires (première fois uniquement)
- Créer et démarrer les containers
- Installer WordPress
- Installer automatiquement les plugins pré-configurés
- Configurer les permaliens et autres options de base

### 3. Accéder à WordPress

Attendez environ 30 secondes pour que l'initialisation se termine, puis accédez à:

- **Site WordPress**: http://localhost:8080
- **Interface d'administration**: http://localhost:8080/wp-admin

### 4. Compléter l'installation WordPress

Lors de la première visite, WordPress vous demandera de:

1. Choisir la langue (français recommandé)
2. Créer un compte administrateur:
   - **Nom d'utilisateur**: admin (ou votre choix)
   - **Mot de passe**: choisissez un mot de passe fort
   - **Email**: votre adresse email
3. Donner un titre à votre site

## ⚙️ Configuration initiale

### Plugins pré-installés

Par défaut, les plugins suivants sont installés et activés:

- **Classic Editor**: Éditeur classique WordPress (alternative à Gutenberg)
- **Duplicate Post**: Permet de dupliquer facilement des articles et pages
- **Contact Form 7**: Création de formulaires de contact
- **All-in-One WP Migration**: Outil de migration et sauvegarde
- **WPForms Lite**: Constructeur de formulaires avancé

### Ajouter d'autres plugins par défaut

Pour ajouter des plugins qui seront installés automatiquement:

1. Éditez le fichier `wordpress/init-wordpress.sh`
2. Ajoutez le slug du plugin dans le tableau `PLUGINS`:

```bash
PLUGINS=(
    "classic-editor"
    "duplicate-post"
    "contact-form-7"
    "all-in-one-wp-migration"
    "wpforms-lite"
    "votre-nouveau-plugin"    # Ajoutez ici
)
```

3. Reconstruisez et redémarrez:

```bash
docker-compose down
docker-compose up -d --build
```

### Configuration des options WordPress

Le fichier `init-wordpress.sh` configure également:
- **Permaliens**: Format "nom de l'article" (`/%postname%/`)
- **Commentaires**: Désactivés par défaut pour les nouveaux articles
- **Fuseau horaire**: Europe/Zurich (modifiable)

## 🎨 Modification et personnalisation

### Workflow de personnalisation

1. **Démarrer l'environnement**:
   ```bash
   docker-compose up -d
   ```

2. **Personnaliser WordPress**:
   - Installer des thèmes via l'interface d'administration
   - Activer/désactiver des plugins
   - Créer des menus de navigation
   - Configurer les widgets
   - Créer des pages et articles d'exemple
   - Personnaliser l'apparence (couleurs, logo, etc.)

3. **Sauvegarder vos modifications** (voir section suivante)

### Accès aux fichiers WordPress

Les fichiers WordPress sont stockés dans un volume Docker. Pour y accéder:

```bash
# Accéder au container
docker exec -it wordpress_app bash

# Naviguer dans WordPress
cd /var/www/html

# Exemple: lister les plugins installés
wp plugin list --allow-root
```

## 💾 Sauvegarde et versionnement

### Sauvegarder votre configuration

Une fois vos modifications terminées, créez une sauvegarde:

```bash
./backup.sh
```

Ce script va créer dans le dossier `backups/`:
- Un dump complet de la base de données (`.sql.gz`)
- La liste des plugins installés (`plugins_list.json`)
- La liste des thèmes installés (`themes_list.json`)
- Les options WordPress principales (nom du site, description, etc.)

### Versionner sur Git

Après une sauvegarde, versionnez vos modifications:

```bash
# Ajouter les fichiers de sauvegarde
git add backups/

# Optionnel: ajouter vos thèmes personnalisés
git add themes/

# Commit
git commit -m "Configuration WordPress: plugins, thèmes et contenu initial"

# Pousser sur GitHub
git push origin main
```

### Ce qui est versionné / Ce qui ne l'est pas

**✅ Versionné** (sauvegardé sur Git):
- Configuration Docker (docker-compose.yml, Dockerfile)
- Scripts de sauvegarde/restauration
- Exports de la base de données (`.sql.gz`)
- Listes de plugins et thèmes
- Thèmes personnalisés (optionnel)
- Documentation

**❌ Non versionné** (fichiers locaux):
- Uploads et médias (dossier `uploads/`)
- Volumes Docker (données dynamiques)
- Fichiers temporaires et logs
- Fichiers de configuration locale (`.env`)

## 🔄 Restauration

### Pour les étudiants: Première installation

```bash
# 1. Cloner le repository
git clone <URL_DU_REPO>
cd wordpress-docker-etudiant

# 2. Démarrer l'environnement
docker-compose up -d

# 3. Attendre l'initialisation (30 secondes)
# 4. Restaurer la configuration sauvegardée
./restore.sh

# 5. Accéder à WordPress
# http://localhost:8080
```

### Restaurer une sauvegarde spécifique

Le script `restore.sh` vous permet de choisir quelle sauvegarde restaurer:

```bash
./restore.sh
```

Suivez les instructions à l'écran pour:
1. Voir les sauvegardes disponibles
2. Choisir laquelle restaurer (ou utiliser la plus récente)
3. Confirmer la restauration

## 🛠️ Commandes utiles

### Gestion des containers

```bash
# Démarrer l'environnement
docker-compose up -d

# Arrêter l'environnement
docker-compose down

# Arrêter et supprimer les données (⚠️ perte de données!)
docker-compose down -v

# Redémarrer l'environnement
docker-compose restart

# Voir les logs
docker-compose logs -f

# Voir les logs d'un container spécifique
docker-compose logs -f wordpress
docker-compose logs -f db

# Reconstruire les images
docker-compose up -d --build
```

### WP-CLI (WordPress Command Line)

```bash
# Accéder au container WordPress
docker exec -it wordpress_app bash

# Une fois dans le container, utiliser WP-CLI:

# Lister les plugins
wp plugin list --allow-root

# Installer un plugin
wp plugin install nom-du-plugin --activate --allow-root

# Désactiver un plugin
wp plugin deactivate nom-du-plugin --allow-root

# Lister les thèmes
wp theme list --allow-root

# Créer un utilisateur
wp user create username email@example.com --role=editor --allow-root

# Vider le cache
wp cache flush --allow-root

# Mettre à jour WordPress
wp core update --allow-root

# Quitter le container
exit
```

### Accès à la base de données

```bash
# Accéder à MySQL
docker exec -it wordpress_db mysql -u wordpress_user -pwordpress_pass_2024 wordpress_db

# Une fois dans MySQL:
SHOW TABLES;
SELECT * FROM wp_options WHERE option_name = 'siteurl';
exit
```

## 🔍 Résolution de problèmes

### Le site n'est pas accessible sur http://localhost:8080

**Vérifications**:
```bash
# Vérifier que les containers sont bien démarrés
docker ps

# Vérifier les logs pour des erreurs
docker-compose logs -f

# Vérifier que le port 8080 n'est pas déjà utilisé
# Sur Windows/Mac: netstat -an | find "8080"
# Sur Linux: netstat -an | grep 8080
```

**Solution**: Si le port 8080 est occupé, modifiez le dans `docker-compose.yml`:
```yaml
ports:
  - "8081:80"  # Changez 8080 en 8081 (ou autre port libre)
```

### Erreur "Error establishing a database connection"

**Cause**: La base de données n'est pas encore prête ou les credentials sont incorrects.

**Solutions**:
```bash
# Attendre 30 secondes et recharger la page

# Vérifier les logs de la base de données
docker-compose logs db

# Redémarrer les containers
docker-compose restart

# En dernier recours, tout supprimer et recommencer
docker-compose down -v
docker-compose up -d
```

### Les plugins ne s'installent pas automatiquement

**Vérifications**:
```bash
# Vérifier les logs d'initialisation
docker-compose logs wordpress | grep "Initialisation"

# Vérifier si le fichier marqueur existe
docker exec wordpress_app ls -la /var/www/html/.initialized
```

**Solution**: Forcer la réinitialisation
```bash
docker exec wordpress_app rm /var/www/html/.initialized
docker-compose restart wordpress
```

### Modifier le mot de passe de la base de données

Si vous voulez changer les mots de passe par défaut (recommandé pour la production):

1. Éditez `docker-compose.yml`
2. Changez les valeurs dans les sections `environment`:
   - `MYSQL_ROOT_PASSWORD`
   - `MYSQL_PASSWORD`
   - `WORDPRESS_DB_PASSWORD`
3. Supprimez et recréez l'environnement:
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```

### Réinitialiser complètement l'environnement

```bash
# ⚠️ ATTENTION: Cette commande supprime TOUTES les données!
docker-compose down -v
docker volume prune -f
docker-compose up -d
```

## 📚 Ressources complémentaires

- [Documentation officielle WordPress](https://wordpress.org/support/)
- [Documentation WP-CLI](https://wp-cli.org/)
- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)

## 👥 Support et contribution

Pour toute question ou problème:
1. Consultez d'abord cette documentation
2. Vérifiez les logs: `docker-compose logs -f`
3. Contactez votre enseignant

## 📝 Licence

Ce projet est fourni à des fins éducatives.

---

**Version**: 1.0  
**Dernière mise à jour**: Janvier 2026  
**Auteur**: Raphaël Racine - HES-SO Valais

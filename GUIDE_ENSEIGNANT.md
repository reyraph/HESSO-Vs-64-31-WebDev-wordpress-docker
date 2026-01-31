# Guide de l'enseignant - Préparation et distribution

Ce guide vous accompagne dans la préparation d'un environnement WordPress pré-configuré pour vos étudiants.

## 📋 Table des matières

1. [Préparation initiale](#préparation-initiale)
2. [Configuration de WordPress](#configuration-de-wordpress)
3. [Sauvegarde et versionnement](#sauvegarde-et-versionnement)
4. [Distribution aux étudiants](#distribution-aux-étudiants)
5. [Maintenance et mises à jour](#maintenance-et-mises-à-jour)
6. [Cas d'usage pédagogiques](#cas-dusage-pédagogiques)

---

## 1️⃣ Préparation initiale

### Première installation

```bash
# 1. Créer un nouveau repository sur GitHub
# Allez sur github.com et créez un nouveau repository public
# Nom suggéré: wordpress-docker-cours-[nom-du-cours]

# 2. Cloner ce projet template
git clone https://github.com/votre-username/wordpress-docker-etudiant.git
cd wordpress-docker-etudiant

# 3. Changer l'origine Git
git remote set-url origin https://github.com/votre-username/nouveau-repo.git

# 4. Démarrer l'environnement
docker-compose up -d

# 5. Attendre l'initialisation (environ 30 secondes)
docker-compose logs -f wordpress | grep "Initialisation terminée"
```

### Vérification de l'installation

Accédez à http://localhost:8080 et vérifiez que:
- ✅ WordPress s'affiche correctement
- ✅ Les plugins sont installés et activés
- ✅ L'interface d'administration est accessible

---

## 2️⃣ Configuration de WordPress

### Installation de base

1. **Accédez à l'administration**: http://localhost:8080/wp-admin

2. **Complétez l'installation**:
   - Langue: Français
   - Titre du site: "Cours [Nom du cours] - Environnement de développement"
   - Identifiant: admin (ou votre choix)
   - Mot de passe: ⚠️ **Notez-le bien!**
   - Email: votre email HES-SO

3. **Première connexion**: Connectez-vous avec vos identifiants

### Personnalisation selon votre cours

#### A) Pour un cours de développement web

```bash
# Installer des plugins de développement
docker exec wordpress_app wp plugin install query-monitor --activate --allow-root
docker exec wordpress_app wp plugin install debug-bar --activate --allow-root
docker exec wordpress_app wp plugin install show-current-template --activate --allow-root
```

**Configuration recommandée**:
- Thème: Twenty Twenty-Four (moderne, pour apprendre Gutenberg)
- Créer des exemples de pages: Accueil, À propos, Contact, Blog
- Créer 3-5 articles de démonstration
- Configurer un menu de navigation

#### B) Pour un cours de design/UX

```bash
# Installer des plugins orientés design
docker exec wordpress_app wp plugin install elementor --activate --allow-root
docker exec wordpress_app wp plugin install custom-css-js --activate --allow-root
```

**Configuration recommandée**:
- Thème: Astra ou Kadence (flexibles pour le design)
- Créer des templates de page variés
- Préparer des exemples de mise en page
- Configurer des zones de widgets

#### C) Pour un cours de marketing digital

```bash
# Installer des plugins marketing
docker exec wordpress_app wp plugin install google-analytics-for-wordpress --activate --allow-root
docker exec wordpress_app wp plugin install mailchimp-for-wp --activate --allow-root
docker exec wordpress_app wp plugin install wordpress-seo --activate --allow-root
```

**Configuration recommandée**:
- Créer un blog avec différentes catégories
- Préparer des formulaires de contact et newsletter
- Configurer les permaliens SEO-friendly
- Créer des pages landing page

### Ajout de contenu d'exemple

#### Créer des pages

Voici un script pour créer rapidement des pages d'exemple:

```bash
# Page d'accueil
docker exec wordpress_app wp post create \
  --post_type=page \
  --post_title='Accueil' \
  --post_content='Bienvenue sur le site de démonstration du cours.' \
  --post_status=publish \
  --allow-root

# Page À propos
docker exec wordpress_app wp post create \
  --post_type=page \
  --post_title='À propos' \
  --post_content='Présentation de notre entreprise.' \
  --post_status=publish \
  --allow-root

# Page Contact
docker exec wordpress_app wp post create \
  --post_type=page \
  --post_title='Contact' \
  --post_content='[contact-form-7 id="1" title="Formulaire de contact"]' \
  --post_status=publish \
  --allow-root
```

#### Créer des articles de blog

```bash
# Article 1
docker exec wordpress_app wp post create \
  --post_title='Premier article de blog' \
  --post_content='Contenu de l\'article de démonstration.' \
  --post_status=publish \
  --post_category=1 \
  --allow-root

# Article 2
docker exec wordpress_app wp post create \
  --post_title='Deuxième article' \
  --post_content='Autre exemple d\'article.' \
  --post_status=publish \
  --allow-root
```

#### Créer des menus

Via l'interface admin:
1. Apparence → Menus
2. Créer un nouveau menu "Navigation principale"
3. Ajouter les pages créées
4. Assigner à l'emplacement "Primary Menu"

### Créer des comptes utilisateurs pour exercices

```bash
# Créer un éditeur
docker exec wordpress_app wp user create editeur editeur@example.com \
  --role=editor \
  --user_pass=etudiant2024 \
  --display_name='Éditeur Exemple' \
  --allow-root

# Créer un auteur
docker exec wordpress_app wp user create auteur auteur@example.com \
  --role=author \
  --user_pass=etudiant2024 \
  --display_name='Auteur Exemple' \
  --allow-root

# Créer un contributeur
docker exec wordpress_app wp user create contributeur contributeur@example.com \
  --role=contributor \
  --user_pass=etudiant2024 \
  --display_name='Contributeur Exemple' \
  --allow-root
```

---

## 3️⃣ Sauvegarde et versionnement

### Créer une sauvegarde de votre configuration

Une fois votre WordPress configuré comme vous le souhaitez:

```bash
# 1. Créer la sauvegarde
./backup.sh

# 2. Vérifier les fichiers créés
ls -lh backups/
```

Vous devriez voir:
- `wordpress_config_YYYYMMDD_HHMMSS.sql.gz` - La base de données
- `plugins_list.json` - Liste des plugins
- `themes_list.json` - Liste des thèmes
- Fichiers `wp_*.txt` - Configuration WordPress

### Versionner sur Git

```bash
# 1. Ajouter les fichiers de sauvegarde
git add backups/

# 2. Ajouter les modifications éventuelles
git add docker-compose.yml wordpress/ README.md

# 3. Créer un commit descriptif
git commit -m "Configuration WordPress - Cours [NOM] - Semestre [X]

- Plugins installés: Classic Editor, Contact Form 7, etc.
- Thème configuré: Twenty Twenty-Four
- Pages créées: Accueil, À propos, Contact, Blog
- 5 articles de démonstration
- 3 comptes utilisateurs (rôles: editeur, auteur, contributeur)
- Menu de navigation configuré"

# 4. Pousser sur GitHub
git push origin main
```

### Créer un tag pour cette version

```bash
# Créer un tag avec la version du cours
git tag -a v1.0-automne2024 -m "Version cours automne 2024"
git push origin v1.0-automne2024
```

---

## 4️⃣ Distribution aux étudiants

### Préparer les instructions pour les étudiants

1. **Créez un document d'instructions** (sur Moodle, Teams, etc.):

```markdown
# Installation de l'environnement WordPress

## Prérequis
1. Installez Docker Desktop: https://www.docker.com/products/docker-desktop
2. Vérifiez l'installation: ouvrez un terminal et tapez `docker --version`

## Installation

1. Ouvrez un terminal
2. Téléchargez le projet:
   ```
   git clone https://github.com/VOTRE-USERNAME/wordpress-docker-cours.git
   cd wordpress-docker-cours
   ```
3. Démarrez WordPress:
   ```
   docker-compose up -d
   ```
4. Attendez 30 secondes, puis restaurez la configuration:
   ```
   ./restore.sh
   ```
5. Accédez à WordPress: http://localhost:8080

## Identifiants de test
- **Administrateur**: admin / [mot de passe fourni en cours]
- **Éditeur**: editeur@example.com / etudiant2024
- **Auteur**: auteur@example.com / etudiant2024

## Besoin d'aide ?
Consultez le fichier QUICKSTART.md dans le projet
```

### Communication avec les étudiants

**Email type**:

```
Objet: Environnement WordPress pour le cours [NOM DU COURS]

Bonjour,

Pour ce cours, vous allez travailler avec WordPress dans un environnement
Docker pré-configuré. Cela vous permettra d'avoir un environnement de 
développement identique à tous vos collègues.

Repository GitHub: [URL]

Instructions d'installation: [LIEN VERS LE DOCUMENT]

Assurez-vous d'avoir installé Docker Desktop AVANT le prochain cours.
Nous vérifierons ensemble que tout fonctionne.

En cas de problème, contactez-moi ou consultez le fichier QUICKSTART.md
dans le projet.

Cordialement,
[Votre nom]
```

### Support technique aux étudiants

**Problèmes courants et solutions**:

| Problème | Solution |
|----------|----------|
| "docker: command not found" | Docker Desktop n'est pas installé |
| "Port 8080 already in use" | Changer le port dans docker-compose.yml |
| "Permission denied" | Sous Linux: `sudo usermod -aG docker $USER` puis redémarrer |
| Site inaccessible | Vérifier que Docker Desktop est lancé |
| Erreur base de données | Attendre plus longtemps (60s) ou redémarrer |

---

## 5️⃣ Maintenance et mises à jour

### Mettre à jour la configuration en cours de semestre

Si vous devez ajouter du contenu ou des plugins après le début du cours:

```bash
# 1. Faire vos modifications dans WordPress

# 2. Créer une nouvelle sauvegarde
./backup.sh

# 3. Commiter et pousser
git add backups/
git commit -m "Mise à jour: ajout exercice semaine 5"
git push

# 4. Informer les étudiants
# Email: "Mettez à jour votre environnement avec 'git pull && ./restore.sh'"
```

### Créer différentes versions pour différents groupes

```bash
# Créer une branche par classe
git checkout -b classe-A
# ... configuration spécifique classe A ...
git push origin classe-A

git checkout main
git checkout -b classe-B
# ... configuration spécifique classe B ...
git push origin classe-B
```

Instructions aux étudiants:
```bash
# Classe A
git clone -b classe-A https://github.com/...

# Classe B
git clone -b classe-B https://github.com/...
```

---

## 6️⃣ Cas d'usage pédagogiques

### Scénario 1: Apprentissage des rôles utilisateurs

**Configuration**:
- Créer 4-5 comptes avec rôles différents
- Chaque étudiant teste un rôle différent

**Exercice**:
1. Se connecter avec chaque compte
2. Noter les différences de permissions
3. Créer un tableau comparatif des capacités

### Scénario 2: Projet de création de site vitrine

**Configuration**:
- WordPress vierge avec thème de base
- Plugins essentiels installés
- Brief du projet dans une page "Consignes"

**Exercice**:
1. Créer les pages demandées (Accueil, Services, Contact, etc.)
2. Configurer le menu
3. Personnaliser l'apparence
4. Export du site final avec All-in-One WP Migration

### Scénario 3: Travaux pratiques sur les plugins

**Configuration**:
- Site de base avec contenu d'exemple
- Liste de plugins à tester

**Exercice**:
1. Installer et configurer un plugin de formulaire
2. Installer un plugin de galerie photo
3. Comparer différents plugins de SEO
4. Documentation de l'expérience

### Scénario 4: Développement de thème enfant

**Configuration**:
- Thème parent installé (Twenty Twenty-Four)
- WP-CLI disponible
- Éditeur de code externe (VS Code)

**Exercice**:
1. Créer un thème enfant
2. Modifier les CSS
3. Ajouter des fonctionnalités PHP
4. Tester les modifications

---

## 📞 Support et ressources

### Pour vous

- **Docker**: https://docs.docker.com/
- **WP-CLI**: https://wp-cli.org/
- **WordPress**: https://wordpress.org/support/

### Pour vos étudiants

- **QUICKSTART.md**: Guide rapide dans le projet
- **README.md**: Documentation complète
- **Forum de support**: Créez une section dédiée sur votre plateforme d'enseignement

---

## ✅ Checklist finale avant distribution

- [ ] WordPress fonctionne correctement (http://localhost:8080)
- [ ] Tous les plugins sont installés et activés
- [ ] Thème configuré et personnalisé
- [ ] Contenu d'exemple créé (pages, articles, menus)
- [ ] Comptes utilisateurs de test créés
- [ ] Sauvegarde effectuée avec `./backup.sh`
- [ ] Fichiers versionnés sur Git (`git push`)
- [ ] README.md mis à jour avec infos spécifiques à votre cours
- [ ] QUICKSTART.md adapté si nécessaire
- [ ] Instructions pour étudiants rédigées
- [ ] Tag créé pour cette version (`git tag v1.0-...`)

---

**Bon cours! 🎓**

Si vous avez des questions ou suggestions d'amélioration pour ce projet,
n'hésitez pas à créer une issue sur le repository GitHub.

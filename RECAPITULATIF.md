# 🎯 WordPress Docker - Projet finalisé

## ✅ Ce qui a été créé pour vous

Félicitations! Votre environnement WordPress Dockerisé est prêt à être partagé avec vos étudiants.

---

## 📦 Contenu du projet

### Fichiers principaux

| Fichier | Description | Usage |
|---------|-------------|-------|
| `docker-compose.yml` | Configuration des containers | Orchestration Docker |
| `wordpress/Dockerfile` | Image WordPress personnalisée | Build de l'image |
| `wordpress/init-wordpress.sh` | Installation auto des plugins | Au premier démarrage |
| `wordpress/docker-entrypoint.sh` | Point d'entrée du container | Gestion du démarrage |
| `backup.sh` ⭐ | **Script de sauvegarde** | Exporter votre config |
| `restore.sh` ⭐ | **Script de restauration** | Importer une config |
| `Makefile` | Commandes simplifiées | Raccourcis pratiques |

### Documentation

| Document | Public cible | Contenu |
|----------|--------------|---------|
| `README.md` | **Étudiants + Vous** | Documentation complète |
| `QUICKSTART.md` | **Étudiants** | Démarrage en 5 étapes |
| `GUIDE_ENSEIGNANT.md` | **Vous** | Workflow complet de préparation |
| `CHANGELOG.md` | Tous | Historique des versions |

### Dossiers

| Dossier | Contenu | Versionné Git? |
|---------|---------|----------------|
| `wordpress/` | Configuration Docker | ✅ Oui |
| `backups/` | Sauvegardes SQL et config | ✅ Oui |
| `uploads/` | Médias WordPress | ❌ Non (trop volumineux) |
| `themes/` | Thèmes personnalisés | ⚙️ Optionnel |

---

## 🚀 Prochaines étapes - Workflow complet

### 1️⃣ Tester localement (5 minutes)

```bash
# Démarrer l'environnement
cd /home/claude/wordpress-docker-etudiant
docker-compose up -d

# Attendre l'initialisation (30 secondes)
# Puis accéder à http://localhost:8080
```

### 2️⃣ Configurer WordPress (20-40 minutes)

**Installation de base**:
1. Accéder à http://localhost:8080
2. Choisir la langue: Français
3. Créer le compte admin (⚠️ notez bien le mot de passe!)
4. Se connecter à http://localhost:8080/wp-admin

**Personnalisation selon votre cours**:
- Installer des plugins supplémentaires si nécessaire
- Configurer un thème adapté
- Créer des pages d'exemple (Accueil, À propos, Contact, etc.)
- Créer 3-5 articles de blog pour démonstration
- Configurer un menu de navigation
- Créer des comptes utilisateurs de test (éditeur, auteur, contributeur)

💡 **Consultez `GUIDE_ENSEIGNANT.md` pour des exemples détaillés selon le type de cours**

### 3️⃣ Sauvegarder votre configuration (2 minutes)

```bash
# Une fois votre WordPress configuré comme vous le souhaitez
./backup.sh

# Vérifier que les fichiers ont été créés
ls -lh backups/
```

Vous devriez voir:
- Un fichier `.sql.gz` (base de données)
- `plugins_list.json`
- `themes_list.json`
- Fichiers `wp_*.txt`

### 4️⃣ Créer le repository GitHub (5 minutes)

**Sur GitHub**:
1. Aller sur https://github.com/new
2. Nom du repository: `wordpress-docker-cours-[nom-de-votre-cours]`
3. Choisir "Public" (pour que les étudiants puissent cloner)
4. Ne PAS initialiser avec README (on a déjà les fichiers)
5. Créer le repository

**Depuis votre terminal**:
```bash
cd /home/claude/wordpress-docker-etudiant

# Initialiser Git si ce n'est pas déjà fait
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Configuration initiale WordPress pour cours [NOM DU COURS]

- Plugins installés: Classic Editor, Contact Form 7, etc.
- Configuration de base
- Contenu d'exemple
- Documentation complète en français"

# Lier au repository GitHub
git remote add origin https://github.com/VOTRE-USERNAME/VOTRE-REPO.git

# Pousser sur GitHub
git branch -M main
git push -u origin main

# Créer un tag pour cette version
git tag -a v1.0 -m "Version initiale - Semestre [X]"
git push origin v1.0
```

### 5️⃣ Distribuer aux étudiants (10 minutes)

**Préparer les instructions** (exemple de message):

```markdown
📧 Email aux étudiants
---

Objet: Installation environnement WordPress - Cours [NOM]

Bonjour,

Pour ce cours, vous allez utiliser WordPress dans un environnement Docker.
Cela garantit que tout le monde a la même configuration.

🔗 Repository GitHub: https://github.com/VOTRE-USERNAME/VOTRE-REPO

📋 Instructions d'installation:

1. Installer Docker Desktop: https://www.docker.com/products/docker-desktop
   
2. Télécharger le projet:
   ```
   git clone https://github.com/VOTRE-USERNAME/VOTRE-REPO.git
   cd wordpress-docker-cours-[nom]
   ```

3. Démarrer WordPress:
   ```
   docker-compose up -d
   ```

4. Restaurer la configuration du cours:
   ```
   ./restore.sh
   ```

5. Accéder à WordPress: http://localhost:8080

📖 Pour plus de détails, consultez le fichier QUICKSTART.md dans le projet.

⚠️ Important: Installez Docker Desktop AVANT le prochain cours!

Identifiants de test fournis en cours.

Cordialement,
[Votre nom]
```

---

## 🛠️ Commandes pratiques

### Commandes de base (avec le Makefile)

```bash
make start      # Démarrer WordPress
make stop       # Arrêter WordPress
make restart    # Redémarrer WordPress
make logs       # Voir les logs
make status     # État des containers
make backup     # Créer une sauvegarde
make restore    # Restaurer une sauvegarde
make shell      # Accéder au shell WordPress
make db-shell   # Accéder à MySQL
make help       # Afficher toutes les commandes
```

### Commandes sans Makefile

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Voir les logs
docker-compose logs -f

# Sauvegarder
./backup.sh

# Restaurer
./restore.sh
```

### Commandes WP-CLI utiles

```bash
# Lister les plugins
docker exec wordpress_app wp plugin list --allow-root

# Installer un plugin
docker exec wordpress_app wp plugin install nom-plugin --activate --allow-root

# Créer un utilisateur
docker exec wordpress_app wp user create username email@example.com --role=editor --allow-root

# Vider le cache
docker exec wordpress_app wp cache flush --allow-root
```

---

## 📚 Documentation disponible

### Pour vous

1. **GUIDE_ENSEIGNANT.md** ⭐
   - Workflow complet de préparation
   - Cas d'usage pédagogiques
   - Exemples de configuration selon type de cours
   - Scripts de création de contenu
   - Gestion de plusieurs groupes

2. **README.md**
   - Documentation technique complète
   - Résolution de problèmes
   - Architecture du projet

3. **CHANGELOG.md**
   - Historique des versions
   - Guide de versionnement

### Pour vos étudiants

1. **QUICKSTART.md** ⭐
   - Guide ultra-simplifié
   - Installation en 5 étapes
   - FAQ rapide

2. **README.md**
   - Documentation de référence
   - Commandes utiles
   - Résolution de problèmes

---

## ⚡ Modifications courantes

### Changer le port (si 8080 est occupé)

Éditez `docker-compose.yml`:
```yaml
ports:
  - "8081:80"  # Changez 8080 en 8081 (ou autre)
```

### Ajouter un plugin par défaut

Éditez `wordpress/init-wordpress.sh`:
```bash
PLUGINS=(
    "classic-editor"
    "duplicate-post"
    "contact-form-7"
    "all-in-one-wp-migration"
    "wpforms-lite"
    "nouveau-plugin"  # Ajoutez ici
)
```

Puis reconstruisez:
```bash
docker-compose down
docker-compose up -d --build
```

### Modifier les mots de passe par défaut

Éditez `docker-compose.yml` (sections `environment`) puis:
```bash
docker-compose down -v  # ⚠️ Supprime les données!
docker-compose up -d
```

---

## 🔄 Mise à jour en cours de semestre

Si vous devez modifier la configuration après le début du cours:

```bash
# 1. Faire vos modifications dans WordPress
# 2. Sauvegarder
./backup.sh

# 3. Versionner
git add backups/
git commit -m "Mise à jour semaine 5: ajout exercice XYZ"
git push

# 4. Créer un nouveau tag
git tag -a v1.1 -m "Mise à jour semaine 5"
git push origin v1.1

# 5. Informer les étudiants
# Email: "Mettez à jour avec: git pull && ./restore.sh"
```

---

## 🆘 Support et résolution de problèmes

### Problèmes courants

| Problème | Solution |
|----------|----------|
| Site inaccessible | Vérifier que Docker Desktop est lancé |
| Port 8080 occupé | Changer le port dans docker-compose.yml |
| Erreur base de données | Attendre plus longtemps (60s) ou redémarrer |
| Plugins non installés | Supprimer `.initialized` et redémarrer |
| Permission denied | Sous Linux: ajouter user au groupe docker |

### Réinitialisation complète

```bash
# ⚠️ ATTENTION: Supprime TOUTES les données!
docker-compose down -v
docker-compose up -d
./restore.sh  # Si vous avez une sauvegarde
```

---

## ✅ Checklist finale avant distribution

- [ ] WordPress fonctionne (http://localhost:8080) ✅
- [ ] Tous les plugins installés et activés ✅
- [ ] Thème configuré ✅
- [ ] Contenu d'exemple créé ✅
- [ ] Comptes utilisateurs de test créés ⚙️ (optionnel)
- [ ] Sauvegarde effectuée (`./backup.sh`) ⚠️ **IMPORTANT**
- [ ] Repository GitHub créé et poussé ⚠️ **IMPORTANT**
- [ ] Tag version créé (`git tag v1.0`) ✅ (recommandé)
- [ ] Instructions étudiants rédigées ⚠️ **IMPORTANT**
- [ ] README.md personnalisé avec nom de votre cours ⚙️ (optionnel)

---

## 🎓 Ressources

### Liens utiles

- **Docker Desktop**: https://www.docker.com/products/docker-desktop
- **Documentation WordPress**: https://wordpress.org/support/
- **WP-CLI**: https://wp-cli.org/
- **Git**: https://git-scm.com/doc

### Support pour vous

Si vous rencontrez des problèmes avec ce projet:
1. Consultez les fichiers de documentation
2. Vérifiez les logs: `docker-compose logs -f`
3. N'hésitez pas à adapter le projet à vos besoins spécifiques

---

## 📝 Notes finales

### Personnalisation

Ce projet est un template. N'hésitez pas à:
- Modifier la liste des plugins par défaut
- Adapter la documentation à votre cours
- Créer des branches pour différents groupes
- Ajouter vos propres scripts

### Maintenance

- Les sauvegardes sont compressées (`.sql.gz`) pour économiser l'espace
- Les uploads ne sont PAS versionnés (trop volumineux)
- Les volumes Docker persistent entre les redémarrages
- Pensez à tagger vos versions importantes

### Pour aller plus loin

- **Multi-sites**: Ajoutez `WORDPRESS_MULTISITE` dans docker-compose.yml
- **HTTPS local**: Ajoutez un reverse proxy (Traefik, Nginx)
- **Performance**: Activez Redis ou Memcached
- **CI/CD**: Automatisez les déploiements avec GitHub Actions

---

**Bon cours! 🚀**

N'oubliez pas de sauvegarder avec `./backup.sh` avant de pousser sur GitHub!

---

*Document créé le 31 janvier 2026*  
*Projet: WordPress Docker pour enseignement*  
*Auteur: Raphaël Racine - HES-SO Valais*

# Guide de démarrage rapide - WordPress Docker

## Pour les étudiants 🎓

### Installation en 5 étapes

#### 1️⃣ Prérequis
Installez Docker Desktop sur votre ordinateur:
- **Windows/Mac**: https://www.docker.com/products/docker-desktop
- **Linux**: https://docs.docker.com/engine/install/

#### 2️⃣ Téléchargement
```bash
git clone <URL_DU_REPO>
cd wordpress-docker-etudiant
```

#### 3️⃣ Démarrage
```bash
docker-compose up -d
```
⏱️ Attendez environ 30 secondes...

#### 4️⃣ Restauration (si nécessaire)
Si votre enseignant a fourni une configuration pré-établie:
```bash
./restore.sh
```

#### 5️⃣ Accès
Ouvrez votre navigateur: **http://localhost:8080**

---

## Pour l'enseignant 👨‍🏫

### Workflow de préparation

#### 1. Configuration initiale
```bash
# Cloner/créer le projet
git clone <URL_REPO> ou créer le dossier

# Démarrer
docker-compose up -d

# Attendre l'initialisation
sleep 30
```

#### 2. Personnalisation
- Accéder à http://localhost:8080/wp-admin
- Installer thèmes et plugins supplémentaires
- Créer le contenu d'exemple (pages, articles, menus)
- Configurer les widgets et l'apparence
- Créer des comptes utilisateurs d'exemple si nécessaire

#### 3. Sauvegarde
```bash
./backup.sh
```

#### 4. Versionnement sur GitHub
```bash
git add backups/ themes/ README.md
git commit -m "Configuration WordPress pour cours [NOM DU COURS]"
git push origin main
```

#### 5. Partage avec les étudiants
Communiquez l'URL du repository GitHub aux étudiants.

---

## Commandes essentielles 🔧

### Démarrage quotidien
```bash
docker-compose up -d      # Démarrer
```

### Arrêt
```bash
docker-compose down       # Arrêter (garde les données)
```

### Problèmes ?
```bash
docker-compose logs -f    # Voir les logs
docker-compose restart    # Redémarrer
```

### Tout réinitialiser (⚠️ PERTE DE DONNÉES!)
```bash
docker-compose down -v
docker-compose up -d
```

---

## FAQ Rapide ❓

**Q: Le site ne s'affiche pas**  
R: Vérifiez que Docker Desktop est bien lancé et que les containers sont démarrés (`docker ps`)

**Q: Port 8080 déjà utilisé**  
R: Modifiez le port dans `docker-compose.yml` (ligne `ports: - "8080:80"` → changez 8080)

**Q: Mot de passe admin oublié**  
R: Utilisez WP-CLI:
```bash
docker exec -it wordpress_app wp user update admin --user_pass=nouveaumotdepasse --allow-root
```

**Q: Impossible de télécharger des images**  
R: Vérifiez les permissions du dossier `uploads/`:
```bash
docker exec -it wordpress_app chmod -R 777 /var/www/html/wp-content/uploads
```

---

## Ressources utiles 📚

- **WordPress**: https://wordpress.org/support/
- **Docker**: https://docs.docker.com/
- **Ce projet sur GitHub**: <URL_DU_REPO>

---

**Support**: Contactez votre enseignant en cas de problème  
**Version**: 1.0 | **Date**: Janvier 2026

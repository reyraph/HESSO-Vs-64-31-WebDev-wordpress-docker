# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### À faire
- Ajouter support pour PHP 8.2
- Créer des profils de configuration prédéfinis (blog, e-commerce, vitrine)
- Ajouter script de génération de contenu lorem ipsum automatique

---

## [1.0.0] - 2026-01-31

### Ajouté
- Configuration Docker Compose avec WordPress et MySQL
- Image WordPress personnalisée avec WP-CLI
- Script d'initialisation automatique des plugins
- Plugins pré-installés:
  - Classic Editor
  - Duplicate Post
  - Contact Form 7
  - All-in-One WP Migration
  - WPForms Lite
- Script de sauvegarde (`backup.sh`)
- Script de restauration (`restore.sh`)
- Documentation complète en français:
  - README.md (documentation principale)
  - QUICKSTART.md (guide de démarrage rapide)
  - GUIDE_ENSEIGNANT.md (guide pour enseignants)
  - Ce CHANGELOG.md
- Makefile pour simplifier les commandes
- Fichier .gitignore adapté
- Fichier .env.example pour configuration personnalisée
- Dossiers pré-configurés (uploads/, themes/, backups/)
- Healthcheck pour la base de données
- Configuration WordPress automatique:
  - Permaliens en "nom de l'article"
  - Commentaires désactivés par défaut
  - Fuseau horaire Europe/Zurich
  - Support multilingue

### Configuration
- WordPress: dernière version stable
- MySQL: 8.0
- PHP: 8.x (inclus dans l'image WordPress)
- Port par défaut: 8080
- Volumes persistants pour données MySQL et WordPress

### Sécurité
- Séparation réseau Docker
- Variables d'environnement pour credentials
- Healthcheck de la base de données

---

## Format des versions futures

### [X.Y.Z] - YYYY-MM-DD

#### Ajouté
- Nouvelles fonctionnalités

#### Modifié
- Changements dans les fonctionnalités existantes

#### Déprécié
- Fonctionnalités bientôt supprimées

#### Supprimé
- Fonctionnalités supprimées

#### Corrigé
- Corrections de bugs

#### Sécurité
- Mises à jour de sécurité

---

## Guide de versionnement

### Numérotation de version (X.Y.Z)

- **X (Majeure)**: Changements incompatibles avec versions précédentes
  - Exemple: 1.0.0 → 2.0.0
  - Nécessite migration manuelle

- **Y (Mineure)**: Nouvelles fonctionnalités compatibles
  - Exemple: 1.0.0 → 1.1.0
  - Plugins ajoutés, nouvelles options

- **Z (Correctif)**: Corrections de bugs
  - Exemple: 1.0.0 → 1.0.1
  - Pas de nouvelles fonctionnalités

### Tags Git correspondants

```bash
# Version majeure
git tag -a v2.0.0 -m "Version 2.0 - Nouvelle architecture"

# Version mineure
git tag -a v1.1.0 -m "Ajout support e-commerce"

# Correctif
git tag -a v1.0.1 -m "Correction bug initialisation"

# Pousser les tags
git push origin --tags
```

---

**Contributeurs**: Raphaël Racine (HES-SO Valais)  
**Licence**: Projet éducatif  
**Repository**: [URL du repository GitHub]

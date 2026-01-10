# Skills Hub - BUT Techniques de Commercialisation

Application de gestion des compétences et du référentiel pédagogique pour le BUT TC.

## 🚀 Fonctionnalités

### 📚 Référentiel Digitalisé Complet
- **Couverture Totale** : BUT 1, BUT 2 et BUT 3 (Niveaux 1, 2, 3).
- **Parcours Spécialisés** :
  - Stratégie de Marque et Événementiel (SME)
  - Marketing et Management du Point de Vente (MMPV)
  - Marketing Digital, E-Business et Entrepreneuriat (MDEE)
  - Business International (BI)
  - Business Développement et Management de la Relation Client (BDMRC)
- **Contenu Riche** :
  - Fiches Ressources détaillées (Objectifs, Contenus pédagogiques, Mots clés).
  - Volumes horaires précis (ex: "24h dont 20h TP").
  - Lien direct entre Activités (SAÉ), Ressources et Compétences (AC).

### 🗺️ Roadmap & Découverte
- **Visualisation Stratégique** : Nouvelle vue Roadmap interactive présentant la progression des compétences (BUT 1 à 3) sous forme de matrice.
- **Génération PDF à la volée** : Moteur dynamique (`ReportLab`) créant des fiches interactives pour les Activités et Ressources.
  - **Sommaire Interactif** : Navigation par liens internes dans le PDF.
  - **Grille d'Auto-évaluation** : Page dédiée en mode paysage pour une utilisation optimale à l'impression.
- **Rendu Riche** : Support des badges interactifs et nettoyage automatique des caractères spéciaux (ligatures).

### 🖥️ Interface Utilisateur
- **Dashboard Central** : Point d'entrée unique sur le port 80 pour accéder à tous les services (Admin, Nextcloud, Mattermost, LDAP).
- **Filtrage Avancé** : Recherche et filtres par semestre, type et parcours pour la génération de documents.
- **Configuration d'Identité** : Gestion dynamique du logo, de l'adresse et des contacts de l'établissement.

### 🛠️ Outils d'Administration & Sécurité
- **Provisioning Nextcloud** : Création automatique de dossiers sécurisés en "Lecture Seule" pour les élèves via l'API.
- **Configuration SMTP** : Support des e-mails réels (OVH ssl0.ovh.net) pour les notifications et les futurs Magic Links.
- **Sauvegarde & Reset** : Procédure "bulletproof" pour une réinstallation complète automatisée avec restauration des données SQL et LDAP.

## 📦 Installation & Lancement

### Pré-requis
- Docker & Docker Compose

### Démarrage Rapide
```bash
# 1. Lancer l'infrastructure complète
npm run infra:up

# 2. Accéder au Tableau de Bord
# URL : http://projet-edu.eu/ (ou http://localhost)
```

### Services Disponibles
| Service | URL (Projet Edu) | Description |
| :--- | :--- | :--- |
| **Dashboard** | http://projet-edu.eu/ | Portail central (Port 80) |
| **Skills Hub Admin** | http://projet-edu.eu:3000/ | Gestion du référentiel |
| **Nextcloud** | http://projet-edu.eu:8082/ | Stockage & Édition |
| **Mattermost** | http://projet-edu.eu:8065/ | Collaboration |
| **LDAP Admin** | http://projet-edu.eu:8081/ | Gestion des comptes |
| **Mailpit** | http://projet-edu.eu:8025/ | Test des emails |


### Commandes Utiles

**Purger et reconstruire (Full Reset) :**
```bash
npm run infra:reset
```

**Sauvegarder les données (BDD) :**
```bash
docker exec but_tc_db pg_dump -U app_user skills_db > backup_data.sql
```

**Restaurer les données :**
```bash
docker exec -i but_tc_db psql -U app_user skills_db < backup_data.sql
```

## 📂 Structure du Projet

- `apps/api` : Backend FastAPI (SQLModel, PostgreSQL).
- `apps/web` : Frontend React (Mantine UI, Vite).
- `apps/api/app/data/referentiel_final.json` : Fichier maître des données pédagogiques.
- `infrastructure` : Configuration Docker et scripts de déploiement.
- `docs` : Documentation technique et prompts d'extraction.
- `tmp` : Scripts d'extraction et fichiers temporaires.

## 📝 Scripts d'Extraction (Maintenance)

Les scripts situés dans `tmp/` permettent de régénérer le fichier JSON à partir du PDF officiel.
- `extract_resources.py` : Ressources BUT 1.
- `extract_s2.py` : Activités BUT 1 (Semestre 2).
- `extract_pathways.py` : BUT 2 & 3 complets (tous parcours).
- `deduplicate_data.py` : Nettoyage des doublons.

---
*Projet développé avec l'assistance de Gemini CLI.*

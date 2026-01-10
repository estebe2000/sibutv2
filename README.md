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
- **Visualisation Stratégique** : Nouvelle vue Roadmap interactive présentant la progression des compétences (BUT 1 à 3) sous forme de matrice (Style Page 18).
- **Fiches PDF Intégrées** : Accès direct aux fiches pédagogiques PDF officielles (S1 à S6) stockées au sein de l'image Docker pour un déploiement sans dépendance locale.
- **Rendu Riche** : Moteur de rendu dynamique supportant les badges interactifs et le formatage propre pour les Apprentissages Critiques (AC).

### 🖥️ Interface Utilisateur
- **Vue en Accordéon** : Navigation fluide par Année et par Type (Compétences, Activités, Ressources).
- **Filtrage Dynamique** : Affichage contextuel selon le parcours sélectionné.
- **Fiches Détails** : Modales interactives pour consulter le détail d'une ressource, d'une activité ou d'un AC.
- **Tri Intelligent** : Affichage automatique des AC dans l'ordre numérique (01, 02, etc.).

### 🛠️ Outils d'Administration
- **Extraction PDF** : Scripts Python (`tmp/extract_*.py`) pour parser le Programme National (PN) PDF.
- **Seeding** : Peuplement automatique de la base de données PostgreSQL.
- **Gestion des Utilisateurs** : Import LDAP complet (45+ utilisateurs de test), assignation aux groupes, rôles.
- **Sauvegarde de la donnée** : Scripts de dump SQL pour sécuriser les enrichissements pédagogiques.

## 📦 Installation & Lancement

### Pré-requis
- Docker & Docker Compose
- Node.js (facultatif, pour le développement)

### Démarrage Rapide
```bash
# 1. Lancer l'infrastructure (Base de données, API, Frontend, LDAP, etc.)
npm run infra:up

# 2. Accéder à l'application
# Frontend : http://localhost:3000
# API Doc : http://localhost:8000/docs
```

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

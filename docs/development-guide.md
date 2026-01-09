# Guide de Développement

## Architecture des Données (Data Model)

Le modèle de données repose sur `SQLModel` (FastAPI) et PostgreSQL.

### Entités Principales

#### 1. Competency (Compétence)
Représente une macro-compétence (ex: C1, C4-SME).
- **Niveaux** : 1, 2, 3 (correspondant aux années du BUT).
- **Relation** : Contient des `LearningOutcome` (AC) et `EssentialComponent` (CE).

#### 2. Activity (SAÉ / Stage / Portfolio)
Représente une situation d'apprentissage.
- **Types** : `SAE`, `STAGE`, `PORTFOLIO`, `PROJET`.
- **Champs Clés** :
  - `pathway` : Parcours associé ("Tronc Commun", "SME", etc.).
  - `resources` : Liste des codes ressources (ex: "R1.01, R1.02").
  - `hours` : Volume horaire (entier).

#### 3. Resource (Ressource)
Représente un savoir ou un cours.
- **Champs Enrichis** :
  - `description` : Objectifs et contexte.
  - `content` : Contenu pédagogique détaillé.
  - `hours` : Volume horaire total (entier).
  - `hours_details` : Détail du volume (ex: "24h dont 10h TP").
  - `targeted_competencies` : Liste textuelle des compétences visées (C1, C2...).
  - `pathway` : Parcours associé (permet de distinguer R3.01 SME de R3.01 MMPV).

### Processus d'Extraction et de Seeding

Le fichier maître est `apps/api/app/data/referentiel_final.json`. Il est généré par des scripts Python qui parsent le PDF officiel du programme.

1.  **Extraction** : Les scripts dans `tmp/` (`extract_*.py`) lisent le PDF et mettent à jour le JSON.
2.  **Seeding** : Le script `apps/api/app/seed_db.py` lit ce JSON et peuple la base de données au démarrage du conteneur API.
    *   *Note* : Si le schéma de la base change (ex: ajout de colonne), une suppression des volumes (`docker-compose down -v`) est nécessaire car nous n'utilisons pas d'outil de migration (Alembic) pour ce prototype.

## Frontend (React / Mantine)

### Gestion du Référentiel (`CompetencyEditor` dans `App.tsx`)
- **Onglets** : Compétences / Activités / Ressources.
- **Filtres** :
  - Par Niveau (BUT 1, 2, 3).
  - Par Parcours (`pathway`). Le filtre s'applique aux Activités ET aux Ressources.
- **Affichage** :
  - Utilisation massive de `Accordion` pour la densité d'information.
  - Modales "Light" pour la consultation rapide.
  - Badges de couleur pour identifier les types et les heures.

## Bonnes Pratiques
- **Toujours passer par le script `refresh-data.sh`** pour mettre à jour les données locales après une modification du JSON ou des scripts d'extraction.
- **Respecter la nomenclature des codes** (`R3.SME.15`) pour garantir le bon fonctionnement des filtres.
# Skills Hub : Documentation d'Architecture Brownfield (État PoC)

## 1. Introduction

Ce document décrit l'architecture RÉELLE du projet Skills Hub à la fin de sa phase PoC. Il sert de base pour la planification de la transition vers la production et la fragmentation de la base de données.

### État du Document
*   **Version** : 1.0 (Audit PoC)
*   **Date** : 12/04/2026
*   **Auteur** : Winston (Architecte)

---

## 2. Vue d'Ensemble Technique

### Stack Technologique Actuelle
| Composant | Technologie | Version (estimée) | Notes |
| :--- | :--- | :--- | :--- |
| **Backend** | FastAPI | 0.100+ | Utilise SQLModel (SQLAlchemy + Pydantic) |
| **Frontend** | React | 18.x | Vite, Mantine UI, Zustand |
| **Base de Données** | PostgreSQL | 15+ | Monolithique (un seul schéma public) |
| **Auth** | Keycloak | v26 | Intégration LDAP/OIDC |
| **Stockage** | Nextcloud | v28+ | Via API/WebDAV pour les fichiers étudiants |

### Structure du Dépôt
```text
/
├── apps/
│   ├── api/            # Backend FastAPI
│   │   ├── app/
│   │   │   ├── models.py    # Monolithe de modèles SQLModel
│   │   │   ├── routers/   # Endpoints API (Auth, Curriculum, etc.)
│   │   │   └── services/  # Logique métier (Partielle)
│   ├── web/            # Frontend React
│   └── scodoc-api-relay/ # Proxy pour Scodoc (à vérifier)
├── infrastructure/     # Docker Compose (Dev/Prod)
└── docs/               # Documentation (README, PRD)
```

---

## 3. Analyse de la Base de Données (Monolithe)

Actuellement, tous les modèles résident dans `apps/api/app/models.py`.

### Domaines de Données Identifiés
1.  **IAM & Core** : `User`, `Group`, `SystemConfig`.
2.  **Référentiel (Curriculum)** : `Competency`, `LearningOutcome` (AC), `EssentialComponent` (CE), `Resource`.
3.  **Activités & Évaluation** : `Activity` (SAE/Stages), `ActivityGroup`, `EvaluationRubric`, `Grade`.
4.  **Stages (Internships)** : `Internship`, `Company`, `InternshipVisit`, `InternshipApplication`.
5.  **Portfolio & Traces** : `PortfolioPage`, `StudentFile`, `StudentPPP`.

### Relations Critiques (Goulots d'étranglement pour la fragmentation)
*   `Activity` est lié à `LearningOutcome` et `EssentialComponent` via des tables de liaison (`ActivityACLink`, `ActivityCELink`).
*   `Internship` utilise `LearningOutcome` via `InternshipACLink`.
*   `User` (LDAP UID) est la clé étrangère omniprésente utilisée dans presque tous les modules.

---

## 4. Dette Technique et Points de Vigilance

### Dette Identifiée
*   **Absence de Schémas** : Toutes les tables sont dans le schéma `public`. La fragmentation demandée par le PRD nécessitera une migration vers des schémas (`core`, `curriculum`, `internships`).
*   **Typage Pydantic** : Mélange entre les modèles de table et les modèles de réponse API.
*   **Logique Scodoc** : Actuellement centrée sur les étudiants. L'extension vers les responsables et ressources (FR1 du PRD) nécessite de nouveaux services.
*   **Stages vs SAE** : Le PRD demande de traiter les Stages comme des "SAE Solo". L'architecture actuelle sépare `Activity` et `Internship`, ce qui crée une duplication de logique d'évaluation.

### Workarounds du PoC
*   Les informations d'entreprise dans `Internship` sont parfois dupliquées (`company_name`, `company_address`) au lieu de pointer systématiquement vers `Company`.

---

## 5. Stratégie de Transition (Migration)

### Étape 1 : Isolation des Schémas (Fragmentation)
Nous allons migrer vers une structure multi-schémas :
*   `sch_core` : Utilisateurs, Groupes, Config.
*   `sch_curriculum` : Référentiel de compétences (Compétences, AC, CE, Ressources).
*   `sch_pedagogy` : SAE, Stages, Groupes, Évaluations.
*   `sch_portfolio` : Pages, Exports, Traces.

### Étape 2 : Unification SAE/Stages
Refactoriser le module `Internship` pour qu'il hérite ou utilise les mécanismes de `Activity` (SAE), permettant ainsi de réutiliser les grilles d'évaluation et le mapping des AC.

### Étape 3 : Abstraction Scodoc
Créer un service `ScodocService` dédié pour isoler les appels API et le mapping des données, afin de protéger le reste du système contre les changements d'API Scodoc.

---

## 6. Infrastructure de Production

### Déploiement Cible (172.16.95.98)
*   **Reverse Proxy** : Nginx gérant les certificats SSL et le dispatching vers les conteneurs.
*   **Keycloak** : Doit être configuré avec `KC_HOSTNAME` explicite pour éviter les erreurs de redirection OIDC rencontrées lors du PoC.
*   **Nextcloud** : Utilisation de l'application `user_oidc` pour assurer la cohérence des UID entre Skills Hub et le stockage des fichiers.

# BUT TC Skills Tracking Application - Brownfield Architecture

**Date :** Mercredi 7 Janvier 2026
**Version :** 2.0
**Statut :** Finalisé
**Auteur :** Winston (Architecte)

---

## 1. Introduction & Analyse de l'Existant

Ce document définit l'architecture technique pour l'évolution majeure du "Skills Hub". L'objectif est d'intégrer la multi-ténacité, la gouvernance avancée, l'accessibilité universelle et la collaboration en temps réel tout en assainissant le socle existant.

### 1.1 Analyse de l'état actuel
- **Stack** : FastAPI (Python), React (TypeScript + Mantine), PostgreSQL (SQLModel), Docker (LDAP, Nextcloud).
- **Points Critiques** : `App.tsx` et `main.py` sont trop volumineux et nécessitent une modularisation immédiate.
- **Infrastructure** : Utilisation robuste de Docker-compose pour les services tiers (LDAP, Nextcloud).

---

## 2. Stratégie d'Intégration et Multi-Ténacité

### 2.1 Isolation par Département (Multi-tenant)
L'application adopte une stratégie d'**isolation par instance Docker**. Chaque département dispose de :
*   Sa propre instance de l'App (code partagé, config isolée).
*   Sa propre base de données PostgreSQL (ou schéma dédié).
*   Sa propre instance/dossier Nextcloud.

### 2.2 Stratégie d'Intégration du Code
Extraction de la logique métier vers une structure **Feature-Based** (par fonctionnalités). Passage d'un design fixe à un design **Responsive & Accessible** (WCAG 2.1 AA).

---

## 3. Stack Technologique Étendue

| Catégorie | Technologie | Rôle |
| :--- | :--- | :--- |
| **Backend** | FastAPI | Moteur API. |
| **Frontend** | React + Mantine | UI adaptable et accessible. |
| **Stockage** | WebDAV Client | Proxy sécurisé pour Nextcloud. |
| **Collaboration** | Mattermost API | Canaux de projets automatiques. |
| **Accessibilité** | OpenDyslexic / Aria | Support inclusif. |
| **Reporting** | React-PDF / CSV | Génération de documents. |

---

## 4. Modèles de Données (Schéma BDD)

### 4.1 Évolutions Majeures
*   **`AcademicYear`** : Gère l'historique pluri-annuel (crucial pour les redoublants).
*   **`ResponsibilityMatrix`** : Lie les professeurs aux activités (SAE/Stage) avec des rôles (LEAD, INTERVENANT).
*   **`StudentEvaluation`** : Ajout du flag `is_capitalized` et du `magic_link_token`.
*   **`Workgroup`** : Gère les groupes de projet et leur canal Mattermost associé.
*   **`User.preferences` (JSON)** : Stocke les réglages d'accessibilité et de style d'affichage.

---

## 5. Architecture des Composants

### 5.1 Frontend (React)
Utilisation de Providers globaux pour l'injection dynamique de thèmes :
*   **`A11yProvider`** : Gère le contraste, les polices et le **Mode Zen**.
*   **`ViewModeProvider`** : Gère les styles d'affichage (Tuiles, Listes, Bannières).
*   **`LayoutEngine`** : Rend les composants selon la densité d'information choisie.

### 5.2 Backend (FastAPI)
Modularisation via `APIRouter` par domaines : `/auth`, `/admin`, `/curriculum`, `/evaluation`, `/collaboration`.

---

## 6. Design de l'API & Intégrations

*   **Config Dynamique** : `GET /api/public/config` pour charger le branding et les URLs externes.
*   **Proxy Nextcloud** : Le backend masque les accès WebDAV directs pour la sécurité.
*   **Magic Links** : Routes publiques protégées par tokens cryptographiques.
*   **Mattermost** : Automatisation via Bot Tokens pour la création de canaux.

---

## 7. Arborescence du Code (Source Tree)

```text
/
├── apps/
│   ├── api/ (Services, Routers, Core)
│   └── web/ (Contexts, Features, Theme)
├── packages/
│   └── shared/ (Types partagés)
└── infrastructure/ (Docker, CapRover)
```

---

## 8. Déploiement & Qualité

*   **Infrastructure** : Déploiement via CapRover. Une seule image Docker pour tous les départements, configurée via variables d'environnement.
*   **Qualité** : Strict Typing (TS/SQLModel), Documentation OpenAPI (Swagger), et tests unitaires sur les zones à risque (Calculs de notes, RBAC).
*   **Accessibilité** : Vérification systématique des contrastes et de la navigation clavier.

---

## 9. Prochaines Étapes

### Handoff Story Manager
"Veuillez utiliser cette architecture pour détailler les stories. Points clés : isolation Docker par département, injection dynamique de branding via `/api/public/config`, et gestion de la capitalisation via la table `AcademicYear`. Priorité à l'Epic 1 (Branding & Config)."

### Handoff Développeur
"La priorité technique est la modularisation de `main.py` et `App.tsx`. Utilisez le `A11yProvider` pour l'accessibilité et le `NextcloudService` pour tout accès aux fichiers. Aucun secret ne doit être hardcodé : utilisez les variables d'environnement."

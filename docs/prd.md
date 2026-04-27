# Skills Hub : Transition du PoC vers la Production - PRD Brownfield

## 1. Introduction et Analyse du Contexte

Ce document définit les exigences pour transformer le Proof of Concept (PoC) de **Skills Hub** en un système d'information académique robuste, prêt pour le déploiement en production à l'université.

### Objectifs de la Phase
*   **Solidifier l'infrastructure** : Fragmentation de la base de données, typage strict et tests.
*   **Étendre le périmètre fonctionnel** : Nouveau module de Stages (conçu comme une "SAE Solo"), gestion complète des SAE et intégration Scodoc étendue.
*   **Unifier l'écosystème** : Migration vers Emdash (portfolios) et centralisation des échanges via Matrix/Element.
*   **Garantir le déploiement** : Automatisation et sécurisation sur le serveur 172.16.95.98.

### Historique des Changements
| Version | Date | Description | Auteur |
| :--- | :--- | :--- | :--- |
| 1.0 | 12/04/2026 | Initialisation du PRD de transition PoC -> Prod | Winston (Architecte) |

---

## 2. Exigences (Requirements)

### 2.1 Exigences Fonctionnelles (FR)
*   **FR1 : Connecteur Scodoc Étendu** - Récupération automatique des ressources et de leurs responsables via API (Lecture seule).
*   **FR2 : Module Stages / SAE Solo** - Workflow complet : de la fiche de prospection à l'évaluation des AC (Apprentissages Critiques) par le trio Étudiant/Tuteur Péda/Tuteur Entreprise.
*   **FR3 : Gestion des SAE** - Création, affectation de groupes et suivi des compétences transversales.
*   **FR4 : Unification Matrix** - Création automatique de salons de discussion pour chaque stage/SAE.
*   **FR5 : Migration Portfolio** - Remplacement d'Odoo par Emdash comme plateforme de portfolio.

### 2.2 Exigences Non-Fonctionnelles (NFR)
*   **NFR1 : Fragmentation de la Base de Données** - Isolation logique par schémas PostgreSQL pour faciliter la maintenance.
*   **NFR2 : Typage et Qualité** - Migration vers Pydantic v2 et couverture de tests unitaires sur les services critiques.
*   **NFR3 : Performance** - Mise en cache des données Scodoc pour limiter les appels API et assurer une interface réactive.

### 2.3 Compatibilité (CR)
*   **CR1 : Source de Vérité Scodoc** - Skills Hub ne doit jamais modifier les données dans Scodoc.
*   **CR2 : Identité Unique** - Utilisation stricte de Keycloak (SSO) pour tous les services tiers (Emdash, Matrix, Nextcloud).

---

## 3. Contraintes Techniques et Intégration

### Stack Technique Actuelle
*   **Backend** : FastAPI (Python 3.11+), SQLModel.
*   **Frontend** : React (TS), Mantine UI v7, Zustand.
*   **Infrastructure** : Docker Compose, Keycloak v26, PostgreSQL.
*   **Hébergement** : Serveur Université (172.16.95.98), Nginx Reverse Proxy.

### Stratégie d'Intégration
*   **Gestion des Fichiers** : Utilisation de Nextcloud comme serveur de stockage (via API et WebDAV).
*   **Édition Collaborative** : Intégration OnlyOffice pour les documents dynamiques.
*   **Fragmentation DB** : Découpage en schémas (`core`, `stages`, `competences`) pour préparer une future architecture microservices si nécessaire.

---

## 4. Structure des Épiques et Stories

### Épique 1 : Fondations et Consolidation
*   **Story 1.1** : Fragmentation de la base de données (Schémas Postgres).
*   **Story 1.2** : Extension du connecteur Scodoc (Ressources & Responsables).
*   **Story 1.3** : Consolidation du code (Typage strict, Pydantic v2, Tests).

### Épique 2 : Le Module "Stage / SAE Solo"
*   **Story 2.1** : Fiche de prospection et sélection des AC (Globaux/Parcours).
*   **Story 2.2** : Workflow de validation (Directeur d'Études) et assignation des tuteurs.
*   **Story 2.3** : Évaluation multilatérale, arbitrage des AC et notation finale avec historique.

### Épique 3 : Écosystème et Déploiement
*   **Story 3.1** : Intégration Emdash et retrait d'Odoo.
*   **Story 3.2** : Automatisation Matrix/Element (Invitations tuteurs externes).
*   **Story 3.3** : Déploiement final, sécurisation HTTPS et scripts d'exploitation (Sauvegardes).

---

## 5. Risk Assessment (Analyse des Risques)
*   **Risque technique** : Complexité de l'accès Matrix pour les tuteurs externes (Solution : Client Web simplifié ou invitations Guests).
*   **Risque de données** : Intégrité lors de la fragmentation de la DB (Solution : Scripts de migration rigoureux et sauvegardes préalables).
*   **Risque d'adoption** : Complexité du nouveau workflow de notation (Solution : Interface intuitive basée sur Mantine UI et rapport de synthèse clair).

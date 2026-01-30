# Skills Hub - BUT Techniques de Commercialisation

Application de gestion des compétences, du référentiel pédagogique et de la valorisation du parcours étudiant pour le BUT TC.

## 🚀 Fonctionnalités Majeures

### 📱 Expérience Mobile First & PWA (NOUVEAU)
- **Application Mobile** : Interface optimisée pour smartphones (iPhone/Android).
- **Progressive Web App (PWA)** : Installable sur l'écran d'accueil, compatible avec l'encoche (notch) et le mode sombre.
- **Login Ergonomique** : Connexion simplifiée avec support complet de l'autofill (Keychain/Google) et clavier virtuel.
- **Navigation Tactile** : Menus en onglets "pills", listes verticales et actions adaptées au pouce.

### 📚 Référentiel & Pédagogie
- **Référentiel Digitalisé** : BUT 1 à 3, tous parcours (SME, MMPV, MDEE, BI, BDMRC).
- **Roadmap Interactive** : Visualisation matricielle de la progression des compétences (disponible sur mobile).
- **Génération PDF Dynamique** : Création automatique de fiches ressources et SAÉ rigoureuses (ReportLab).
- **Gouvernance** : Matrice des responsabilités (Ressources, SAÉ, Tutorat) avec exports PDF/CSV/JSON.

### 📄 Super Portfolio de Compétences
- **Éditeur de Blocs** : Interface moderne (style Notion via Editor.js) pour la rédaction des réflexions.
- **Coffre-fort des Preuves** : Dépôt sécurisé de documents (PDF, images) liés aux activités académiques.
- **Liaison Intelligente** : Insertion directe des preuves du coffre-fort dans les pages de réflexion.
- **Assistant d'Exportation** : Wizard par étapes pour générer un **Web-Book (HTML)** ou un **Book Officiel (PDF)** personnalisable.
- **Projet Personnel (PPP)** : Section dédiée à la réflexion post-BUT et aux ambitions de carrière.

### 🎓 Suivi du Terrain
- **Tutorat de Stage** : Cycle complet d'évaluation tripartite (Étudiant, Pro, Prof).
- **Suivi de Recherche (Mobile)** : Tableau de bord des candidatures en mode liste intelligente.
- **Graphiques Radar** : Visualisation croisée des compétences acquises en stage.
- **Magic Links** : Accès sans mot de passe pour les tuteurs en entreprise.

### 🛠️ Pilotage & Collaboration
- **Boîte à Idées Staff** : Hub de retours (Bugs, Idées, Demandes) avec système de vote (pouce jaune).
- **Transition Année** : Module de bascule académique avec archivage (5 ans) et promotion des cohortes.
- **Assistant IA** : Aide à la rédaction et analyse des fiches pédagogiques.

## 🏗️ Infrastructure & Résilience

La plateforme repose sur une architecture robuste séparant les environnements.

### Environnements
| Environnement | URL | Port | Rôle |
| :--- | :--- | :--- | :--- |
| **Production** | https://home.educ-ai.fr/app/ | 443 | Utilisation réelle |
| **Test Mobile** | https://home.educ-ai.fr/appdev/ | 443 | Validation UX Mobile & New Features |
| **Développement** | https://dev.educ-ai.fr | 8081 | Bac à sable technique |

### Stratégie de Sauvegarde (BCP)
- **Cible** : Serveur distant `tc-portail` (172.16.95.98) sur partition de **4 To**.
- **Sécurité** : Transfert par clé SSH RSA 4096 (port 4660).
- **Rétention** : Sauvegarde quotidienne avec historique sur **5 ans**.
- **Contenu** : Full SQL (App, Keycloak, Odoo, Mattermost) + Volumes de fichiers étudiants.

## 📦 Commandes de Gestion

### Lancement
```bash
# Installation Automatique (Premier lancement)
./install.sh
# Ce script génère les mots de passe, lance les conteneurs et vous guide vers l'assistant web.

# Lancer la production (et l'environnement de test mobile)
./start.sh

# Lancer l'environnement de développement (Sandbox)
npm run dev:start
```

### Maintenance & Sauvegarde
```bash
# Effectuer une sauvegarde manuelle vers le serveur de 4To
npm run prod:backup

# Verifier l'etat de l'espace et des archives sur le serveur de backup
npm run prod:check-backup

# Restaurer une archive (Rollback complet données + fichiers)
npm run prod:restore <nom_archive.tar.gz>
```

## 📂 Structure du Projet

- `apps/api` : Backend FastAPI (PostgreSQL / SQLModel).
- `apps/web` : Frontend React (Mantine UI / Vite) - Version Production.
- `apps/web-dev` : Frontend React - Version Test Mobile (Features UX avancées).
- `infrastructure` : Scripts critiques de sauvegarde, restauration et déploiement.
- `docs` : Documentation technique incluant le **Manuel d'Exploitation LaTeX**.

---
*Plateforme sécurisée et pérennisée pour le BUT Techniques de Commercialisation.*
# User Stories - Epic 1 : Fondation, Infrastructure & Branding

## Story 1.0 : Mise en place de la Gateway Unifiée (Nginx) [x]
**En tant qu'** Utilisateur (Étudiant ou Professeur),
**Je veux** accéder à tous les services (App, API, Nextcloud) via une adresse web unique sécurisée,
**Afin de** ne pas avoir à jongler avec des ports différents et d'éviter les erreurs de connexion.

*Note : OnlyOffice integration has known issues in local Docker Desktop environment (Server-to-Server communication).*

### Contexte Technique
*   **Composant :** Nginx (conteneur `dashboard` actuel à transformer).
*   **Architecture :** Reverse Proxy vers les conteneurs internes (`web`, `api`, `nextcloud`, `mattermost`).
*   **Sécurité :** Terminaison SSL unique.

### Critères d'Acceptation
1.  Le conteneur `dashboard` (Nginx) écoute sur les ports 80/443.
2.  L'URL `/` redirige vers l'application Web React (`web:80`).
3.  L'URL `/api` proxifie vers le backend FastAPI (`api:8000`).
4.  L'URL `/nextcloud` proxifie vers le service Nextcloud (`nextcloud:80`).
5.  Les ports internes (3000, 8000, 8082) ne sont plus exposés directement sur la machine hôte (sauf en dev si nécessaire).
6.  La configuration Nginx gère correctement les en-têtes Websocket (pour le HMR de Vite) et les gros fichiers (pour l'upload).

---

## Story 1.1 : Branding Dynamique via Variables d'Environnement
**En tant qu'** Administrateur Départemental,
**Je veux** que l'interface s'adapte aux couleurs et au logo de mon département via la configuration,
**Afin d'** assurer une identité visuelle cohérente sans modifier le code.

### Contexte Technique
*   **Frontend :** React + Mantine (Theme customization).
*   **Backend :** FastAPI (Endpoint de configuration).
*   **Variables :** `APP_LOGO_URL`, `APP_PRIMARY_COLOR`, `APP_WELCOME_MESSAGE`, `APP_CONTACT_EMAIL`.

### Critères d'Acceptation
1.  Le backend expose un endpoint `GET /api/public/config` accessible sans authentification.
2.  Cet endpoint retourne les valeurs des variables d'environnement (avec valeurs par défaut).
3.  Le frontend appelle cet endpoint au chargement (`App.tsx` ou un Provider dédié).
4.  La couleur primaire de Mantine est mise à jour dynamiquement avec `APP_PRIMARY_COLOR`.
5.  Le logo sur la page de login et dans le header est remplacé par `APP_LOGO_URL`.
6.  Le message d'accueil sur la page de login affiche `APP_WELCOME_MESSAGE`.

---

## Story 1.2 : Extension de la Matrice de Rôles (RBAC)
**En tant que** Système,
**Je veux** disposer de rôles pédagogiques précis (SuperAdmin, DeptAdmin, RespSAE, RespStage),
**Afin d'** appliquer une gouvernance stricte sur les validations de compétences.

### Contexte Technique
*   **Modèles :** Mise à jour de l'Enum `UserRole` dans `models.py`.
*   **Sécurité :** Mise à jour des dépendances FastAPI (`get_current_user`).

### Critères d'Acceptation
1.  L'Enum `UserRole` contient : `SUPER_ADMIN`, `DEPT_ADMIN`, `RESP_SAE`, `RESP_STAGE`, `PROFESSOR`, `STUDENT`, `GUEST`.
2.  La base de données (PostgreSQL) est mise à jour via une migration (ou reset si en dev).
3.  Le middleware d'authentification backend permet de filtrer par rôle (ex: `@require_role(UserRole.DEPT_ADMIN)`).
4.  L'interface de dispatching permet d'assigner ces nouveaux rôles aux utilisateurs LDAP.

---

## Notes pour les Développeurs
*   **Story 1.0** est bloquante pour le déploiement propre sur le serveur de test.
*   **Story 1.1** peut être développée en parallèle sur le Frontend.
*   **Story 1.2** nécessite une migration DB.
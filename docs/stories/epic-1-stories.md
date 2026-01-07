# User Stories - Epic 1 : Fondation, Infrastructure & Branding

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

## Story 1.3 : Isolation des Données (Multi-Tenant)
**En tant qu'** Administrateur Système,
**Je veux** que chaque instance Docker soit totalement isolée au niveau des données,
**Afin de** garantir la confidentialité entre les différents départements de l'université.

### Contexte Technique
*   **Docker :** Utilisation de fichiers `.env` séparés par instance.
*   **Base de données :** Une base de données (ou un schéma) par instance.

### Critères d'Acceptation
1.  L'application backend utilise la variable `DATABASE_URL` pour se connecter à sa propre base.
2.  Les scripts de seed (`seed_db.py`) sont isolés et n'écrasent pas les données des autres instances.
3.  Les dossiers de stockage temporaires sont isolés.
4.  Vérification que l'instance A ne peut en aucun cas accéder aux fichiers ou utilisateurs de l'instance B.

---

## Notes pour les Développeurs
*   Utiliser les **CSS Variables** pour injecter les couleurs dynamiques dans Mantine.
*   Ne pas stocker les secrets (API Keys Nextcloud) dans le code, mais uniquement dans les variables d'environnement.
*   Documenter les nouvelles variables d'environnement dans le `README.md`.

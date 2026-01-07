# Epic 1 : Fondation, Infrastructure & Branding - Spécifications Détaillées

**Statut :** En cours de définition
**Priorité :** Critique (Bloquant pour le reste du projet)
**Objectif :** Déployer un socle multi-département configurable et sécurisé.

---

## 1. Contexte du Système Existant
Le projet possède déjà un backend FastAPI et un frontend React. L'authentification LDAP est fonctionnelle mais limitée à un rôle unique. Le dispatching existe mais ne gère pas encore la multi-ténacité ni les nouveaux rôles pédagogiques.

## 2. Détails de l'Epic

### Objectifs :
*   Permettre le déploiement de plusieurs instances Docker avec des configurations distinctes.
*   Offrir une interface personnalisable (Logo, Couleurs, Textes) par département.
*   Mettre en place un système de rôles rigoureux (SuperAdmin, DeptAdmin, Prof_SAE, Prof_Stage).

### Critères de Succès :
*   L'application peut être lancée avec un fichier `config.json` ou des variables d'env qui modifient le logo et les couleurs.
*   Un SuperAdmin peut gérer tous les départements ; un DeptAdmin est limité à son instance.
*   La base de données supporte les nouveaux rôles et l'isolation des données.

---

## 3. Liste des User Stories

### Story 1.1 : Configuration Multi-Tenant & Branding
**En tant qu'** Administrateur Système,
**Je veux** configurer l'intégralité des paramètres système (Branding, LDAP, Nextcloud, SMTP, Mattermost) via des variables d'environnement ou un fichier de configuration,
**Afin que** l'instance soit totalement autonome et isolée.
*   **Critères d'Acceptation :**
    1.  Support des variables pour le branding : `APP_LOGO_URL`, `APP_PRIMARY_COLOR`, `APP_WELCOME_MESSAGE`.
    2.  Support des paramètres infra : `LDAP_URL`, `NEXTCLOUD_URL`, `SMTP_HOST`, `MATTERMOST_URL`.
    3.  Le frontend récupère la configuration publique via un endpoint dédié.
    4.  Validation au démarrage du backend de la présence des variables obligatoires.

### Story 1.2 : Matrice de Rôles Étendue (RBAC)
**En tant qu'** Administrateur Départemental,
**Je veux** assigner des rôles spécifiques (Responsable SAE, Responsable Stage),
**Afin de** déléguer les droits de validation finale.
*   **Critères d'Acceptation :**
    1.  Mise à jour du modèle `UserRole` pour inclure : `SUPER_ADMIN`, `DEPT_ADMIN`, `RESP_SAE`, `RESP_STAGE`.
    2.  Middleware de sécurité vérifiant ces rôles pour les actions critiques.

### Story 1.3 : Gestion des Super-Utilisateurs & Isolation
**En tant que** SuperAdmin,
**Je veux** accéder à une vue globale des instances,
**Afin de** superviser les différents départements.
*   **Critères d'Acceptation :**
    1.  Isolation des données par "Tenant ID" (ou par instance Docker séparée).
    2.  Droit de création de comptes `DEPT_ADMIN`.

---

## 4. Risques et Atténuation
*   **Risque :** Complexité de la gestion des styles dynamiques en React.
*   **Atténuation :** Utilisation des variables CSS (CSS Variables) injectées via le thème Mantine.
*   **Risque :** Conflit lors de l'authentification LDAP partagée.
*   **Atténuation :** Configuration LDAP isolable par instance.

---

## 5. Handoff pour les Développeurs
"Veuillez implémenter le socle de configuration dynamique. Priorité à l'injection des couleurs et logos via le backend et à l'extension de l'énumération des rôles dans les modèles SQLModel."

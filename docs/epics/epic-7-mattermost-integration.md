# Epic 7 : Collaborative Ecosystem (Mattermost) - Spécifications Détaillées

**Statut :** En cours de définition
**Priorité :** Moyenne (Valeur ajoutée pédagogique)
**Objectif :** Intégrer une couche de communication temps réel et souveraine.

---

## 1. Contexte Technique
L'application doit s'interfacer avec une instance Mattermost auto-hébergée. L'authentification doit être synchronisée (SSO LDAP commun) pour que l'expérience soit fluide.

## 2. User Stories

### Story 7.1 : Notifications Automatiques
**En tant que** Professeur,
**Je veux** recevoir une notification Mattermost lorsqu'un étudiant dépose une preuve ou une auto-évaluation,
**Afin de** réagir rapidement sans consulter mes emails.
*   **Critères d'Acceptation :**
    1.  Configuration de Webhooks Mattermost par département.
    2.  Message formaté contenant le nom de l'étudiant et le lien direct vers l'évaluation.

### Story 7.2 : Canaux de SAÉ / Groupes de Travail
**En tant qu'** Étudiant membre d'un groupe de projet,
**Je veux** qu'un canal Mattermost privé soit automatiquement créé pour mon groupe,
**Afin de** collaborer exclusivement avec mes partenaires et mon professeur tuteur.
*   **Critères d'Acceptation :**
    1.  Lors de la création d'un "Groupe de Travail" dans l'application, un appel API vers Mattermost crée un canal privé.
    2.  Nommage automatique du canal : `[SAE-CODE]-[NOM-GROUPE]`.
    3.  Ajout automatique des membres du groupe et du professeur responsable au canal.
    4.  Lien direct vers ce canal affiché sur le Dashboard du groupe.

### Story 7.3 : Intégration Nextcloud
**En tant qu'** Utilisateur,
**Je veux** pouvoir partager des fichiers Nextcloud directement dans Mattermost,
**Afin de** centraliser les échanges autour des documents de preuve.
*   **Critères d'Acceptation :**
    1.  Activation du plugin Mattermost pour Nextcloud.
    2.  Configuration guidée dans la documentation d'installation.

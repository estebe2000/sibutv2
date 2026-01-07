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

### Story 7.2 : Canaux de SAÉ / Projets
**En tant qu'** Étudiant,
**Je veux** accéder au canal de discussion Mattermost de ma SAÉ directement depuis l'application,
**Afin de** collaborer avec mes pairs et mes professeurs en contexte.
*   **Critères d'Acceptation :**
    1.  Lien dynamique vers le canal Mattermost sur la fiche SAÉ/Activité.
    2.  Utilisation de l'API Mattermost pour vérifier l'existence du canal ou le créer si nécessaire.

### Story 7.3 : Intégration Nextcloud
**En tant qu'** Utilisateur,
**Je veux** pouvoir partager des fichiers Nextcloud directement dans Mattermost,
**Afin de** centraliser les échanges autour des documents de preuve.
*   **Critères d'Acceptation :**
    1.  Activation du plugin Mattermost pour Nextcloud.
    2.  Configuration guidée dans la documentation d'installation.

# Epic 3 : Portfolio & Nextcloud Integration - Spécifications Détaillées

**Statut :** En cours de définition
**Priorité :** Haute
**Objectif :** Assurer le stockage souverain des preuves sur Nextcloud via un proxy backend.

---

## 1. Contexte Technique
Le backend FastAPI doit agir comme un proxy WebDAV. L'application ne stocke aucun fichier localement (stateless). Chaque étudiant possède un dossier dédié sur le Nextcloud de l'IUT.

## 2. User Stories

### Story 3.1 : Service Proxy WebDAV
**En tant que** Développeur,
**Je veux** un service backend qui encapsule les appels WebDAV vers Nextcloud,
**Afin de** gérer les uploads/downloads de manière sécurisée sans exposer les identifiants de service au frontend.
*   **Critères d'Acceptation :**
    1.  Implémentation d'un client WebDAV (ex: `webdav4`) dans `apps/api/app/services/nextcloud_service.py`.
    2.  Support des opérations : `upload`, `download`, `delete`, `mkdir`.
    3.  Gestion des erreurs (quota plein, timeout) avec retours explicites.

### Story 3.2 : Galerie de Preuves Étudiant
**En tant qu'** Étudiant,
**Je veux** voir la liste de mes fichiers déjà uploadés dans une galerie,
**Afin de** pouvoir les associer à plusieurs compétences si nécessaire.
*   **Critères d'Acceptation :**
    1.  Interface en grille (Grid View) affichant les fichiers présents dans le dossier Nextcloud de l'étudiant.
    2.  Affichage du type de fichier (PDF, Image, Vidéo) avec icônes.
    3.  Action "Supprimer" qui supprime réellement le fichier sur Nextcloud.

### Story 3.3 : Upload Mobile-First & Association
**En tant qu'** Étudiant,
**Je veux** uploader une preuve directement depuis mon téléphone et l'associer à une SAE,
**Afin de** documenter mon apprentissage sur le terrain.
*   **Critères d'Acceptation :**
    1.  Composant `FileUploader` avec barre de progression réelle.
    2.  Lien automatique en base de données entre le `FileID` Nextcloud et la `StudentEvaluation`.
    3.  Validation du type de fichier et de la taille (max 50 Mo).

---

## 3. Sécurité et Performance
*   **Chunked Upload** : Recommandé pour les vidéos de plus de 20 Mo.
*   **Stateless** : Le serveur ne doit jamais écrire le fichier sur son propre disque (utilisation de streams).

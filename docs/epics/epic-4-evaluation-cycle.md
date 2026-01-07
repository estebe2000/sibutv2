# Epic 4 : Le Cycle d'Évaluation (Magic Links & Sliders) - Spécifications Détaillées

**Statut :** En cours de définition
**Priorité :** Critique (Cœur de métier)
**Objectif :** Digitaliser la boucle de feedback entre l'étudiant, le tuteur et le professeur.

---

## 1. Contexte Métier
Le système doit être "Zéro Friction" pour le tuteur externe. Il ne doit pas avoir à créer de compte.

## 2. User Stories

### Story 4.1 : Auto-Évaluation et Soumission
**En tant qu'** Étudiant,
**Je veux** rédiger mon texte réflexif et choisir mon niveau d'acquisition auto-évalué,
**Afin de** déclencher la demande d'évaluation auprès de mon tuteur.
*   **Critères d'Acceptation :**
    1.  Formulaire simple : Commentaire + Radio Button (Non acquis, En cours, Acquis).
    2.  Le bouton "Soumettre" verrouille l'édition des preuves pour cette compétence.
    3.  Envoi automatique d'une notification email au tuteur.

### Story 4.2 : Génération et Sécurité des Magic Links
**En tant que** Système,
**Je veux** générer un lien unique, temporaire et sécurisé pour chaque demande d'évaluation,
**Afin de** permettre au tuteur d'accéder au formulaire sans login.
*   **Critères d'Acceptation :**
    1.  Token cryptographique (UUID ou JWT) stocké en base avec date d'expiration (+7 jours).
    2.  Route publique `/evaluation/external/{token}`.
    3.  Invalidation du lien dès que le tuteur a soumis son feedback.

### Story 4.3 : Formulaire Tuteur Ultra-Simplifié
**En tant que** Tuteur Externe,
**Je veux** voir la preuve déposée par l'étudiant et laisser un avis qualitatif rapide,
**Afin d'** évaluer l'étudiant en moins d'une minute.
*   **Critères d'Acceptation :**
    1.  Affichage du nom de l'étudiant, de sa réflexion et d'un bouton pour ouvrir le fichier (PDF/Vidéo).
    2.  Champ texte "Commentaire du tuteur" + Avis simple (Positif / À améliorer).
    3.  Interface optimisée pour mobile (consultation sur le lieu de stage).

### Story 4.4 : Validation Finale (Le Slider Professeur)
**En tant que** Professeur Responsable,
**Je veux** consulter les avis (étudiant + tuteur) et fixer la note finale via un slider,
**Afin de** valider officiellement la compétence.
*   **Critères d'Acceptation :**
    1.  Tableau de bord "À valider" regroupant les demandes complétées.
    2.  Slider 0 à 100% avec retour visuel immédiat.
    3.  Enregistrement définitif en base de données avec date et signature du prof.

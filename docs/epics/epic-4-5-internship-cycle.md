# Epic 4.5 : Suivi Complet des Stages et Évaluations de Terrain - Spécifications Démo

**Statut :** Prêt pour implémentation
**Priorité :** Critique (Cœur de la démonstration)
**Objectif :** Boucler le cycle de stage par l'assignation de tuteurs, l'organisation de visites et la collecte des évaluations tripartites (Étudiant, Maître de Stage, Enseignant).

---

## 1. Contexte du Système Existant
Le système possède déjà une gestion de fiches de stage et une table `ResponsibilityMatrix`. Le constructeur de grilles d'évaluation est fonctionnel côté administrateur. L'envoi d'emails est configuré.

## 2. Détails de l'Epic

### Objectif :
Permettre à un Directeur d'Études de définir une grille de stage, aux enseignants de suivre leurs stagiaires (RDV, visites) et aux maîtres de stage d'évaluer via un lien sécurisé.

### Critères de Succès :
*   Un enseignant peut être assigné comme "Tuteur" à un étudiant.
*   Le tuteur peut saisir des comptes-rendus de visite (date, lieu, commentaire).
*   Le maître de stage reçoit un Magic Link par email et remplit une grille simplifiée (curseurs %).
*   L'évaluation finale agrège les 3 avis (Auto, Pro, Académique).

---

## 3. Liste des User Stories

### Story 4.5.1 : Assignation et Gestion des Visites de Stage
**En tant qu'** Enseignant Tuteur,
**Je veux** programmer mes rendez-vous de suivi et saisir mes rapports de visite,
**Afin de** tracer l'accompagnement pédagogique de l'étudiant.
*   **Critères d'Acceptation :**
    1.  Nouvelle table `InternshipVisit` (date, type: SITE/PHONE/VISIO, commentaire).
    2.  Interface de gestion des visites sur le `ProfessorDashboard`.
    3.  Affichage des coordonnées du Maître de Stage (extraites de la fiche de stage).

### Story 4.5.2 : Magic Links et Évaluation du Maître de Stage
**En tant que** Maître de Stage (externe),
**Je veux** évaluer l'étudiant via un formulaire sans création de compte,
**Afin de** valider ses compétences en situation professionnelle.
*   **Critères d'Acceptation :**
    1.  Route publique `/evaluation/external/{token}` sécurisée par UUID.
    2.  Formulaire affichant les AC (Apprentissages Critiques) avec sliders 0-100%.
    3.  Zone de commentaire global et boutons de validation.
    4.  Notification email automatique lors de la soumission.

### Story 4.5.3 : Synthèse Tripartite et Dashboard Tuteur
**En tant qu'** Enseignant Tuteur,
**Je veux** comparer les trois évaluations (Étudiant, Pro, Ma tienne) sur une interface unique,
**Afin de** finaliser la note de stage.
*   **Critères d'Acceptation :**
    1.  Vue comparative avec 3 curseurs par critère (couleurs distinctes : Bleu=Élève, Orange=Pro, Vert=Prof).
    2.  Calcul automatique d'une moyenne suggérée.
    3.  Bouton "Publier l'évaluation finale" qui verrouille le cycle de stage.

---

## 4. Handoff Technique
*   **Backend** : Ajouter `InternshipVisit` à `models.py`. Créer `routers/public_eval.py`.
*   **Frontend** : Créer `InternshipManagementView.tsx` pour les tuteurs.
*   **Sécurité** : Les tokens de Magic Link doivent expirer après 15 jours.

---

## 5. Risques et Atténuation
*   **Risque** : Email du Maître de Stage erroné.
*   **Atténuation** : Validation du format email en JS et test d'envoi immédiat avec feedback visuel.

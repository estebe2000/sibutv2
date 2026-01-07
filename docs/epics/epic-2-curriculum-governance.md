# Epic 2 : Curriculum & Advanced Governance - Spécifications Détaillées

**Statut :** En cours de définition
**Priorité :** Haute (Nécessaire pour l'intégrité des évaluations)
**Objectif :** Structurer le référentiel et assigner les responsabilités décisionnelles.

---

## 1. Contexte du Système Existant
Le référentiel (Compétences, SAE, Ressources) est déjà modélisé dans `models.py`. Cependant, il manque la notion de "Propriété" (Ownership). Actuellement, n'importe quel professeur authentifié pourrait théoriquement valider n'importe quelle compétence, ce qui pose un risque majeur pour l'intégrité académique.

## 2. Détails de l'Epic

### Objectifs :
*   Assigner un **Responsable principal** (Owner) à chaque SAÉ, Stage ou Ressource.
*   Assigner des **Intervenants** (Participants) qui peuvent consulter et annoter, mais pas valider.
*   Garantir que la validation finale (le slider 0-100%) n'est accessible qu'au responsable désigné ou à l'administrateur.

### Critères de Succès :
*   L'interface "Référentiel" permet de choisir un professeur dans une liste pour l'assigner à une SAÉ.
*   Un professeur voit sur son tableau de bord uniquement les éléments dont il est responsable.
*   Le backend rejette toute tentative de validation émanant d'un professeur non responsable de l'élément concerné.

---

## 3. Liste des User Stories

### Story 2.1 : Matrice de Responsabilité (Assignation)
**En tant qu'** Administrateur Départemental,
**Je veux** assigner un professeur responsable pour chaque SAÉ et chaque Stage du référentiel,
**Afin que** les étudiants sachent qui va les évaluer et que le système sache qui a le droit de valider.
*   **Critères d'Acceptation :**
    1.  Nouvelle table/relation `ResponsibilityMatrix` liant `User` et `Activity` (SAE/Stage).
    2.  Interface d'assignation simple (Select searchable) dans l'éditeur de référentiel.
    3.  Support de plusieurs "Intervenants" mais d'un seul "Responsable validateur".

### Story 2.2 : Filtres de Dashboard Professeur
**En tant que** Professeur,
**Je veux** voir uniquement les étudiants et les compétences qui me sont assignés,
**Afin de** me concentrer sur mon périmètre pédagogique.
*   **Critères d'Acceptation :**
    1.  Le endpoint `GET /api/prof/tasks` filtre les résultats en fonction de la matrice de responsabilité.
    2.  Indicateur visuel "Responsable" vs "Intervenant" sur les fiches de compétences.

### Story 2.3 : Verrouillage des Validations Finales
**En tant que** Système,
**Je veux** bloquer l'accès au slider de validation finale aux utilisateurs non autorisés,
**Afin d'** éviter les validations accidentelles ou non légitimes.
*   **Critères d'Acceptation :**
    1.  Le slider de validation est grisé ou masqué pour les professeurs "intervenants".
    2.  Vérification côté serveur (FastAPI) de l'identité du validateur par rapport à la matrice de responsabilité avant d'enregistrer la note.

---

## Story 2.7 : Workgroup Builder (SAÉ & Projets)
**En tant que** Professeur Responsable,
**Je veux** organiser les étudiants en groupes de travail pour une SAÉ spécifique,
**Afin de** permettre une évaluation et une collaboration collective.
*   **Critères d'Acceptation :**
    1.  Interface de sélection multiple pour regrouper des étudiants.
    2.  Possibilité de nommer le groupe (ex: "Groupe A - Agence Marketing").
    3.  Une preuve déposée par un membre est automatiquement visible et associée à tous les membres du groupe.
    4.  Déclenchement de la création du canal Mattermost (lié à l'Epic 7).
*   **Risque :** Absence de responsable (vacance de poste).
*   **Atténuation :** Les Administrateurs Départementaux gardent un droit de validation "Master" par défaut.
*   **Risque :** Complexité de gestion si un professeur a 50 SAÉs.
*   **Atténuation :** Mise en place de filtres et de recherche rapide sur le Dashboard Prof.

---

## 5. Handoff pour les Développeurs
"Cette Epic nécessite une modification de la base de données pour ajouter les liens de responsabilité. Il faudra également mettre à jour les politiques de sécurité (Scopes/Permissions) sur les endpoints de validation."

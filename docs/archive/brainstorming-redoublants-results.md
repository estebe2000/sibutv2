# Synthèse Brainstorming : Workflow "Redoublants & Capitalisation"

**Date :** Mercredi 7 Janvier 2026
**Participants :** Mary (BA) & Porteur de projet
**Cible :** Product Manager (John) & Architecte

---

## 1. Vision Globale
La gestion des redoublants repose sur un processus **humain et pédagogique**. L'application sert de support à l'entretien de rentrée entre l'étudiant et son professeur référent pour acter les décisions de "Capitalisation" (conservation des acquis).

## 2. Règles Métier Clés
*   **Seuil de Capitalisation** : Une compétence peut être capitalisée si la note obtenue est **> 10/20**.
*   **Droit à la Ré-évaluation** : L'étudiant a le droit de demander une ré-évaluation même s'il a > 10, afin d'améliorer sa note.
*   **Pouvoirs du Référent (Option A)** : Lors de l'entretien, le professeur référent dispose des droits d'édition sur l'ensemble du parcours de l'étudiant pour l'année en cours, quel que soit le responsable de la SAÉ/Stage.

## 3. Workflow Opérationnel
1.  **Affichage Historique** : Le Dashboard affiche les 3 années du BUT. En cas de redoublement, les tentatives successives sont listées (ex: BUT2 2024-2025 et BUT2 2025-2026).
2.  **Entretien de Rentrée** : Rencontre physique entre l'étudiant et le référent.
3.  **Saisie des Décisions** : Via une interface dédiée ("Mode Entretien"), le référent bascule chaque compétence :
    *   **Statut : CAPITALISÉ** -> La note N-1 est verrouillée et reportée. L'étudiant ne peut pas uploader de nouvelles preuves pour cette année.
    *   **Statut : NOUVELLE TENTATIVE** -> Une instance d'évaluation vide est créée pour l'année en cours. L'étudiant doit fournir de nouvelles preuves.
4.  **Consultation** : L'étudiant voit immédiatement le résultat des décisions sur son Dashboard (indicateur "Capitalisé" ou "À faire").

## 4. Impacts Techniques (Pour l'Architecte)
*   **Schéma de Données** : La table `StudentEvaluation` doit être liée à une `AcademicYear` pour distinguer les tentatives.
*   **Droits (RBAC)** : Créer un scope de permission temporaire ou spécifique pour le rôle "Professeur Référent" sur ses étudiants assignés.
*   **Reporting** : Les rapports doivent savoir agréger la "meilleure note" ou la "note capitalisée" pour le calcul des moyennes finales.

---

## 5. Prochaines Étapes
1.  **John (PM)** : Créer une User Story "Interface Entretien Référent".
2.  **Winston (Architecte)** : Adapter le modèle `StudentEvaluation` pour supporter les années académiques multiples.

# Story: Hub Recherche de Stage & Suivi Candidatures (Kanban)

**Status:** Ready for Review
**Type:** Feature

## Contexte
Aider les étudiants à structurer leur recherche de stage en leur fournissant un outil de suivi (CRM type Kanban) et des ressources pour améliorer leurs candidatures. Préparer le terrain pour l'intégration d'IA et d'agrégateurs d'offres.

## User Stories
1. **En tant qu'étudiant**, je veux un tableau de bord **Kanban** pour suivre mes candidatures de manière visuelle (glisser-déposer entre colonnes).
2. **En tant qu'étudiant**, je veux pouvoir noter mes refus pour garder une trace de mes efforts.
3. **En tant qu'étudiant**, je veux une section "Coaching" avec des conseils et un assistant IA (placeholder).

## Acceptance Criteria
- [ ] Une nouvelle entrée "Recherche Stage" dans le menu latéral étudiant.
- [ ] Une vue avec 3 onglets (Mes Candidatures, Recherche, Coaching).
- [ ] L'onglet "Mes Candidatures" affiche un **Tableau Kanban** fonctionnel.
- [ ] Persistance des données en base (Table `InternshipApplication`).

## Technical Tasks

### 1. Backend: Modèle et API
- [ ] Ajouter `InternshipApplication` dans `models.py`.
- [ ] Créer `routers/applications.py`.

### 2. Frontend: Kanban et UI
- [ ] Implémenter une version simplifiée de Kanban (Mantine + DND si disponible, ou simple liste colonnée).
- [ ] Créer les composants `ApplicationTracker.tsx` (Kanban), `InternshipSearchView.tsx` (Moteur placeholder), `CoachingPanel.tsx` (Conseils).

## Dev Agent Record
...
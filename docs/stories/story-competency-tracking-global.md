# Story: Suivi Global des Compétences (Karutisation)

**Status:** Draft
**Type:** Feature / Architectural Evolution

## Contexte
Faire évoluer le Hub pour permettre un suivi exhaustif du référentiel de compétences (BUT TC), inspiré de la rigueur de Karuta, mais avec l'ergonomie actuelle. L'objectif est que l'étudiant puisse visualiser sa progression sur chaque Apprentissage Critique (AC) tout au long de son cursus.

## User Stories
1. **En tant qu'étudiant**, je veux voir l'arborescence complète de mes compétences (C1, C2...) et des AC associés dans mon "Parcours Scolaire".
2. **En tant qu'étudiant**, je veux pouvoir attacher une preuve (document, lien Odoo) directement à un AC spécifique, et non plus seulement à une SAÉ.
3. **En tant qu'enseignant**, je veux valider le niveau d'acquisition d'un AC pour un étudiant après avoir consulté ses preuves.
4. **En tant qu'étudiant**, je veux voir une jauge de progression (0-100%) pour chaque compétence majeure.

## Acceptance Criteria
- [ ] La vue `AcademicPathView` affiche une arborescence interactive (Competency -> LearningOutcome).
- [ ] Chaque `LearningOutcome` affiche son statut (Non commencé, En cours, Acquis).
- [ ] Possibilité de cliquer sur un AC pour ouvrir un "tiroir" permettant de déposer/voir les preuves liées.
- [ ] Un script de calcul automatique met à jour le score global de la compétence en fonction des AC validés.

## Technical Tasks

### 1. Backend: Évolution du Modèle
- [ ] Créer `CompetencyValidation` dans `models.py` pour stocker le score/statut d'un étudiant sur un AC.
- [ ] Créer une table de liaison `EvidenceACLink` pour lier les `StudentFile` aux `LearningOutcome`.

### 2. Backend: API
- [ ] Endpoint `GET /competencies/my-progress` : retourne l'arborescence avec les scores de l'étudiant connecté.
- [ ] Endpoint `POST /competencies/link-evidence` : lie un fichier existant à un AC.

### 3. Frontend: Dashboard de Compétences
- [ ] Remplacer le placeholder de `AcademicPathView.tsx` par un composant `CompetencyTree`.
- [ ] Utiliser des indicateurs visuels (RingProgress ou Progress bars Mantine) pour les niveaux d'acquisition.
- [ ] Intégrer la gestion des preuves dans cette vue.

## Dev Agent Record
### Debug Log
- (Empty)

### Completion Notes
- (Empty)

### File List
- apps/api/app/models.py
- apps/api/app/routers/curriculum.py
- apps/web/src/views/AcademicPathView.tsx
- apps/web/src/components/CompetencyTree.tsx (nouveau)

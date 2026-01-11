# Architecture Cible Frontend : Modularité & UX

**Version :** 2.0 (Target)
**Date :** 11 Janvier 2026
**Statut :** Spécification Technique

## 1. Vue d'Ensemble

L'objectif est de refondre le frontend actuel (monolithique) vers une architecture modulaire, testable et performante, capable de supporter les fonctionnalités riches (Radar Charts, Drag & Drop, Édition collaborative).

### Principes Clés
*   **Atomic Design :** Composants réutilisables (Atoms -> Molecules -> Organisms -> Templates).
*   **Séparation des responsabilités :** UI (Composants) vs Logique (Hooks) vs Données (Store).
*   **Performance :** Code splitting et Lazy loading par route.

---

## 2. Structure des Dossiers Cible

```text
apps/web/src/
├── components/          # Composants UI partagés (stateless)
│   ├── atoms/           # Boutons, Inputs, Badges
│   ├── molecules/       # Cartes, Formulaires simples
│   └── organisms/       # Header, Sidebar, Grilles complexes
├── features/            # Modules fonctionnels (Domain Driven)
│   ├── competencies/    # Gestion du référentiel
│   │   ├── components/  # Composants spécifiques (Editor, List)
│   │   ├── hooks/       # Logique métier (useCompetency.ts)
│   │   └── types.ts     # Types TS
│   ├── dashboard/       # Vue d'accueil
│   ├── evaluation/      # Cycle d'évaluation (Sliders, Forms)
│   └── analytics/       # Radar Charts & Reports
├── store/               # Gestion d'état global (Zustand)
│   ├── useAuthStore.ts
│   └── useUIStore.ts
├── services/            # Couche API
│   ├── api.ts           # Instance Axios configurée
│   └── auth.ts          # Services d'authentification
├── layouts/             # Gabarits de page (Main, Auth, Print)
└── routes/              # Définition des routes
```

---

## 3. Stratégie de Refactoring (Priorité : CompetencyEditor)

Le fichier `CompetencyEditor.tsx` (actuellement >600 lignes) sera découpé en :

1.  **`CompetencyTree.tsx` (Organism) :** Affichage de l'arbre des compétences (Drag & Drop).
2.  **`CompetencyDetail.tsx` (Organism) :** Formulaire d'édition d'une compétence sélectionnée.
3.  **`ResourceLinker.tsx` (Molecule) :** Gestion des liens vers les ressources/SAE.
4.  **`useCompetencies.ts` (Hook) :**
    *   Gestion du fetch API (`react-query` recommandé).
    *   Gestion des mutations (Create, Update, Delete).
    *   Logique de filtrage local.

### Exemple de Hook (Pseudo-code)
```typescript
export const useCompetencies = () => {
  const query = useQuery({ queryKey: ['competencies'], queryFn: api.getCompetencies });
  const updateMutation = useMutation({ mutationFn: api.updateCompetency });
  
  return {
    competencies: query.data,
    isLoading: query.isLoading,
    update: updateMutation.mutate
  };
};
```

---

## 4. Gestion de l'État (State Management)

Nous utiliserons **Zustand** pour l'état global léger et **TanStack Query (React Query)** pour l'état serveur (cache API).

*   **Zustand :**
    *   `user` (Session actuelle, Rôles).
    *   `theme` (Préférences UI, Mode Sombre).
    *   `notifications` (Toast messages).
*   **React Query :**
    *   Cache des données compétences (évite le re-fetching incessant).
    *   Gestion automatique des états de chargement (`isLoading`, `isError`).

---

## 5. Nouveaux Composants UX

### 5.1 Radar Chart (Analytics)
Intégration de la librairie **Recharts** (ou Nivo) pour visualiser les 5 axes de compétences.
*   Composant : `StudentProgressRadar.tsx`
*   Props : `data: { skill: string, value: number }[]`

### 5.2 Magic Link Landing (Tuteurs)
Une nouvelle route publique (`/external/evaluation/:token`) avec un layout simplifié (pas de Sidebar, pas de Header complexe).
*   Optimisé pour mobile.
*   Formulaire "One-Thumb" (facile à utiliser à une main).

---

## 6. Intégration API & Configuration

L'URL de l'API ne sera plus devinée (`window.location...`) mais injectée via `.env` :
```typescript
const API_URL = import.meta.env.VITE_API_URL || '/api';
```
En production (derrière la Gateway), ce sera simplement `/api` (relatif), ce qui résout les problèmes CORS.

---

## 7. Plan de Migration

1.  **Setup :** Mettre en place la nouvelle structure de dossiers.
2.  **Extraction :** Déplacer les composants UI génériques de `CompetencyEditor` vers `components/`.
3.  **Logique :** Extraire la logique API vers `hooks/useCompetencies.ts`.
4.  **Assemblage :** Réécrire `CompetencyEditor` en utilisant les nouveaux hooks et composants.
5.  **Extension :** Ajouter les nouveaux modules (Analytics, Evaluation).

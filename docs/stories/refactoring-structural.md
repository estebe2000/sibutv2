# User Story : Refactorisation Structurelle (Fondations)

**ID :** Story 0.1
**Statut :** À faire
**Priorité :** Critique (Fondation technique)

## 1. Description
**En tant que** Développeur,
**Je veux** découper le monolithe frontend (`App.tsx`) et modulariser le backend,
**Afin de** rendre le code maintenable, testable et prêt pour les futures évolutions (Gouvernance, Nextcloud).

## 2. Critères d'Acceptation
### Frontend
1.  **Découpage de `App.tsx`** : Le fichier principal doit faire moins de 200 lignes. Les logiques de vues doivent être déplacées dans `src/views/` et les composants génériques dans `src/components/`.
2.  **Centralisation API** : Création d'un service Axios configuré dans `src/services/api.ts` pour gérer les en-têtes et les URLs de base.
3.  **Gestion d'État** : Utilisation rigoureuse du store Zustand existant pour l'authentification et les données globales.

### Backend
4.  **Organisation par couches** : Séparation claire entre les routeurs (FastAPI) et la logique métier (Services).
5.  **Nettoyage** : Suppression des fichiers de debug et des scripts temporaires obsolètes.

## 3. Tâches
- [x] Créer la structure de dossiers cible sur le Frontend (Atoms, Molecules, Organisms, Services).
- [x] Extraire la logique de Dispatching dans `src/views/DispatcherView.tsx`.
- [x] Extraire les utilitaires Axios dans `src/services/api.ts`.
- [x] Créer une couche `services/` dans le Backend pour isoler la logique Keycloak et LDAP.
- [x] Vérifier que l'application fonctionne toujours parfaitement après le découpage.

## 4. Dev Agent Record
- **Agent Model Used:** Gemini 2.0 Flash
- **Status:** Ready for Review
- **Debug Log:** 
    - Corrigé ModuleNotFoundError dans pdf_service.py suite au déplacement (imports relatifs ..models).
    - Stabilisé le cycle de rendu dans DispatcherView pour éviter les boucles infinies de fetch.
- **Completion Notes:**
    - Frontend découpé : App.tsx réduit, DispatcherView.tsx créé.
    - Axios centralisé dans services/api.ts avec injection automatique du token.
    - Backend modularisé : keycloak, ldap et pdf déplacés dans app/services/.
    - Build et déploiement validés sur Docker.
- **File List:** 
    - apps/web/src/views/DispatcherView.tsx (Nouveau)
    - apps/web/src/services/api.ts (Nouveau)
    - apps/api/app/services/ (Nouveau dossier)
    - apps/web/src/App.tsx (Modifié)
    - apps/api/app/main.py (Modifié)
    - apps/api/app/routers/ (Modifiés)
- **Change Log:**
    - 2026-01-12: Création de la structure de dossiers modulaire frontend.
    - 2026-01-12: Extraction de la logique Dispatcher et centralisation Axios.
    - 2026-01-12: Modularisation du Backend (couche services).

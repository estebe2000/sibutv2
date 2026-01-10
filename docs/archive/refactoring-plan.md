# Plan de Refactorisation Stratégique - Skills Hub

**Date :** Mercredi 7 Janvier 2026
**Auteur :** Mary (Business Analyst)
**Statut :** Recommandation technique pour le Product Manager

---

## 1. État des Lieux et Problématique
Le projet actuel a atteint une "masse critique" où la logique métier, la gestion de l'état UI et les appels API sont trop étroitement liés.
*   **Frontend :** `App.tsx` fait plus de 800 lignes, gérant l'auth, le drag & drop, l'édition de référentiel et la configuration.
*   **Backend :** `main.py` contient l'intégralité des routes, mélangeant l'administration LDAP, le parsing PDF et la gestion Docker.

## 2. Refactorisation Frontend (React + Mantine)

### 2.1 Découpage des Composants (Atomic Design)
Il est impératif d'extraire la logique de `App.tsx` vers une structure modulaire dans `apps/web/src/` :

1.  **`src/layouts/MainLayout.tsx`** : Contient l' `AppShell`, le Header et la Navbar.
2.  **`src/features/dispatcher/`** :
    *   `DispatcherPage.tsx` : Vue principale du dispatching.
    *   `LDAPList.tsx` : Composant de la liste de gauche.
    *   `GroupCard.tsx` : Composant pour chaque carte de groupe (droite).
3.  **`src/features/curriculum/`** :
    *   `CurriculumPage.tsx` : Gestion du référentiel.
    *   `CompetencyAccordion.tsx` : Logique d'affichage des compétences/AC/CE.
    *   `ActivityCard.tsx` : Affichage des SAE/Stages.
4.  **`src/features/settings/`** :
    *   `SettingsPage.tsx` : Configuration système.

### 2.2 Gestion de l'État et Appels API
*   **Custom Hooks (`src/hooks/`)** : Créer des hooks comme `useLdapUsers()`, `useGroups()`, `useCurriculum()` pour encapsuler les appels Axios.
*   **API Client** : Centraliser la configuration Axios dans `src/api/client.ts`.

## 3. Refactorisation Backend (FastAPI)

### 3.1 Modularisation par Routers
Utiliser `APIRouter` pour diviser `main.py` en fichiers spécialisés dans `apps/api/app/routers/` :

*   **`auth.py`** : Login, JWT, Magic Links.
*   **`admin.py`** : Dispatching, gestion des groupes, quotas Nextcloud.
*   **`curriculum.py`** : CRUD du référentiel et export.
*   **`import_export.py`** : Logique d'import Excel et parsing PDF (AI).

### 3.2 Couche de Services (`apps/api/app/services/`)
Extraire la logique métier des routes pour la rendre testable :
*   **`NextcloudService`** : Encapsuler les appels WebDAV et les commandes Docker OCC.
*   **`LDAPService`** : Logique de recherche et vérification LDAP.
*   **`ParsingService`** : Logique de traitement des fichiers PDF/Excel.

## 4. Bénéfices Attendus
1.  **Maintenabilité** : Les bugs seront localisés dans des petits fichiers plutôt que dans un fichier géant.
2.  **Parallélisme** : Plusieurs développeurs pourront travailler sur des modules différents sans conflits Git.
3.  **Testabilité** : Possibilité d'ajouter des tests unitaires sur les `services` backend et les `hooks` frontend.

---

## 5. Prochaines Étapes Techniques (Sprint de Transition)
1.  Initialiser la structure de dossiers sur le Backend et déplacer les routes.
2.  Extraire `CompetencyEditor` vers son propre fichier (le plus gros gain immédiat).
3.  Mettre en place un système de types partagés entre le Backend (Pydantic) et le Frontend (TypeScript).

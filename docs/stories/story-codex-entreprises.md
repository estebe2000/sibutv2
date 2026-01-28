# Story: Codex des Entreprises et Autocomplétion Stages

**Status:** Draft
**Type:** Feature / Refactor

## Contexte
Actuellement, les données des entreprises sont dupliquées dans chaque fiche de stage (`Internship` model). Nous souhaitons centraliser ces informations dans un "Codex" (référentiel unique) pour :
1. Faciliter la saisie des étudiants via l'autocomplétion.
2. Permettre aux administrateurs/enseignants de gérer un annuaire (mise à jour coordonnées, désactivation si l'entreprise ne prend plus de stagiaires).
3. Historiser le nombre d'étudiants reçus par entreprise.

## User Stories
1. **En tant qu'étudiant**, je veux taper le nom de mon entreprise d'accueil et voir des suggestions, afin de ne pas avoir à ressaisir adresse et contact si l'entreprise est déjà connue.
2. **En tant qu'étudiant**, si l'entreprise est nouvelle, je veux pouvoir saisir ses informations pour qu'elle soit ajoutée au Codex.
3. **En tant qu'enseignant/admin**, je veux accéder à la liste des entreprises (Codex) pour voir les coordonnées et le nombre de stagiaires accueillis.
4. **En tant qu'admin**, je veux pouvoir décocher "Accepte des stagiaires" pour une entreprise, afin qu'elle n'apparaisse plus en suggestion prioritaire ou soit signalée.

## Acceptance Criteria
- [ ] Une table `Company` existe en base de données.
- [ ] Les données existantes des stages sont migrées vers cette table (dédoublonnage sur le nom).
- [ ] Le formulaire de stage propose une autocomplétion sur le champ "Entreprise".
- [ ] Si l'utilisateur modifie l'adresse d'une entreprise existante, cela met à jour le Codex (ou propose le choix).
- [ ] Une nouvelle vue "Codex Entreprises" est accessible dans le menu Admin.
- [ ] Cette vue permet de filtrer par nom et de voir le compteur de stages.

## Technical Tasks

### 1. Backend: Modèles et Migration
- [ ] Créer le modèle `Company` dans `apps/api/app/models.py` :
    - `id`, `name` (index/unique?), `address`, `phone`, `email`, `website`.
    - `accepts_interns` (bool, default true).
    - `visible_to_students` (bool, default true).
- [ ] Modifier `Internship` pour ajouter `company_id` (ForeignKey) tout en gardant les champs texte pour l'historique ou "snapshot" (optionnel, ou on remplace totalement).
    - *Décision*: On garde les champs dans `Internship` comme "cache" ou on lie ? -> Pour ce sprint, on lie. Si l'étudiant modifie, ça update le Codex.
- [ ] Créer un script de migration (ou endpoint one-shot) pour extraire les `company_name` distincts actuels et peupler `Company`.

### 2. Backend: API
- [ ] Créer `apps/api/app/routers/companies.py`.
- [ ] Endpoint `GET /companies?search=...` (retourne id, nom, adresse...).
- [ ] Endpoint `POST /companies` (création).
- [ ] Endpoint `PATCH /companies/{id}` (mise à jour).
- [ ] Endpoint `GET /companies/{id}/stats` (nombre de stagiaires).

### 3. Frontend: Vue Admin (Codex)
- [ ] Créer `apps/web/src/views/CompanyCodexView.tsx`.
- [ ] Table avec : Nom, Ville, Contact, Switch "Accepte stagiaires", Compteur stagiaires.
- [ ] Modal d'édition des détails.
- [ ] Ajouter l'entrée dans le menu de gauche (conditionnel : Admin/Prof).

### 4. Frontend: Formulaire Étudiant (Refonte)
- [ ] Modifier `apps/web/src/components/InternshipForm.tsx`.
- [ ] Remplacer `TextInput` pour le nom par un `Autocomplete` (Mantine) ou `Select` avec recherche.
- [ ] Logique :
    - Si sélection existante -> Populate les champs Adresse/Tel/Email.
    - Si modif des champs pré-remplis -> Avertir que cela mettra à jour le référentiel OU créer une nouvelle entrée ? (Simplification : Update le référentiel).

## Dev Agent Record
### Debug Log
- (Empty)

### Completion Notes
- (Empty)

### File List
- apps/api/app/models.py
- apps/api/app/routers/companies.py
- apps/api/app/main.py
- apps/web/src/views/CompanyCodexView.tsx
- apps/web/src/components/InternshipForm.tsx
- apps/web/src/App.tsx

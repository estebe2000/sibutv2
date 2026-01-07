# Epic 6 : Multi-Tenant Expansion (PDF Import) - Spécifications Détaillées

**Statut :** En cours de définition
**Priorité :** Basse (Nécessaire pour l'échelle)
**Objectif :** Automatiser la création de référentiels à partir des documents officiels.

---

## 1. Contexte Technique
Le script `ai_parser.py` existe déjà en partie. Il faut l'intégrer dans une interface utilisateur sécurisée pour les administrateurs.

## 2. User Stories

### Story 6.1 : Assistant d'Importation PDF
**En tant qu'** Administrateur,
**Je veux** téléverser le "Programme National" (PDF) de mon département,
**Afin que** le système en extraise automatiquement l'arbre des compétences.
*   **Critères d'Acceptation :**
    1.  Zone de drag & drop pour fichier PDF.
    2.  Traitement asynchrone (avec loader) pour l'extraction de texte.
    3.  Génération d'un modèle de données préliminaire (JSON).

### Story 6.2 : Validation de l'Extraction
**En tant qu'** Administrateur,
**Je veux** réviser et corriger les données extraites par l'IA avant leur injection en base,
**Afin de** garantir l'exactitude du référentiel pédagogique.
*   **Critères d'Acceptation :**
    1.  Interface d'édition en liste des éléments extraits (Code, Libellé, Description).
    2.  Bouton "Confirmer et Injecter" qui crée les entrées `Competency`, `LearningOutcome` et `EssentialComponent` en base.
    3.  Journal d'import pour tracer les erreurs éventuelles.

---

## 3. Note sur l'IA
*   Utiliser des prompts spécialisés pour identifier les motifs "Compétence X", "SAE X.01", "AC X.XX" dans le texte extrait.

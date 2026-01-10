# Prompt pour l'Extraction du Référentiel BUT TC

Tu es un expert en ingénierie pédagogique et en structuration de données JSON. Ta mission est d'extraire les informations du "Programme National BUT Techniques de Commercialisation" (PDF) et de les convertir en un fichier JSON strict.

## 1. Règles Structurelles Fondamentales

### A. Compétences (C1-C5)
- **C1, C2, C3 (Tronc Commun)** : Existent en BUT 1, 2, 3.
- **C4, C5 (Parcours)** : Existent **uniquement en BUT 2 et BUT 3**.
- **Codes** : `C[X]-[PARCOURS]-BUT[N]` (ex: `C4-SME-BUT2`).
- **Niveaux** : 
  - BUT 1 = AC1X.XX
  - BUT 2 = AC2X.XX
  - BUT 3 = AC3X.XX

### B. Activités (SAÉ et STAGES)
- **Types** :
  - **SAÉ** : Chercher le motif `SAÉ X.XX : [Titre]`
  - **STAGE** : Chercher le motif `STAGE : [Titre]` ou `Stage [S2/S4/S6]`
  - **PORTFOLIO** : Chercher le motif `PORTFOLIO : [Titre]`
- **Champs requis** :
  - `code` : "SAE 1.01", "STAGE S2", "PORTFOLIO S1"
  - `nom` : Titre exact (ex: "Marketing : positionnement...")
  - `description` : Concaténer "Objectifs et problématique professionnelle", "Objectifs du stage" et "Descriptif générique". Garder les sauts de ligne.
  - `hours` : Volume horaire (entier). Si "à définir localement", mettre `0`.
  - `resources` : Liste des codes ressources cités (ex: `["R1.01", "R1.02"]`).
  - `ac_codes` : Liste des codes AC cités (ex: `["AC11.01", "AC11.02"]`).

### C. Ressources (R)
- **Codes** : `R[N].[XX]` (ex: `R1.01`).
- **Champs requis** :
  - `code` : "R1.01"
  - `label` : Titre exact.
  - `description` : "Descriptif" complet (Contribution au développement...). 
  - `content` : "Contenu" complet (liste des savoirs, sans le titre "Contenu :").
  - `keywords` : "Mots clés". (Ajouter à la fin de la description ou stocker à part).
  - `hours` : Volume horaire défini nationalement (entier, ex: 24).
  - `hours_details` : La phrase complète du volume horaire (ex: "24 heures dont 20 heures de TP").
  - `ac_codes` : Liste des AC ciblés.

## 2. Instructions d'Extraction (Parsing)

### Ne te fie pas aux numéros de pages fixes !
La structure du document peut varier. Recherche les titres de sections :
- **"Fiches Situations d’apprentissage et d’évaluation (SAÉ)"** : Début des activités.
- **"Fiches Ressources"** : Début des ressources.
- **"SAÉ X.XX :"** : Début d'une fiche activité.
- **"Ressource RX.XX :"** : Début d'une fiche ressource.


### Nettoyage du Texte
- Concatène les lignes coupées mais **préserve les paragraphes et les listes à puces** (`–` ou `-`).
- Utilise `\n` pour les sauts de ligne dans le JSON.
- Échappe les guillemets doubles `"` dans le texte.
- **Attention aux ligatures** : "déﬁni" peut contenir un caractère spécial `ﬁ`. Traite-le comme "défini".

## 3. Format de Sortie JSON (Exemple)

```json
{
  "activities": [
    {
      "code": "SAE 1.01",
      "nom": "Titre complet",
      "description": "Objectifs...\n\nDescriptif générique...",
      "type": "SAE",
      "niveau": 1,
      "semestre": 1,
      "pathway": "Tronc Commun",
      "hours": 0,
      "resources": ["R1.01", "R1.02"],
      "ac_codes": ["AC11.01"]
    }
  ],
  "resources": [
    {
      "code": "R1.01",
      "label": "Titre complet",
      "description": "Contribution au développement...",
      "content": "Contenu :\n- Point 1\n- Point 2",
      "hours": 24,
      "hours_details": "24 heures dont 20 heures de TP",
      "ac_codes": ["AC11.01"]
    }
  ]
}
```

## 4. Tâche Spécifique
Extrais les SAÉ, Stages et Ressources du **Semestre [X]** (ou Niveau [X]).

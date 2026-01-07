# Epic 5 : Visual Analytics & Reporting - Spécifications Détaillées

**Statut :** En cours de définition
**Priorité :** Moyenne
**Objectif :** Transformer les données brutes en indicateurs visuels pour le suivi des parcours.

---

## 1. Contexte UI/UX
L'application doit utiliser des graphiques modernes (Radar Charts) pour illustrer l'acquisition des 5 compétences du BUT TC.

## 2. User Stories

### Story 5.1 : Dashboard Radar Chart (Étudiant)
**En tant qu'** Étudiant,
**Je veux** voir ma progression sur un graphique en radar,
**Afin d'** identifier immédiatement mes points forts et mes axes de progression.
*   **Critères d'Acceptation :**
    1.  Graphique radar avec 5 axes (une pour chaque compétence majeure).
    2.  Les données sont basées sur le pourcentage de validation des professeurs.
    3.  L'étudiant peut cliquer sur une branche pour voir le détail des AC/SAE associés.

### Story 5.2 : Rapports de Synthèse (PDF)
**En tant que** Étudiant,
**Je veux** générer un "Passeport de Compétences" au format PDF,
**Afin de** le joindre à mon CV ou mon dossier de poursuite d'études.
*   **Critères d'Acceptation :**
    1.  Bouton "Générer mon passeport" sur le dashboard.
    2.  PDF contenant : Nom, Promo, Graphique radar, Liste des compétences validées et liens vers les preuves majeures.
    3.  Mise en page professionnelle (branding départemental).

### Story 5.3 : Analytics de Promotion (Professeur)
**En tant que** Professeur Référent,
**Je veux** voir une "Heatmap" de ma promotion,
**Afin de** détecter les étudiants en difficulté sur une compétence spécifique.
*   **Critères d'Acceptation :**
    1.  Tableau croisé : Étudiants (Lignes) x Compétences (Colonnes).
    2.  Couleurs basées sur le taux d'acquisition (Rouge < 30%, Orange < 70%, Vert >= 70%).
    3.  Filtres par groupe (TP1, TP2, etc.).

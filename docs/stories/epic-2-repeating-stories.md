# User Stories - Epic 2 (Suite) : Gestion des Redoublants

## Story 2.4 : Dashboard de Parcours Pluriannuel
**En tant qu'** Étudiant (notamment redoublant),
**Je veux** visualiser mes tentatives passées et actuelles sur un dashboard unique couvrant les 3 ans du BUT,
**Afin d'** avoir une vision claire de ma progression globale et de mes acquis.

### Contexte Technique
*   **Frontend :** Mise à jour de la vue Dashboard pour grouper les évaluations par année académique.
*   **Backend :** Le endpoint `/api/me/dashboard` doit retourner l'historique complet, pas seulement l'année en cours.

### Critères d'Acceptation
1.  Le dashboard affiche des sections distinctes pour BUT1, BUT2 et BUT3.
2.  En cas de redoublement, les deux années apparaissent (ex: "BUT2 - 2024" et "BUT2 - 2025").
3.  Une note capitalisée est visuellement identifiée par un badge "Capitalisé".

---

## Story 2.5 : Interface "Mode Entretien" pour le Référent
**En tant que** Professeur Référent,
**Je veux** disposer d'une interface de saisie rapide lors de mon entretien avec un redoublant,
**Afin de** acter les décisions de capitalisation ou de ré-évaluation en temps réel.

### Contexte Technique
*   **Frontend :** Nouvelle vue "Entretien de Rentrée" accessible depuis la fiche étudiant.
*   **Permissions :** Scope spécifique permettant au référent de modifier le statut des compétences de ses étudiants assignés.

### Critères d'Acceptation
1.  Liste des compétences de l'année redoublée avec la note N-1 affichée.
2.  Un interrupteur (Switch) pour chaque compétence : "Capitaliser (Garder la note)" ou "Nouvelle Tentative".
3.  Le choix "Capitaliser" n'est disponible que si la note N-1 est > 10/20.
4.  Un bouton "Valider les décisions" qui verrouille les choix pour le semestre.

---

## Story 2.6 : Logique de Capitalisation et Verrouillage
**En tant que** Système,
**Je veux** reporter et verrouiller automatiquement les notes capitalisées,
**Afin d'** empêcher l'étudiant de soumettre de nouvelles preuves pour une compétence déjà acquise.

### Contexte Technique
*   **Backend :** Logique de copie de la note N-1 vers l'instance N.
*   **Base de données :** Flag `is_capitalized` sur le modèle `StudentEvaluation`.

### Critères d'Acceptation
1.  Si une compétence est marquée comme `is_capitalized`, l'accès à l'upload de fichiers est bloqué pour cette compétence.
2.  La note reportée est utilisée dans les calculs de moyenne du département.
3.  Historique : Le système conserve le lien vers les preuves de l'année N-1 pour consultation.

---

## Notes pour les Développeurs
*   Attention à la gestion de la date de l'entretien pour l'auditabilité.
*   Prévoir un mécanisme de "déverrouillage par un Admin" en cas d'erreur de saisie lors de l'entretien.

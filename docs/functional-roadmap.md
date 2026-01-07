# Feuille de Route Fonctionnelle (Roadmap) - Skills Hub

**Projet :** Application de Suivi de Compétences BUT TC
**Date :** Mercredi 7 Janvier 2026
**Cible :** Product Manager / Équipe de Développement

---

## 1. Vision du Produit
Passer d'un outil d'administration pure à une plateforme interactive de **gestion de carrière** pour l'étudiant, centrée sur la preuve et la validation souveraine.

## 2. Jalon 1 : Le Portfolio Souverain (Epic 3)
*Objectif : Permettre à l'étudiant de constituer son dossier de preuves.*

*   **Story 3.1 - Proxy Nextcloud :** Implémenter le service backend qui reçoit les fichiers et les pousse sur le Nextcloud de l'IUT (via WebDAV).
*   **Story 3.2 - Galerie de Preuves :** Interface "Mes Documents" pour l'étudiant où il voit ses fichiers stockés sur Nextcloud.
*   **Story 3.3 - Liaison Preuve-Compétence :** Dans le référentiel, l'étudiant doit pouvoir cliquer sur "Ajouter une preuve" et sélectionner un fichier de sa galerie.

## 3. Jalon 2 : Le Cycle d'Évaluation "Zéro Friction" (Epic 4)
*Objectif : Connecter les tuteurs externes et les professeurs.*

*   **Story 4.1 - Auto-évaluation :** L'étudiant dépose un commentaire réflexif sur une compétence et "lance" la demande d'évaluation.
*   **Story 4.2 - Système de Magic Links :** 
    *   Génération d'un token sécurisé par email pour le tuteur.
    *   Interface ultra-simplifiée (sans login) pour que le tuteur laisse son avis en 2 clics.
*   **Story 4.3 - Le Slider du Professeur :** Interface de validation finale où le prof voit (Avis Étudiant + Avis Tuteur + Preuve) et ajuste un curseur de 0 à 100%.

## 4. Jalon 3 : Visualisation et Analytics (Epic 5)
*Objectif : Donner du sens à la progression.*

*   **Story 5.1 - Radar Charts :** Dashboard étudiant affichant un graphique en radar des 5 parcours pour visualiser les forces et faiblesses.
*   **Story 5.2 - Heatmap Promotion :** Vue pour le prof pour identifier en un coup d'œil les étudiants en retard sur une compétence spécifique.

## 5. Jalon 4 : Automatisation (Epic 6)
*Objectif : Faciliter le déploiement à d'autres départements.*

*   **Story 6.1 - Assistant d'Import PDF :** Finaliser l'interface qui permet de téléverser un Programme National PDF et d'en extraire automatiquement l'arbre des compétences (en utilisant les scripts `ai_parser.py` existants).

---

## 6. Indicateurs de Succès (KPIs)
1.  **Souveraineté :** 100% des fichiers sont sur Nextcloud (0 octet de preuve sur le serveur de l'app).
2.  **Adhésion Tuteur :** Temps moyen d'évaluation par un tuteur externe < 60 secondes.
3.  **Accessibilité :** Score de conformité WCAG AA > 90%.

---

## 7. Recommandation Prioritaire
Le PM doit prioriser le **Jalon 2 (Magic Links)**. C'est la fonctionnalité qui apporte le plus de valeur immédiate par rapport aux systèmes actuels (souvent basés sur des fichiers Excel envoyés par mail).

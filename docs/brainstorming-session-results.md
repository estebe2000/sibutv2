**Session Date:** Tuesday, January 6, 2026
**Facilitator:** Business Analyst Mary
**Participant:** Steeve (IUT Le Havre)

# Executive Summary

**Topic:** Conception d'une application de suivi des compétences (Portfolio/LMS) pour le BUT Techniques de Commercialisation (TC) de l'IUT du Havre.

**Session Goals:** Définir les fonctionnalités clés, le parcours utilisateur et l'architecture technique d'une plateforme centralisée pour gérer l'évaluation des compétences, les preuves (portfolio) et le suivi pédagogique.

**Techniques Used:**
1.  Décomposition Fonctionnelle (Entités & Structure)
2.  Cartographie du Parcours Utilisateur (User Journey)
3.  Définition Technique & UX

**Total Ideas Generated:** Une architecture complète et détaillée couvrant les besoins pédagogiques et techniques.

**Key Themes Identified:**
-   **Flexibilité Pédagogique:** Gestion fine des Compétences, Apprentissages Critiques (AC) et Parcours via des Templates.
-   **Évaluation Nuancée:** Système de curseur (0-100%), auto-évaluation + validation tuteur + validation prof.
-   **Gestion des Preuves (GED):** Centralisation via API Nextcloud, système de tags contextuels.
-   **Expérience Utilisateur (UX):** Accessible (Dys, contrastes), Responsive (Mobile/Desktop), Dashboard visuel (Radar, progression).
-   **Interopérabilité:** LDAP (Auth), Magic Links (Tuteurs), Docker/CapRover (Déploiement).

# Technique Sessions

## Technique 1: Décomposition Fonctionnelle - 20 min

**Description:** Identification des entités métier et de leurs relations basées sur le programme officiel du BUT TC.

**Ideas Generated:**
1.  **Acteurs:** Étudiant, Enseignant, Tuteur (Entreprise), Admin/Super-Prof.
2.  **Structure:** Compétences, AC, Parcours (5 officiels), Niveaux (BUT 1-3), SAÉ, Stages, Portfolio.
3.  **Logique d'Évaluation:**
    *   Filtre initial : "Concerné ?" (Oui/Non).
    *   Si Oui : Fréquence (Rare/Fréquent/Quotidien) + Écrit réflexif (Contexte).
    *   Validation finale : Curseur de pourcentage (0-100%) par le prof.
4.  **Templates:** Modèles pré-configurés par l'Admin (par Année, Parcours, Alternance/Initial) pour déploiement massif.

**Insights Discovered:**
-   La complexité du BUT impose une configuration centralisée (Admin) pour simplifier la vie des élèves/profs.
-   L'évaluation n'est pas binaire (Acquis/Non acquis) mais progressive.

## Technique 2: Cartographie du Parcours Utilisateur - 25 min

**Description:** Simulation des interactions clés durant l'année universitaire.

**Ideas Generated:**
1.  **Initialisation (Admin):** Création des Templates -> Assignation aux Groupes d'élèves (import/gestion interne car LDAP incomplet pour les groupes).
2.  **Collecte de Preuves (Élève - Fil rouge):**
    *   Upload de documents (PDF, Vidéo, Audio) vers Nextcloud (via API).
    *   Association via Tags (ex: "Stage 2026", "SAE Négociation").
    *   Une preuve peut servir plusieurs compétences/moments.
3.  **Évaluation Tuteur (Stage):**
    *   Pas de compte créé.
    *   Envoi d'un "Magic Link" sécurisé par email.
    *   Formulaire simplifié, évaluation "à l'aveugle" (sans voir l'auto-éval élève).
4.  **Validation (Prof - Fin de période):**
    *   Vue de synthèse : Auto-éval + Avis Tuteur + Preuves.
    *   Entretien oral de validation.
    *   Saisie finale via Curseur %.

**Notable Connections:**
-   Le Portfolio n'est pas une entité séparée mais une "Vue" agrégée des preuves taguées stockées dans la GED.
-   Le redoublement nécessite une conservation des acquis ("Capitalisation") tout en gardant l'accès à l'amélioration.

# Idea Categorization

## Immediate Opportunities
*Ideas ready to implement now*

**1. Architecture "Légère" & Souveraine**
- Description: Backend Python (FastAPI) + Frontend React/Vue + API Nextcloud pour le stockage.
- Why immediate: Utilise l'infrastructure existante (CapRover, LDAP) et délègue la complexité du stockage de fichiers à Nextcloud.
- Resources needed: Serveur Docker, Instance Nextcloud dédiée.

**2. Système de "Magic Link" pour Tuteurs**
- Description: Génération de tokens uniques temporaires envoyés par email pour accéder aux formulaires d'évaluation.
- Why immediate: Résout le problème majeur de la gestion des comptes utilisateurs externes ("Password fatigue").
- Resources needed: Service d'envoi d'emails (SMTP IUT).

**3. UX Inclusive & Responsive**
- Description: Interface Mobile-First avec options d'accessibilité natives (Contrastes, Polices Dys, Audio-description).
- Why immediate: Contrainte pédagogique forte et valeur ajoutée immédiate pour tous les étudiants.
- Resources needed: Design System accessible (ex: Rgaa, WCAG).

## Future Innovations
*Ideas requiring development/research*

**1. Calculateur de Moyennes Avancé**
- Description: Transformer les % de compétences en notes chiffrées (/20) via des coefficients paramétrables par AC/UE.
- Development needed: Algorithme de pondération flexible à intégrer dans les Templates.
- Timeline estimate: Version 2 (après validation du modèle de données).

**2. Module "Parcours Adapté"**
- Description: Interface spécifique pour gérer les aménagements (Tiers-temps, dispenses) directement dans le suivi de compétences.
- Development needed: Modélisation des exceptions au règlement des études.
- Timeline estimate: Version 1.5.

# Action Planning

## #1 Priority: Définition du Modèle de Données (Back-end)
- Rationale: La structure du BUT (Parcours, AC, Compétences) est complexe. Il faut la figer en base de données avant tout code d'interface.
- Next steps: Créer le diagramme Entité-Relation (MCD) et valider avec le programme officiel.
- Resources needed: Programme Officiel BUT TC, Spécifications techniques Nextcloud API.
- Timeline: Semaine 1

## #2 Priority: Prototypage UX/UI (Front-end)
- Rationale: Valider l'ergonomie (Curseurs, Upload, Magic Link) avant de coder la logique complexe.
- Next steps: Maquettes écrans (Mobile & Desktop) des 3 vues clés (Élève, Prof, Tuteur).
- Resources needed: Outil de maquettage (Figma/Penpot).
- Timeline: Semaine 1-2

## #3 Priority: POC Connexion (Infra)
- Rationale: Valider les interconnexions critiques (LDAP IUT, Nextcloud API, Docker).
- Next steps: Petit script Python qui authentifie un user LDAP et dépose un fichier sur Nextcloud.
- Resources needed: Accès serveurs IUT.
- Timeline: Semaine 1

# Reflection & Follow-up

**What Worked Well:**
- L'approche par "Scénarios Utilisateurs" a permis de lever des loups (gestion des tuteurs, redoublants).
- L'idée de déléguer le stockage à Nextcloud simplifie énormément le projet.

**Areas for Further Exploration:**
- **Import des données:** Comment initialiser la base "Professeurs" et "Élèves" massivement ? (CSV ? Script LDAP ?)
- **Notification:** Système de rappel pour les tuteurs/élèves (Email ? Notif in-app ?).

**Recommended Follow-up Techniques:**
- **Product Requirements Document (PRD):** Pour spécifier techniquement chaque écran.
- **Architecture Diagram:** Pour visualiser les flux de données entre App, LDAP et Nextcloud.

---
*Session facilitated using the BMAD-METHOD™ brainstorming framework*

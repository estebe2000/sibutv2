# Skills Hub - BUT Techniques de Commercialisation

Application de gestion des compétences et du référentiel pédagogique pour le BUT TC.

## 🚀 Fonctionnalités

### 📚 Référentiel Digitalisé Complet
- **Couverture Totale** : BUT 1, BUT 2 et BUT 3 (Niveaux 1, 2, 3).
- **Parcours Spécialisés** :
  - Stratégie de Marque et Événementiel (SME)
  - Marketing et Management du Point de Vente (MMPV)
  - Marketing Digital, E-Business et Entrepreneuriat (MDEE)
  - Business International (BI)
  - Business Développement et Management de la Relation Client (BDMRC)
- **Contenu Riche** :
  - Fiches Ressources détaillées (Objectifs, Contenus pédagogiques, Mots clés).
  - Volumes horaires précis (ex: "24h dont 20h TP").
  - Lien direct entre Activités (SAÉ), Ressources et Compétences (AC).

### 🗺️ Roadmap & Découverte
- **Visualisation Stratégique** : Nouvelle vue Roadmap interactive présentant la progression des compétences (BUT 1 à 3) sous forme de matrice.
- **Génération PDF à la volée** : Moteur dynamique (`ReportLab`) créant des fiches interactives pour les Activités et Ressources.
  - **Sommaire Interactif** : Navigation par liens internes dans le PDF.
  - **Grille d'Auto-évaluation** : Page dédiée en mode paysage pour une utilisation optimale à l'impression.
- **Rendu Riche** : Support des badges interactifs et nettoyage automatique des caractères spéciaux (ligatures).

### 🖥️ Interface Utilisateur
- **Dashboard Central** : Point d'entrée unique sur le port 80 pour accéder à tous les services (Admin, Nextcloud, Mattermost, LDAP).
- **Filtrage Avancé** : Recherche et filtres par semestre, type et parcours pour la génération de documents.
- **Configuration d'Identité** : Gestion dynamique du logo, de l'adresse et des contacts de l'établissement.

### 🎓 Suivi des Stages & Évaluation Tripartite
- **Cycle Complet** : Gestion de l'assignation des tuteurs, programmation des visites et rapports de suivi (Site, Tél, Visio).
- **Évaluation Tripartite** : Système de notation et commentaires croisés entre l'Étudiant, le Maître de Stage (Pro) et le Tuteur Enseignant.
- **Magic Links** : Accès sécurisé sans authentification pour les tuteurs en entreprise via UUID unique.
- **Bilan de Stage PDF** : Document officiel rigoureux incluant :
  - **Graphique Radar** généré dynamiquement (`Matplotlib`) comparant les 3 regards.
  - **Détail des scores** par critère avec code couleur (Élève: Bleu, Pro: Orange, Prof: Vert).
  - **Synthèse des commentaires** détaillés pour chaque compétence.
- **Gestion de l'Historique** : Archivage des anciens stages et possibilité de réinitialiser un parcours en cas de changement d'entreprise.

### 📊 Pilotage & Gouvernance
- **Rapport de Gouvernance** : Vue centralisée des responsabilités segmentée par Ressources (R), SAÉ et Tutorat.
- **Exports Administratifs** : Génération de rapports PDF paysages filtrés pour le pilotage du département.
- **Recherche Instantanée** : Filtres temps-réel par enseignant, code d'activité ou email.

### 🛠️ Outils d'Administration & Sécurité
- **Provisioning Nextcloud** : Création automatique de dossiers sécurisés en "Lecture Seule" pour les élèves via l'API.
- **Configuration SMTP** : Support des e-mails réels (OVH ssl0.ovh.net) pour les notifications et les futurs Magic Links.
- **Sauvegarde & Reset** : Procédure "bulletproof" pour une réinstallation complète automatisée avec restauration des données SQL et LDAP.

## 📦 Installation & Lancement

### Pré-requis
- Docker & Docker Compose

### Démarrage Rapide
```bash
# 1. Lancer l'infrastructure complète
npm run infra:up

# 2. Accéder au Tableau de Bord
# URL : http://projet-edu.eu/ (ou http://localhost)
```

### Services Disponibles (Production)
| Service | URL | Description |
| :--- | :--- | :--- |
| **Dashboard** | https://home.educ-ai.fr/ | Portail central |
| **Skills Hub Admin** | https://home.educ-ai.fr/app/ | Gestion du référentiel (SSO) |
| **Nextcloud** | https://nextcloud.educ-ai.fr/ | Stockage & Édition (SSO) |
| **Keycloak** | https://keycloak.educ-ai.fr/ | Identité & SSO |
| **Mattermost** | https://home.educ-ai.fr/mattermost/ | Collaboration |
| **LDAP Admin** | http://projet-edu.eu:8081/ | Gestion des comptes (Local) |

## ☁️ Configuration Cloudflare Tunnel

Pour exposer le projet via Cloudflare Zero Trust (domaine `educ-ai.fr`), configurez vos **Public Hostnames** comme suit :

| Subdomain | Domain | Service | Origin Settings |
| :--- | :--- | :--- | :--- |
| `home` | `educ-ai.fr` | `http://localhost:80` | Default |
| `nextcloud` | `educ-ai.fr` | `http://localhost:8082` | Default |
| `keycloak` | `educ-ai.fr` | `http://localhost:8080` | Default |
| `only-office`| `educ-ai.fr` | `http://localhost:8083` | Default |

**Note :** Si vous pointez vers le port `443` de la machine hôte au lieu des ports directs, activez l'option **"No TLS Verify"** dans les *Origin Settings* pour accepter le certificat auto-signé de Nginx.

## 🔑 Identification Unique (SSO)

Le projet utilise **Keycloak** comme Identity Provider centralisé.
- **Login unique** : Connectez-vous une fois sur le Dashboard pour accéder à toutes les applications.
- **Source d'utilisateurs** : Fédération LDAP (Université) + Utilisateurs locaux Keycloak (Intervenants).
- **Compte Admin par défaut** : `admin` / `Rangetachambre76*`
- **Comptes de Test (Local)** : 
  - Admin : `tata` / `tata`
  - Directeur d'Études : `tbtb` / `tbtb`
  - Enseignant : `tctc` / `tctc`
  - Étudiant : `tdtd` / `tdtd`

### Commandes Utiles

**Purger et reconstruire (Full Reset) :**
```bash
# Cette commande efface TOUS les volumes et réinitialise LDAP/Nextcloud/Keycloak
npm run infra:reset
```

**Sauvegarder les données (BDD) :**
```bash
docker exec but_tc_db pg_dump -U app_user skills_db > backup_data.sql
```

**Restaurer les données :**
```bash
docker exec -i but_tc_db psql -U app_user skills_db < backup_data.sql
```

## 📂 Structure du Projet

- `apps/api` : Backend FastAPI (SQLModel, PostgreSQL), refactorisé avec des routeurs modulaires.
- `apps/web` : Frontend React (Mantine UI, Vite), avec gestion d'état centralisée (Zustand) et composants modulaires.
- `apps/api/app/data/referentiel_final.json` : Fichier maître des données pédagogiques.
- `infrastructure` : Configuration Docker et scripts de déploiement.
- `docs` : Documentation technique. Les archives sont dans `docs/archive`.

## 🛠 Maintenance

Les scripts de maintenance (ex: extraction PDF) sont situés dans `apps/api/scripts/`.
- `ai_parser.py` : Script d'extraction assisté par IA (Codestral).

---
*Projet développé avec l'assistance de Gemini CLI.*

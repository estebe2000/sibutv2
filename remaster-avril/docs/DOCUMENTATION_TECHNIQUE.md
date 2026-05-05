# Documentation Technique - Skills Hub Remaster

## 1. Architecture Logicielle (Clean Architecture)

Le backend de l'application a été refondu pour suivre les principes de la **Clean Architecture** (ou Architecture Hexagonale), visant à séparer clairement les responsabilités et à rendre le code testable et maintenable.

La structure des dossiers est la suivante :

```text
backend/app/
├── api/             # Couche Présentation (Contrôleurs, Endpoints FastAPI)
├── application/     # Couche Application (Cas d'utilisation / Use Cases, Interfaces)
├── core/            # Couche Configuration (Initialisation, Settings, Middlewares)
├── infrastructure/  # Couche Infrastructure (Base de données, Services externes)
└── models/          # Couche Domaine (Modèles SQLModel/Pydantic purs)
```

### 1.1 Couche Domaine (`app/models/`)
Contient les entités métier pures. Le monolithe `models.py` a été divisé par domaine :
- `user.py` : Utilisateurs et Groupes.
- `curriculum.py` : Compétences, Composantes Essentielles, Apprentissages Critiques, Ressources.
- `activity.py` : SAÉs, Projets, Stages.
- `internship.py` : Dossiers de stage, Entreprises.
- `evaluations.py` : Grilles d'évaluation, Résultats, Magic Links.

### 1.2 Couche Application (`app/application/`)
Orchestre la logique métier.
- **Use Cases** : Classes contenant la logique spécifique (ex: `SubmitInternshipApplicationUseCase`).
- **Interfaces** : Définition des contrats pour les services externes (ex: `PdfGeneratorInterface`, `SmtpServiceInterface`), garantissant un découplage fort.

### 1.3 Couche Infrastructure (`app/infrastructure/`)
Implémente les interfaces définies par la couche application :
- `database.py` : Configuration SQLAlchemy/SQLModel.
- `services/` : Implémentations concrètes (ex: `ReportLabPdfGenerator` pour la génération de PDF, `MatrixService` pour la communication avec le serveur Element).

### 1.4 Couche API (`app/api/`)
Points d'entrée de l'application (API REST). Expose les routes pour l'authentification (`auth.py`) et la génération de fiches (`fiches.py`). Un routeur séparé (`app/routers/mobile.py`) est dédié aux vues mobiles avec un rendu côté serveur via Jinja2.

---

## 2. Gestion des Données Personnelles (RGPD)

Le Skills Hub manipule des données d'étudiants, d'enseignants et de tuteurs professionnels. Les principes suivants s'appliquent :

### 2.1 Minimisation des données
- Les comptes internes (étudiants, enseignants) sont gérés via un SSO (Keycloak / LDAP de l'Université). Le backend ne stocke que l'`uid` LDAP, le nom complet et l'adresse email. **Aucun mot de passe n'est stocké dans la base locale.**
- Pour les tuteurs externes, seuls le nom, l'email et un numéro de téléphone facultatif sont conservés pour les besoins de l'évaluation de stage.

### 2.2 Transparence et Droits des utilisateurs
- (À implémenter) Une fonctionnalité d'export de profil doit permettre à l'utilisateur de télécharger toutes les données liées à son `uid` (évaluations, traces, messages).
- Droit à l'oubli : Les données d'évaluation étant liées au parcours académique, une politique de conservation (ex: anonymisation après l'obtention du diplôme) devra être configurée selon la charte de l'université.

### 2.3 Sécurité
- L'authentification est déléguée au SSO Keycloak (OIDC).
- Les "Magic Links" envoyés aux tuteurs utilisent un token UUID unique, généré de manière aléatoire et invalidé après la période d'évaluation.
- (En production) Tous les échanges transitent via HTTPS.

---

## 3. Procédure d'Installation et Mise à jour

### 3.1 Installation Initiale
Un script d'installation interactif (`install.py`) est fourni à la racine du projet.

1. **Cloner le dépôt** sur le serveur cible.
2. **Exécuter le wizard d'installation** :
   ```bash
   python3 install.py
   ```
   Ce script vous demandera de configurer :
   - Le domaine principal (ex: `educ-ai.fr`)
   - L'URL de la base de données PostgreSQL.
   - Les identifiants Keycloak (URL, Realm, Client ID, Secret).
   - Les paramètres du serveur IA Local (Endpoint, Nom du Modèle).
   - La configuration SMTP pour l'envoi des Magic Links.
3. Le script effectue des tests de connexion (non-bloquants) et génère un fichier `.env`.
4. **Lancer l'infrastructure Docker** :
   ```bash
   docker-compose up -d
   ```

### 3.2 Mise à jour
Pour mettre à jour l'application :
1. Récupérer la dernière version du code : `git pull origin main`.
2. Reconstruire les images Docker : `docker-compose build`.
3. Relancer les conteneurs : `docker-compose up -d`.
4. (Si des changements de modèle SQLModel ont eu lieu), les migrations automatiques via Alembic devront être appliquées (actuellement, la base est synchronisée via `SQLModel.metadata.create_all` au démarrage).

---

## 4. Sauvegarde et Restauration

### 4.1 Sauvegarde
La base de données principale (PostgreSQL) contient toute la valeur métier (évaluations, référentiels, mapping).

Pour créer une sauvegarde (dump SQL) :
```bash
docker exec -t <nom_du_conteneur_postgres> pg_dump -c -U app_user skills_db > backup_db_$(date +%Y%m%d).sql
```
*Note : Il est recommandé de planifier cette commande via une tâche `cron` quotidienne.*

### 4.2 Restauration
En cas de sinistre, pour restaurer un dump SQL dans le conteneur actif :
```bash
cat backup_db_YYYYMMDD.sql | docker exec -i <nom_du_conteneur_postgres> psql -U app_user -d skills_db
```
*Attention : Cette opération écrasera l'état actuel de la base de données.*

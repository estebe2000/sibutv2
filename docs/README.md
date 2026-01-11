# Documentation Technique

Bienvenue dans la documentation technique du projet Skills Hub.

## Index

- [Guide de Développement](development-guide.md) : Instructions pour les développeurs.
- [Archives](archive/) : Anciens documents de conception et brainstorming.

## Structure du Code

### Backend (`apps/api`)
Le backend est construit avec FastAPI.
- `app/main.py` : Point d'entrée de l'application.
- `app/routers/` : Contient les endpoints de l'API divisés par domaine (auth, users, curriculum, config, files).
- `app/models.py` : Modèles de données SQLModel.
- `app/database.py` : Configuration de la base de données.
- `app/pdf_generator.py` : Logique de génération des PDF avec ReportLab.

### Frontend (`apps/web`)
Le frontend est une application React utilisant Vite et Mantine UI.
- `src/App.tsx` : Composant principal (layout et routing simple).
- `src/views/` : Vues principales de l'application (Dispatching, Curriculum, etc.).
- `src/components/` : Composants réutilisables.
- `src/store/` : Gestion d'état avec Zustand.

## Déploiement
Voir le dossier `infrastructure/` pour les configurations Docker Compose.

# 📖 Documentation API ScoDoc Relay

Ce relais simplifie l'accès aux données de ScoDoc 9 de l'Université pour le projet Skills Hub.

## 🚀 Accès Rapides (Local Mac)

| Service | URL | Description |
| :--- | :--- | :--- |
| **Vue Démo** | [http://localhost:8092/demo](http://localhost:8092/demo) | Arborescence visuelle (Semestres > Groupes > Étudiants) |
| **API Hiérarchie** | [http://localhost:8092/api/hierarchie](http://localhost:8092/api/hierarchie) | **Format JSON** complet de l'arborescence |
| **Swagger UI** | [http://localhost:8092/docs](http://localhost:8092/docs) | Documentation interactive de toutes les routes |

## 🔗 Points d'accès JSON principaux

- `GET /api/hierarchie` : Récupère toute l'arborescence agrégée.
- `GET /departements` : Liste tous les départements accessibles.
- `GET /departement/TC/etudiants` : Liste tous les étudiants du département TC.
- `GET /etudiants_courants` : Liste globale des étudiants inscrits cette année.

## 🛠 Configuration Technique

- **Conteneur Docker** : `but_tc_scodoc_api_relay`
- **Port interne** : `8000`
- **Port externe (Mac)** : `8092`
- **Identifiants techniques utilisés** : `projet` / `steeve`
- **Serveur distant cible** : `https://scodoc.univ-lehavre.fr/ScoDoc/api`

---
*Note : Pour toute modification du code source, le fichier se trouve dans `apps/scodoc-api-relay/main.py`.*

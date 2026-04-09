# Tech Context

*Technologies principales*  
- Langages : Python, JavaScript, TypeScript, etc.  
- Frameworks : Django/Flask, React, Vue, etc.  
- Bases de données : PostgreSQL, MySQL, SQLite, etc.  
- Conteneurisation : Docker, Docker‑Compose  

*Environnement de développement*  
Décrire les outils (IDE, linters, formatters), les scripts d’initialisation et les dépendances.

*Gestion de version*  
- Système : Git  
- Branching model : Git‑flow, trunk‑based, etc.  

*Déploiement*  
Environnements (dev, test, prod), CI/CD, orchestration (Kubernetes, Docker‑Swarm), hébergement.

*Contraintes et exigences*  
- Compatibilité OS  
- Performances attendues  
- Sécurité (authentification, autorisation, chiffrement)

> **Technologies du projet**  
>   
> - **Langages** : Python 3.11, JavaScript/TypeScript.  
> - **Frameworks back‑end** : FastAPI, SQLModel, Authlib, Pydantic Settings.  
> - **Frameworks front‑end** : React 18, Vite, Mantine UI.  
> - **Bases de données** : PostgreSQL 15 (instances séparées pour l’application, Keycloak, Matrix, LiveKit).  
> - **Gestion d’identité** : Keycloak 26.0.0, OIDC.  
> - **Communication temps réel** : LiveKit, Matrix (Synapse), Coturn.  
> - **Conteneurisation & orchestration** : Docker, Docker‑Compose (versions alpha et beta).  
> - **Reverse‑proxy** : Nginx alpine, configuration via templates.  
> - **Sécurité & réseau** : Cloudflare Tunnel, certificats SSL, headers `X‑Forwarded‑*`.  
> - **CI/CD & déploiement** : scripts `install.sh`, `start.sh`, pipelines GitHub Actions (non montrés).  
> - **Outils de développement** : VSCode/Antigravity, linters (flake8, eslint), formatters (black, prettier).  
>   
> **Environnement de développement**  
> - Docker Desktop ou Docker Engine sur macOS.  
> - Variables d’environnement définies dans `.env` à la racine et dans `remaster‑avril/.env`.  
> - Accès aux services via `localhost` ou via le tunnel Cloudflare (`hub.educ‑ai.fr`).  
>   
> **Contraintes**  
> - Compatibilité macOS 12+ et Linux.  
> - Besoin de ports ouverts pour LiveKit (7880‑7882) et Matrix.  
> - Gestion des secrets (client‑secret Keycloak, JWT secret) via variables d’environnement.

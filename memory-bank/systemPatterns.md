# System Patterns

*Architecture générale*  
Décrire l’architecture du système (ex. micro‑services, monolithe, serveur‑client, etc.).

*Patrons de conception*  
Lister les design patterns utilisés (ex. Singleton, Factory, Repository, Observer, etc.) et les raisons de leur choix.

*Relations entre composants*  
Schématiser les interactions majeures entre les modules, services, bases de données et interfaces externes.

*Flux de données*  
Expliquer comment les données circulent du front‑end au back‑end, les points de validation et de transformation.

*Contraintes techniques*  
Indiquer les limites imposées par l’infrastructure (ex. latence, scalabilité, sécurité).

> **Patrons système**  
>   
> - **Architecture micro‑services** : chaque composant (API, front‑end, Keycloak, LiveKit, Matrix, Coturn, bases de données) tourne dans son propre conteneur Docker.  
> - **Reverse‑proxy Nginx** : le service `ingress` gère le routage HTTP/HTTPS, les en‑têtes `X‑Forwarded‑*` et la terminaison SSL.  
> - **Authentification OIDC** : FastAPI utilise `authlib` pour déléguer l’authentification à Keycloak.  
> - **Communication temps réel** : LiveKit pour la vidéo, Matrix (Synapse) pour le chat, Coturn comme serveur TURN.  
> - **Design patterns** : Singleton (gestion de la connexion DB), Repository (abstraction des accès aux données), Observer (notifications d’événements), Factory (création de services).  
>   
> **Relations entre composants**  
> - Nginx → (proxy) → FastAPI (`app`) et Keycloak.  
> - FastAPI ↔ PostgreSQL (`db`, `db_keycloak`, `db_synapse`).  
> - LiveKit ↔ Coturn pour la traversée NAT.  
> - Matrix ↔ PostgreSQL (`db_synapse`).  
>   
> **Flux de données**  
> 1. Le client web envoie une requête HTTPS à `hub.educ‑ai.fr`.  
> 2. Nginx la redirige vers le service approprié (API, dashboard, livekit).  
> 3. FastAPI valide le token OIDC auprès de Keycloak, puis accède aux données en base.  
> 4. Les services temps réel échangent des médias via WebRTC, en s’appuyant sur Coturn.  
>   
> **Contraintes techniques**  
> - Latence réseau pour la vidéo (optimisation via TURN).  
> - Gestion des certificats SSL via Cloudflare.  
> - Scalabilité horizontale grâce à Docker‑Compose et possible migration vers Kubernetes.

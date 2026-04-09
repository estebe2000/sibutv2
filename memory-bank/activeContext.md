# Active Context

*Focus actuel*  
Décrire la tâche ou la fonctionnalité sur laquelle l’équipe travaille en ce moment.

*Modifications récentes*  
Lister les changements de code, de configuration ou de documentation effectués récemment.

*Prochaines étapes*  
Énumérer les actions à venir, les décisions à prendre et les points d’attention.

*Décisions clés*  
Documenter les choix techniques ou de conception adoptés récemment et leurs justifications.

> **Contexte actif (beta)**  
>   
> *Focus actuel* : finaliser la version beta du Skills Hub, notamment l’intégration complète de l’authentification OIDC, le reverse‑proxy Nginx, et les services temps réel (LiveKit, Matrix, Coturn).  
>   
> *Modifications récentes* :  
> - Ajout du service `ingress` (Nginx) dans `remaster‑avril/docker-compose.yml`.  
> - Implémentation du middleware `ProxyHeadersMiddleware` et de la configuration OIDC dans `remaster‑avril/backend/app/main.py`.  
> - Création du fichier de configuration `remaster‑avril/backend/app/core/config.py` avec les variables d’environnement.  
> - Ajout des services `livekit`, `synapse` et `coturn`.  
>   
> *Prochaines étapes* :  
> - Tester la connexion vidéo LiveKit depuis le front‑end.  
> - Vérifier le tunnel Cloudflare (`tunnel` service) et la résolution du domaine `hub.educ‑ai.fr`.  
> - Rédiger la documentation de déploiement (Docker‑Compose, variables d’environnement).  
> - Effectuer des tests de charge et de sécurité sur l’authentification OIDC.  
>   
> *Décisions clés* :  
> - Utiliser Nginx comme point d’entrée unique pour simplifier la gestion SSL et les en‑têtes.  
> - Séparer les bases de données par domaine fonctionnel pour isoler les charges.  
> - Prioriser OIDC pour l’unification de l’authentification entre tous les services.

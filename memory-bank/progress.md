# Progress

*Ce qui fonctionne*  
Lister les fonctionnalités ou parties du système qui sont déjà opérationnelles.

*Ce qui reste à faire*  
Énumérer les tâches en cours, les fonctionnalités à implémenter et les bugs à corriger.

*État actuel*  
Indiquer le statut global du projet (ex. 60 % complet, version v1.2‑beta, etc.).

*Problèmes connus*  
Décrire les limitations, les risques et les points bloquants.

*Prochaines étapes*  
Planifier les actions à court terme (sprint, itération) et les livrables attendus.

> **État d’avancement**  
>   
> *Ce qui fonctionne* :  
> - Version alpha stable (services API, web, dashboard, Nextcloud, OnlyOffice, Mattermost, Odoo).  
> - Version beta : services `ingress`, `keycloak`, `app`, `db`, `livekit`, `synapse`, `coturn` démarrent correctement via Docker‑Compose.  
> - Authentification OIDC fonctionnelle (login → redirection vers Keycloak, retour avec token).  
>   
> *Ce qui reste à faire* :  
> - Intégration complète du front‑end vidéo LiveKit (UI, gestion des salles).  
> - Tests de bout en bout du tunnel Cloudflare et du domaine `hub.educ‑ai.fr`.  
> - Documentation détaillée du déploiement et des variables d’environnement.  
> - Optimisation des performances (caching, scaling).  
>   
> *État actuel* : environ **45 %** du projet beta implémenté, version beta en cours de test.  
>   
> *Problèmes connus* :  
> - CORS intermittents entre le front‑end et le service `app` derrière le proxy.  
> - Configuration du TURN parfois instable selon le réseau.  
> - Besoin de synchroniser les secrets entre les conteneurs (client‑secret Keycloak).  
>   
> *Prochaines étapes* :  
> - Résoudre les problèmes CORS via les headers Nginx.  
> - Stabiliser la configuration Coturn.  
> - Finaliser la documentation et préparer la migration de la version alpha vers la beta.

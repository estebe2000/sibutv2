# Product Context

*Pourquoi ce projet existe*  
Décrire le problème ou le besoin métier que le produit résout.

*Valeur ajoutée*  
Expliquer les bénéfices pour les utilisateurs et l’organisation.

*Objectifs fonctionnels*  
Lister les fonctions principales que le produit doit offrir.

*Expérience utilisateur*  
Décrire les attentes en termes d’ergonomie, de flux et d’accessibilité.

> **Bilan produit**  
>   
> Le projet original (version alpha) fournit une plateforme de gestion des compétences pour le BUT Techniques de Commercialisation, accessible via `hub.educ-ai.fr`. La version beta, située dans le répertoire `remaster-avril`, vise à moderniser l’infrastructure : intégration de Cloudflare, authentification OIDC via Keycloak, support vidéo (LiveKit) et messagerie instantanée (Matrix).  
>   
> **Valeur ajoutée**  
> - Sécurité renforcée grâce à Cloudflare et OIDC.  
> - Expérience utilisateur enrichie avec vidéo en temps réel et chat.  
> - Architecture plus modulaire et scalable.  
>   
> **Objectifs fonctionnels**  
> - Authentification unique (SSO) via Keycloak.  
> - Accès via le domaine `hub.educ‑ai.fr` (et sous‑domaines).  
> - Services de visioconférence et de messagerie intégrés.  
> - Maintien de toutes les fonctionnalités existantes (référentiel, portfolio, suivi de stage).  
>   
> **Expérience utilisateur**  
> - Interface responsive, compatible PWA.  
> - Navigation sécurisée derrière le reverse‑proxy Nginx.  
> - Gestion des sessions via cookies sécurisés.

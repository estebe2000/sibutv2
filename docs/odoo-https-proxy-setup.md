# Guide de Configuration Odoo avec Nginx Reverse Proxy (HTTPS)

Ce document détaille la procédure pour déployer Odoo derrière un reverse proxy Nginx avec SSL/HTTPS, en résolvant spécifiquement les problèmes de "Mixed Content" (contenu mixte) et les erreurs dans l'éditeur de site web.

## 1. Problème
Lorsqu'Odoo est derrière un proxy qui gère le SSL (Nginx), il peut continuer à générer des liens internes en `http://` s'il ne détecte pas correctement le protocole d'origine. Cela cause des erreurs de sécurité dans le navigateur ("Mixed Content") et bloque l'éditeur de site web.

## 2. Configuration Nginx

Le fichier de configuration Nginx (`nginx.conf`) doit transmettre explicitement les en-têtes indiquant que la connexion est sécurisée.

Ajoutez ou modifiez le bloc `server` pour Odoo comme suit :

```nginx
server {
    listen 80;
    listen 443 ssl;
    server_name odoo.votredomaine.fr;
    
    # Certificats SSL
    ssl_certificate /etc/nginx/ssl/votre_certificat.crt;
    ssl_certificate_key /etc/nginx/ssl/votre_cle.key;

    location / {
        proxy_pass http://odoo:8069;
        
        # En-têtes standards
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # En-têtes CRITIQUES pour HTTPS et Odoo
        proxy_set_header X-Forwarded-Proto https;  # Force le protocole HTTPS
        proxy_set_header X-Forwarded-Port 443;     # Indique le port HTTPS
        proxy_set_header X-Forwarded-Host $host;   # Conserve le nom de domaine
        proxy_set_header X-Forwarded-Server $host;
    }
}
```

## 3. Configuration Odoo (`odoo.conf`)

Odoo doit être configuré pour accepter ces en-têtes proxy. Créez ou modifiez le fichier `odoo.conf` (monté dans `/etc/odoo/odoo.conf` via Docker) :

```ini
[options]
; Active la lecture des headers X-Forwarded-*
proxy_mode = True

; Filtre de base de données (recommandé pour la sécurité)
db_filter = ^%d$

; Mot de passe maître (facultatif mais pratique pour l'admin)
admin_passwd = VotreMotDePasseSuperSecret
```

Assurez-vous que votre `docker-compose.yml` monte ce fichier :

```yaml
services:
  odoo:
    image: odoo:17.0
    volumes:
      - ./apps/odoo/odoo.conf:/etc/odoo/odoo.conf
      - odoo_data:/var/lib/odoo
```

## 4. Configuration Post-Installation (Dans Odoo)

Une fois Odoo lancé et la base de données créée, effectuez ces réglages **immédiatement** pour verrouiller l'URL.

1.  Connectez-vous en administrateur.
2.  Activez le **Mode Développeur** :
    *   Allez dans **Paramètres** (Settings).
    *   Tout en bas de la page, cliquez sur **Activer le mode développeur**.
3.  Allez dans le menu **Technique** (dans la barre supérieure) > **Paramètres Système**.
4.  Cherchez et modifiez la clé `web.base.url` :
    *   **Valeur** : `https://odoo.votredomaine.fr` (Bien vérifier le `https`).
5.  Créez une **nouvelle clé** pour empêcher Odoo de modifier l'URL automatiquement :
    *   **Clé** : `web.base.url.freeze`
    *   **Valeur** : `True`

## 5. Dépannage (En cas d'échec persistant)

Si malgré tout l'éditeur plante ou des erreurs persistent, il est probable que la base de données ait "mémorisé" le HTTP lors de la première requête.

**Solution radicale (Reset Factory) :**
1.  Arrêtez les conteneurs : `docker compose down`
2.  Supprimez les volumes de données Odoo (Attention, perte de données !) :
    ```bash
    docker volume rm projet_odoo_data projet_odoo_db_data
    ```
3.  Redémarrez : `docker compose up -d --build`
4.  Refaites l'étape 4 dès la création de la base.

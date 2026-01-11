# OnlyOffice Integration Debugging (Sprint 1)

## Status
- **Nextcloud**: Fonctionnel (HTTPS via Gateway).
- **OnlyOffice**: Serveur fonctionnel (accessible via `/onlyoffice/`).
- **Integration**: Échec du téléchargement de fichier (Server-to-Server).

## Symptômes
Lors de l'ouverture d'un fichier dans Nextcloud, OnlyOffice charge, mais affiche :
> "Le contenu du fichier ne correspond pas à l'extension du fichier."

Cela indique qu'OnlyOffice a téléchargé une page HTML (erreur ou login) au lieu du fichier DOCX/XLSX.

## Configurations Testées

### 1. Mode "Full Gateway" (Initial)
- **Config**: Nextcloud et OnlyOffice passent par `https://projet-edu.eu`.
- **Problème**: Loopback SSL Docker. OnlyOffice (interne) essaie de contacter l'IP externe de la Gateway.
- **Résultat**: Échec connexion ou Certificat auto-signé rejeté.

### 2. Mode "Internal Network" (Actuel)
- **Config**:
    - `DocumentServerInternalUrl`: `http://but_tc_onlyoffice/`
    - `StorageUrl`: `http://but_tc_nextcloud/`
    - `ALLOW_PRIVATE_IP_ADDRESS`: `true` (OnlyOffice)
    - `verify_peer_off`: `true` (Nextcloud)
    - `trusted_proxies`: `172.16.0.0/12` (Nextcloud)
- **Résultat**: "Échec du téléchargement". Nextcloud semble rejeter la connexion ou renvoyer une redirection vers HTTPS externe malgré la suppression de `OVERWRITEPROTOCOL`.

## Pistes Restantes (DevOps)
1.  **Shared Volume**: Monter le dossier `data` de Nextcloud en lecture seule dans OnlyOffice pour éviter le téléchargement HTTP. (Complexe car permissions `www-data` vs `ds`).
2.  **DNS Split-Horizon**: Configurer le DNS interne Docker pour que `projet-edu.eu` pointe directement sur `nginx` (Gateway) au lieu du Host, et s'assurer que Nginx route correctement le trafic interne.
3.  **Logs Profonds**: Augmenter le niveau de log de `docservice` pour voir l'URL exacte demandée et le code HTTP reçu.

## Workaround Temporaire
Les utilisateurs peuvent télécharger les fichiers, les éditer localement, et les réuploader. L'édition collaborative temps réel est indisponible sur l'environnement de dev local Docker Desktop.
